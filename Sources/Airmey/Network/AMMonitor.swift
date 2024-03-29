//
//  AMMonitor.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation
import SystemConfiguration

open class AMMonitor {
    /// Defines the various states of network reachability.
    public enum Status :Equatable{
        /// It is unknown whether the network is reachable.
        case unknown
        /// The network is not reachable.
        case notReachable
        /// The network is reachable on the associated `ConnectionType`.
        case reachable(ConnectionType)

        init(_ flags: SCNetworkReachabilityFlags) {
            guard flags.isActuallyReachable else { self = .notReachable; return }

            var networkStatus: Status = .reachable(.ethernetOrWiFi)

            if flags.isCellular { networkStatus = .reachable(.cellular) }

            self = networkStatus
        }
        public var isReachable:Bool {
            if case .reachable = self {
                return true
            }
            return false
        }
        /// Defines the various connection types detected by reachability flags.
        public enum ConnectionType {
            /// The connection type is either over Ethernet or WiFi.
            case ethernetOrWiFi
            /// The connection type is a cellular connection.
            case cellular
        }
    }

    /// A closure executed when the network reachability status changes. The closure takes a single argument: the
    /// network reachability status.
    public typealias Listener = (Status) -> Void

    /// Default `NetworkReachabilityManager` for the zero address and a `listenerQueue` of `.main`.
    public static let `default` = AMMonitor()

    // MARK: - Properties

    /// Whether the network is currently reachable.
    open var isReachable: Bool { isReachableOnCellular || isReachableOnEthernetOrWiFi }

    /// Whether the network is currently reachable over the cellular interface.
    ///
    /// - Note: Using this property to decide whether to make a high or low bandwidth request is not recommended.
    ///         Instead, set the `allowsCellularAccess` on any `URLRequest`s being issued.
    ///
    open var isReachableOnCellular: Bool { status == .reachable(.cellular) }

    /// Whether the network is currently reachable over Ethernet or WiFi interface.
    open var isReachableOnEthernetOrWiFi: Bool { status == .reachable(.ethernetOrWiFi) }

    /// `DispatchQueue` on which reachability will update.
    public let reachabilityQueue = DispatchQueue(label: "com.airmey.reachabilityQueue")

    /// Flags of the current reachability type, if any.
    open var flags: SCNetworkReachabilityFlags? {
        var flags = SCNetworkReachabilityFlags()

        return (SCNetworkReachabilityGetFlags(reachability, &flags)) ? flags : nil
    }

    /// The current network reachability status.
    open var status: Status {
        flags.map(Status.init) ?? .unknown
    }

    /// Mutable state storage.
    struct MutableState {
        /// A closure executed when the network reachability status changes.
        var listener: Listener?
        /// `DispatchQueue` on which listeners will be called.
        var listenerQueue: DispatchQueue?
        /// Previously calculated status.
        var previousStatus: Status?
    }

    /// `SCNetworkReachability` instance providing notifications.
    private let reachability: SCNetworkReachability

    /// Protected storage for mutable state.
    @Protected
    private var mutableState = MutableState()

    // MARK: - Initialization

    /// Creates an instance with the specified host.
    ///
    /// - Note: The `host` value must *not* contain a scheme, just the hostname.
    ///
    /// - Parameters:
    ///   - host:          Host used to evaluate network reachability. Must *not* include the scheme (e.g. `https`).
    public convenience init?(host: String) {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else { return nil }

        self.init(reachability: reachability)
    }

    /// Creates an instance that monitors the address 0.0.0.0.
    ///
    /// Reachability treats the 0.0.0.0 address as a special token that causes it to monitor the general routing
    /// status of the device, both IPv4 and IPv6.
    public convenience init?() {
        var zero = sockaddr()
        zero.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zero.sa_family = sa_family_t(AF_INET)

        guard let reachability = SCNetworkReachabilityCreateWithAddress(nil, &zero) else { return nil }

        self.init(reachability: reachability)
    }

    private init(reachability: SCNetworkReachability) {
        self.reachability = reachability
    }

    deinit {
        stopListening()
    }

    // MARK: - Listening

    /// Starts listening for changes in network reachability status.
    ///
    /// - Note: Stops and removes any existing listener.
    ///
    /// - Parameters:
    ///   - queue:    `DispatchQueue` on which to call the `listener` closure. `.main` by default.
    ///   - listener: `Listener` closure called when reachability changes.
    ///
    /// - Returns: `true` if listening was started successfully, `false` otherwise.
    @discardableResult
    open func startListening(onQueue queue: DispatchQueue = .main,
                             onUpdatePerforming listener: @escaping Listener) -> Bool {
        stopListening()

        $mutableState.write { state in
            state.listenerQueue = queue
            state.listener = listener
        }

        var context = SCNetworkReachabilityContext(version: 0,
                                                   info: Unmanaged.passUnretained(self).toOpaque(),
                                                   retain: nil,
                                                   release: nil,
                                                   copyDescription: nil)
        let callback: SCNetworkReachabilityCallBack = { _, flags, info in
            guard let info = info else { return }

            let instance = Unmanaged<AMMonitor>.fromOpaque(info).takeUnretainedValue()
            instance.notifyListener(flags)
        }

        let queueAdded = SCNetworkReachabilitySetDispatchQueue(reachability, reachabilityQueue)
        let callbackAdded = SCNetworkReachabilitySetCallback(reachability, callback, &context)

        // Manually call listener to give initial state, since the framework may not.
        if let currentFlags = flags {
            reachabilityQueue.async {
                self.notifyListener(currentFlags)
            }
        }

        return callbackAdded && queueAdded
    }

    /// Stops listening for changes in network reachability status.
    open func stopListening() {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
        $mutableState.write { state in
            state.listener = nil
            state.listenerQueue = nil
            state.previousStatus = nil
        }
    }

    // MARK: - Internal - Listener Notification

    /// Calls the `listener` closure of the `listenerQueue` if the computed status hasn't changed.
    ///
    /// - Note: Should only be called from the `reachabilityQueue`.
    ///
    /// - Parameter flags: `SCNetworkReachabilityFlags` to use to calculate the status.
    func notifyListener(_ flags: SCNetworkReachabilityFlags) {
        let newStatus = Status(flags)

        $mutableState.write { state in
            guard state.previousStatus != newStatus else { return }
            state.previousStatus = newStatus
            let listener = state.listener
            state.listenerQueue?.async { listener?(newStatus) }
        }
    }
}
extension SCNetworkReachabilityFlags {
    var isReachable: Bool { contains(.reachable) }
    var isConnectionRequired: Bool { contains(.connectionRequired) }
    var canConnectAutomatically: Bool { contains(.connectionOnDemand) || contains(.connectionOnTraffic) }
    var canConnectWithoutUserInteraction: Bool { canConnectAutomatically && !contains(.interventionRequired) }
    var isActuallyReachable: Bool { isReachable && (!isConnectionRequired || canConnectWithoutUserInteraction) }
    var isCellular: Bool {
        #if os(iOS) || os(tvOS)
        return contains(.isWWAN)
        #else
        return false
        #endif
    }

    /// Human readable `String` for all states, to help with debugging.
    var readableDescription: String {
        let W = isCellular ? "W" : "-"
        let R = isReachable ? "R" : "-"
        let c = isConnectionRequired ? "c" : "-"
        let t = contains(.transientConnection) ? "t" : "-"
        let i = contains(.interventionRequired) ? "i" : "-"
        let C = contains(.connectionOnTraffic) ? "C" : "-"
        let D = contains(.connectionOnDemand) ? "D" : "-"
        let l = contains(.isLocalAddress) ? "l" : "-"
        let d = contains(.isDirect) ? "d" : "-"
        let a = contains(.connectionAutomatic) ? "a" : "-"

        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)\(a)"
    }
}
