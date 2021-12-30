//
//  Protected.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import Foundation


/**
 * @typedef AMLock implemented by os_unfair_lock_t
 *
 * @abstract
 * Low-level lock that allows waiters to block efficiently on contention.
 *
 * In general, higher level synchronization primitives such as those provided by
 * the pthread or dispatch subsystems should be preferred.
 *
 * The values stored in the lock should be considered opaque and implementation
 * defined, they contain thread ownership information that the system may use
 * to attempt to resolve priority inversions.
 *
 * This lock must be unlocked from the same thread that locked it, attempts to
 * unlock from a different thread will cause an assertion aborting the process.
 *
 * This lock must not be accessed from multiple processes or threads via shared
 * or multiply-mapped memory, the lock implementation relies on the address of
 * the lock value and owning process.
 *
 * Must be initialized with OS_UNFAIR_LOCK_INIT
 *
 * @discussion
 * Replacement for the deprecated OSSpinLock. Does not spin on contention but
 * waits in the kernel to be woken up by an unlock.
 *
 * As with OSSpinLock there is no attempt at fairness or lock ordering, e.g. an
 * unlocker can potentially immediately reacquire the lock before a woken up
 * waiter gets an opportunity to attempt to acquire the lock. This may be
 * advantageous for performance reasons, but also makes starvation of waiters a
 * possibility.
 *
 */
fileprivate final class AMLock {
    private let unfairLock: os_unfair_lock_t
    init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }
    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }
    private func lock() {
        os_unfair_lock_lock(unfairLock)
    }
    private func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
    fileprivate func around<T>(_ closure: () -> T) -> T {
        lock(); defer { unlock() }
        return closure()
    }
    fileprivate func around(_ closure: () -> Void) {
        lock(); defer { unlock() }
        closure()
    }
}

/// A thread-safe wrapper around a value.
///
@propertyWrapper
@dynamicMemberLookup
public final class Protected<T> {
    private let lock = AMLock()
    private var value: T
    public init(_ value: T) {
        self.value = value
    }
    public init(wrappedValue: T) {
        value = wrappedValue
    }
    public var wrappedValue: T {
        get { lock.around { value } }
        set { lock.around { value = newValue } }
    }
    public var projectedValue: Protected<T> { self }
}

public extension Protected{
    func read<U>(_ closure: (T) -> U) -> U {
        lock.around { closure(self.value) }
    }
    @discardableResult
    func write<U>(_ closure: (inout T) -> U) -> U {
        lock.around { closure(&self.value) }
    }
    /// Access  the protected Dictionary.
    ///
    ///         class Test{
    ///             @Protected var values:[Int:Int] = [:]
    ///             func test(){
    ///                 if ($values[1] != 1){
    ///                     $values[1] = 1
    ///                 }
    ///             }
    ///
    subscript<Property>(dynamicMember keyPath: WritableKeyPath<T, Property>) -> Property {
        get { lock.around { value[keyPath: keyPath] } }
        set { lock.around { value[keyPath: keyPath] = newValue } }
    }
}
/// Array  methods
public extension Protected where T: RangeReplaceableCollection {
    /// Adds a new element to the end of this protected collection.
    ///
    ///         class Test{
    ///             @Protected var values:[Int] = []
    ///             func test(){
    ///                 $values.append(10)
    ///             }
    ///         }
    ///
    /// - Parameter newElement: The `Element` to append.
    func append(_ newElement: T.Element) {
        write { (ward: inout T) in
            ward.append(newElement)
        }
    }

    /// Adds the elements of a sequence to the end of this protected collection.
    ///
    /// - Parameter newElements: The `Sequence` to append.
    func append<S: Sequence>(contentsOf newElements: S) where S.Element == T.Element {
        write { (ward: inout T) in
            ward.append(contentsOf: newElements)
        }
    }

    /// Add the elements of a collection to the end of the protected collection.
    ///
    /// - Parameter newElements: The `Collection` to append.
    func append<C: Collection>(contentsOf newElements: C) where C.Element == T.Element {
        write { (ward: inout T) in
            ward.append(contentsOf: newElements)
        }
    }
}

/// Data  methods
public extension Protected where T == Data? {
    /// Adds the contents of a `Data` value to the end of the protected `Data`.
    ///
    /// - Parameter data: The `Data` to be appended.
    func append(_ data: Data) {
        write { (ward: inout T) in
            ward?.append(data)
        }
    }
}
