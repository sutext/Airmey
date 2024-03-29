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
public final class AMLock {
    private let unfairLock: os_unfair_lock_t
    public init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }
    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }
    public func lock() {
        os_unfair_lock_lock(unfairLock)
    }
    public func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
    public func around<T>(_ closure: () -> T) -> T {
        lock(); defer { unlock() }
        return closure()
    }
    public func around(_ closure: () -> Void) {
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
    /// Removes and returns the element at the specified position.
    ///
    /// All the elements following the specified position are moved up to
    /// close the gap.
    ///
    ///     var measurements: [Double] = [1.1, 1.5, 2.9, 1.2, 1.5, 1.3, 1.2]
    ///     let removed = measurements.remove(at: 2)
    ///     print(measurements)
    ///     // Prints "[1.1, 1.5, 1.2, 1.5, 1.3, 1.2]"
    ///
    /// - Parameter index: The position of the element to remove. `index` must
    ///   be a valid index of the array.
    /// - Returns: The element at the specified index.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the array.
    func remove(at index: T.Index) -> T.Element{
        write {
            $0.remove(at: index)
        }
    }

    /// Inserts a new element at the specified position.
    ///
    /// The new element is inserted before the element currently at the specified
    /// index. If you pass the array's `endIndex` property as the `index`
    /// parameter, the new element is appended to the array.
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.insert(100, at: 3)
    ///     numbers.insert(200, at: numbers.endIndex)
    ///
    ///     print(numbers)
    ///     // Prints "[1, 2, 3, 100, 4, 5, 200]"
    ///
    /// - Parameter newElement: The new element to insert into the array.
    /// - Parameter i: The position at which to insert the new element.
    ///   `index` must be a valid index of the array or equal to its `endIndex`
    ///   property.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the array. If
    ///   `i == endIndex`, this method is equivalent to `append(_:)`.
    func insert(_ newElement: T.Element, at i: T.Index){
        write {
            $0.insert(newElement, at: i)
        }
    }

    /// Removes all elements from the array.
    ///
    /// - Parameter keepCapacity: Pass `true` to keep the existing capacity of
    ///   the array after removing its elements. The default value is
    ///   `false`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the array.
    func removeAll(keepingCapacity keepCapacity: Bool = false){
        write {
            $0.removeAll(keepingCapacity: keepCapacity)
        }
    }
    /// Removes all the elements that satisfy the given predicate.
    ///
    /// Use this method to remove every element in a collection that meets
    /// particular criteria. The order of the remaining elements is preserved.
    /// This example removes all the odd values from an
    /// array of numbers:
    ///
    ///     var numbers = [5, 6, 7, 8, 9, 10, 11]
    ///     numbers.removeAll(where: { $0 % 2 != 0 })
    ///     // numbers == [6, 8, 10]
    ///
    /// - Parameter shouldBeRemoved: A closure that takes an element of the
    ///   sequence as its argument and returns a Boolean value indicating
    ///   whether the element should be removed from the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    func removeAll(where shouldBeRemoved: (T.Element) -> Bool){
        write {
            $0.removeAll(where: shouldBeRemoved)
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
