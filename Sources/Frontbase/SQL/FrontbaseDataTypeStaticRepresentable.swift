/// A type that is capable of being represented by a `FrontbaseFieldType`.
///
/// Types conforming to this protocol can be automatically migrated by `FluentFrontbase`.
///
/// See `FrontbaseType` for more information.
public protocol FrontbaseDataTypeStaticRepresentable {
    /// See `FrontbaseDataTypeStaticRepresentable`.
    static var frontbaseDataType: FrontbaseDataType { get }
}

extension FixedWidthInteger {
    /// See `FrontbaseDataTypeStaticRepresentable`.
    public static var frontbaseDataType: FrontbaseDataType { return .integer }
}

extension UInt: FrontbaseDataTypeStaticRepresentable { }
extension UInt8: FrontbaseDataTypeStaticRepresentable { }
extension UInt16: FrontbaseDataTypeStaticRepresentable { }
extension UInt32: FrontbaseDataTypeStaticRepresentable { }
extension UInt64: FrontbaseDataTypeStaticRepresentable { }
extension Int: FrontbaseDataTypeStaticRepresentable { }
extension Int8: FrontbaseDataTypeStaticRepresentable { }
extension Int16: FrontbaseDataTypeStaticRepresentable { }
extension Int32: FrontbaseDataTypeStaticRepresentable { }
extension Int64: FrontbaseDataTypeStaticRepresentable { }

extension Date: FrontbaseDataTypeStaticRepresentable {
    /// See `FrontbaseDataTypeStaticRepresentable`.
    public static var frontbaseDataType: FrontbaseDataType { return .timestamp }
}

extension BinaryFloatingPoint {
    /// See `FrontbaseDataTypeStaticRepresentable`.
    public static var frontbaseDataType: FrontbaseDataType { return .real }
}

extension Float: FrontbaseDataTypeStaticRepresentable { }
extension Double: FrontbaseDataTypeStaticRepresentable { }

extension Bool: FrontbaseDataTypeStaticRepresentable {
    /// See `FrontbaseDataTypeStaticRepresentable`.
    public static var frontbaseDataType: FrontbaseDataType { return Int.frontbaseDataType }
}

extension UUID: FrontbaseDataTypeStaticRepresentable {
    /// See `FrontbaseDataTypeStaticRepresentable`.
    public static var frontbaseDataType: FrontbaseDataType { return .varyingbits (size: 128) }
}

extension Data: FrontbaseDataTypeStaticRepresentable {
    /// See `FrontbaseDataTypeStaticRepresentable`.
    public static var frontbaseDataType: FrontbaseDataType { return .blob }
}

extension String: FrontbaseDataTypeStaticRepresentable {
    /// See `FrontbaseDataTypeStaticRepresentable`.
    public static var frontbaseDataType: FrontbaseDataType { return .text (size: Int32.max / 2) }
}

extension URL: FrontbaseDataTypeStaticRepresentable {
    /// See `FrontbaseDataTypeStaticRepresentable`.
    public static var frontbaseDataType: FrontbaseDataType { return String.frontbaseDataType }
}

extension Bit96: FrontbaseDataTypeStaticRepresentable {
    /// See `FrontbaseDataTypeStaticRepresentable`.
    public static var frontbaseDataType: FrontbaseDataType { return .bits (size: 96) }
}
