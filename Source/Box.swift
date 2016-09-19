//  Copyright (c) 2014 Rob Rix. All rights reserved.

// MARK: BoxType

/// The type conformed to by all boxes.
public protocol BoxType {
    /// The type of the wrapped value.
    associatedtype Value

    /// Initializes an intance of the type with a value.
    init(_ value: Value)

    /// The wrapped value.
    var value: Value { get }
}

/// The type conformed to by mutable boxes.
public protocol MutableBoxType: BoxType {
    /// The (mutable) wrapped value.
    var value: Value { get set }
}


// MARK: Equality

/// Equality of `BoxType`s of `Equatable` types.
///
/// We cannot declare that e.g. `Box<T: Equatable>` conforms to `Equatable`, so this is a relatively ad hoc definition.
public func == <B: BoxType> (lhs: B, rhs: B) -> Bool where B.Value: Equatable {
    return lhs.value == rhs.value
}

/// Inequality of `BoxType`s of `Equatable` types.
///
/// We cannot declare that e.g. `Box<T: Equatable>` conforms to `Equatable`, so this is a relatively ad hoc definition.
public func != <B: BoxType> (lhs: B, rhs: B) -> Bool where B.Value: Equatable {
    return lhs.value != rhs.value
}


// MARK: Map

/// Maps the value of a box into a new box.
public func map<B: BoxType, C: BoxType>(_ v: B, f: (B.Value) -> C.Value) -> C {
    return C(f(v.value))
}

/// Wraps a type `T` in a reference type.
///
/// Typically this is used to work around limitations of value types (for example, the lack of codegen for recursive value types and type-parameterized enums with >1 case). It is also useful for sharing a single (presumably large) value without copying it.
public final class Box<T>: BoxType, CustomStringConvertible {
    /// Initializes a `Box` with the given value.
    public init(_ value: T) {
        self.value = value
    }


    /// Constructs a `Box` with the given `value`.
    public class func unit(_ value: T) -> Box<T> {
        return Box(value)
    }


    /// The (immutable) value wrapped by the receiver.
    public let value: T

    /// Constructs a new Box by transforming `value` by `f`.
    public func map<U>(_ f: (T) -> U) -> Box<U> {
        return Box<U>(f(value))
    }


    // MARK: Printable

    public var description: String {
        return String(describing: value)
    }
}
