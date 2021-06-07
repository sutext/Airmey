//
//  File.swift
//  
//
//  Created by supertext on 6/7/21.
//

import Foundation
private protocol Lock {
    func lock()
    func unlock()
}
extension Lock {
    func around<T>(_ closure: () -> T) -> T {
        lock(); defer { unlock() }
        return closure()
    }
    func around(_ closure: () -> Void) {
        lock(); defer { unlock() }
        closure()
    }
}

final class UnfairLock: Lock {
    private let unfairLock: os_unfair_lock_t

    init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    fileprivate func lock() {
        os_unfair_lock_lock(unfairLock)
    }

    fileprivate func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}
/// A thread-safe wrapper around a value.
@propertyWrapper
@dynamicMemberLookup
final class Sync<T> {
    private let lock = UnfairLock()
    private var value: T
    init(_ value: T) {
        self.value = value
    }
    var wrappedValue: T {
        get { lock.around { value } }
        set { lock.around { value = newValue } }
    }
    var projectedValue: Sync<T> { self }

    init(wrappedValue: T) {
        value = wrappedValue
    }
    func read<U>(_ closure: (T) -> U) -> U {
        lock.around { closure(self.value) }
    }
    @discardableResult
    func write<U>(_ closure: (inout T) -> U) -> U {
        lock.around { closure(&self.value) }
    }

    subscript<Property>(dynamicMember keyPath: WritableKeyPath<T, Property>) -> Property {
        get { lock.around { value[keyPath: keyPath] } }
        set { lock.around { value[keyPath: keyPath] = newValue } }
    }
}
