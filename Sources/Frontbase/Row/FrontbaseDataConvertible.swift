/// Capable of converting to and from `FrontbaseData`.
public protocol FrontbaseDataConvertible {
    /// Creates `Self` from `FrontbaseData`.
    static func convertFromFrontbaseData(_ data: FrontbaseData) throws -> Self
    
    /// Converts `self` to `FrontbaseData`.
    func convertToFrontbaseData() throws -> FrontbaseData
}

extension FrontbaseData: FrontbaseDataConvertible {
    /// See `FrontbaseDataConvertible.convertFromFrontbaseData(_:)`
    public static func convertFromFrontbaseData(_ data: FrontbaseData) throws -> FrontbaseData {
        return data
    }
    
    /// See `convertToFrontbaseData()`
    public func convertToFrontbaseData() throws -> FrontbaseData {
        return self
    }
}

extension Data: FrontbaseDataConvertible {
    /// See `FrontbaseDataConvertible.convertFromFrontbaseData(_:)`
    public static func convertFromFrontbaseData(_ data: FrontbaseData) throws -> Data {
        switch data {
            case .blob(let blob): return blob.data()
            default: throw FrontbaseError(problem: .warning, reason: "Could not convert to FrontbaseBlob: \(data)", source: .capture())
        }
    }
    
    /// See `convertToFrontbaseData()`
    public func convertToFrontbaseData() throws -> FrontbaseData {
        return .blob(FrontbaseBlob (data: self))
    }
}

extension UUID: FrontbaseDataConvertible {
    /// See `FrontbaseDataConvertible.convertFromFrontbaseData(_:)`
    public static func convertFromFrontbaseData(_ data: FrontbaseData) throws -> UUID {
        switch data {
            case .text(let string):
                guard let uuid = UUID(uuidString: string) else {
                    throw FrontbaseError(problem: .warning, reason: "Could not convert string to UUID: \(string)", source: .capture())
                }
                return uuid
            case .bits(let bits):
                let bits = bits
                switch bits.count {
                    case 16:
                        return UUID(uuid: (
                            bits[0], bits[1], bits[2], bits[3], bits[4], bits[5], bits[6], bits[7],
                            bits[8], bits[9], bits[10], bits[11], bits[12], bits[13], bits[14], bits[15]
                        ))
                    case 12:
                        return UUID(uuid: (
                            bits[0], bits[1], bits[2], bits[3], bits[4], bits[5], bits[6], bits[7],
                            bits[8], bits[9], bits[10], bits[11], 0, 0, 0, 0
                        ))
                    default:
                        throw FrontbaseError(problem: .warning, reason: "Could not convert to UUID: \(bits.description)", source: .capture())
                }
            case .blob(let blob):
                let data = blob.data()
                guard data.count == 16 else {
                    throw FrontbaseError(problem: .warning, reason: "Could not convert to UUID: \(blob.description)", source: .capture())
                }
                return UUID(uuid: (
                    data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7],
                    data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]
                ))
            default: throw FrontbaseError(problem: .warning, reason: "Could not convert to UUID: \(data)", source: .capture())
        }
    }
    
    /// See `convertToFrontbaseData()`
    public func convertToFrontbaseData() throws -> FrontbaseData {
        return .bits([
            uuid.0, uuid.1, uuid.2, uuid.3, uuid.4, uuid.5, uuid.6, uuid.7,
            uuid.8, uuid.9, uuid.10, uuid.11, uuid.12, uuid.13, uuid.14, uuid.15
        ])
    }
}

extension Date: FrontbaseDataConvertible {
    /// See `FrontbaseDataConvertible.convertFromFrontbaseData(_:)`
    public static func convertFromFrontbaseData (_ data: FrontbaseData) throws -> Date {
        switch data {
            case .timestamp (let timestamp): return timestamp
            default: throw FrontbaseError (problem: .warning, reason: "Could not convert to Date: \(data)", source: .capture())
        }
    }

    /// See `convertToFrontbaseData()`
    public func convertToFrontbaseData() throws -> FrontbaseData {
        return .timestamp (self)
    }
}

extension String: FrontbaseDataConvertible {
    /// See `FrontbaseDataConvertible.convertFromFrontbaseData(_:)`
    public static func convertFromFrontbaseData(_ data: FrontbaseData) throws -> String {
        switch data {
            case .text(let string): return string
            default: throw FrontbaseError(problem: .warning, reason: "Could not convert to String: \(data)", source: .capture())
        }
    }
    
    /// See `convertToFrontbaseData()`
    public func convertToFrontbaseData() throws -> FrontbaseData {
        return .text(self)
    }
}

extension URL: FrontbaseDataConvertible {
    /// See `FrontbaseDataConvertible.convertFromFrontbaseData(_:)`
    public static func convertFromFrontbaseData(_ data: FrontbaseData) throws -> URL {
        switch data {
            case .text(let string):
                guard let url = URL(string: string) else {
                    throw FrontbaseError(problem: .warning, reason: "Could not convert to URL: \(data)", source: .capture())
                }
                return url
            default: throw FrontbaseError(problem: .warning, reason: "Could not convert to URL: \(data)", source: .capture())
        }
    }
    
    /// See `convertToFrontbaseData()`
    public func convertToFrontbaseData() throws -> FrontbaseData {
        return .text(description)
    }
}


extension FixedWidthInteger {
    /// See `FrontbaseDataConvertible.convertFromFrontbaseData(_:)`
    public static func convertFromFrontbaseData(_ data: FrontbaseData) throws -> Self {
        switch data {
            case .integer (let int):
                guard int <= Self.max else {
                    throw FrontbaseError(problem: .warning, reason: "Int too large for \(Self.self): \(int)", source: .capture())
                }
                guard int >= Self.min else {
                    throw FrontbaseError(problem: .warning, reason: "Int too small for \(Self.self): \(int)", source: .capture())
                }
                return numericCast(int)
            case .float (let float):
                let int = Self.init (float)
                guard int <= Self.max else {
                    throw FrontbaseError(problem: .warning, reason: "Float too large for \(Self.self): \(float)", source: .capture())
                }
                guard int >= Self.min else {
                    throw FrontbaseError(problem: .warning, reason: "Float too small for \(Self.self): \(float)", source: .capture())
                }
                return numericCast(int)
            default: throw FrontbaseError(problem: .warning, reason: "Could not convert to \(Self.self): \(data)", source: .capture())
        }
    }
    
    /// See `convertToFrontbaseData()`
    public func convertToFrontbaseData() throws -> FrontbaseData {
        return .integer(numericCast(self))
    }
}

extension Array: FrontbaseDataConvertible where Element == UInt8 {
    /// See `FrontbaseDataConvertible.convertFromFrontbaseData(_:)`
    public static func convertFromFrontbaseData(_ data: FrontbaseData) throws -> [UInt8] {
        switch data {
            case .bits(let bits):
                return bits
            default: throw FrontbaseError(problem: .warning, reason: "Could not convert to \([UInt8].self): \(data)", source: .capture())
        }
    }
    
    /// See `convertToFrontbaseData()`
    public func convertToFrontbaseData() throws -> FrontbaseData {
        return .bits (self)
    }
}

extension Int8: FrontbaseDataConvertible { }
extension Int16: FrontbaseDataConvertible { }
extension Int32: FrontbaseDataConvertible { }
extension Int64: FrontbaseDataConvertible { }
extension Int: FrontbaseDataConvertible { }
extension UInt8: FrontbaseDataConvertible { }
extension UInt16: FrontbaseDataConvertible { }
extension UInt32: FrontbaseDataConvertible { }
extension UInt64: FrontbaseDataConvertible { }
extension UInt: FrontbaseDataConvertible { }

extension BinaryFloatingPoint {
    /// See `FrontbaseDataConvertible.convertFromFrontbaseData(_:)`
    public static func convertFromFrontbaseData(_ data: FrontbaseData) throws -> Self {
        switch data {
            case .integer(let int): return .init(int)
            case .float(let double): return .init(double)
            default: throw FrontbaseError(problem: .warning, reason: "Could not convert to String: \(data)", source: .capture())
        }
    }
    
    /// See `convertToFrontbaseData()`
    public func convertToFrontbaseData() throws -> FrontbaseData {
        switch self {
            case let double as Double: return .float(double)
            case let float as Float: return .float(.init(float))
            default: throw FrontbaseError(problem: .warning, reason: "Could not convert to FrontbaseData: \(Self.self)", source: .capture())
        }
        
    }
}

extension Double: FrontbaseDataConvertible { }
extension Float: FrontbaseDataConvertible { }

extension Bool: FrontbaseDataConvertible {
    /// See `FrontbaseDataConvertible.convertFromFrontbaseData(_:)`
    public static func convertFromFrontbaseData(_ data: FrontbaseData) throws -> Bool {
        switch data {
            case .boolean(let boolean): return .init(boolean)
            case .integer(let int): return .init(int != 0)
            case .float(let double): return .init(double != 0.0)
            default: throw FrontbaseError(problem: .warning, reason: "Could not convert to Bool: \(data)", source: .capture())
        }
    }

    /// See `convertToFrontbaseData()`
    public func convertToFrontbaseData() throws -> FrontbaseData {
        return .boolean (self)
    }
}

public struct Bit96 {
    let bits: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

    public init (bits: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)) {
        self.bits = bits
    }
}

extension Bit96: Codable {

    public init (from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.bits = (try container.decode (UInt8.self), try container.decode (UInt8.self), try container.decode (UInt8.self), try container.decode (UInt8.self),
                     try container.decode (UInt8.self), try container.decode (UInt8.self), try container.decode (UInt8.self), try container.decode (UInt8.self),
                     try container.decode (UInt8.self), try container.decode (UInt8.self), try container.decode (UInt8.self), try container.decode (UInt8.self))
    }

    public func encode (to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try Mirror (reflecting: bits).children.forEach { try container.encode ($0.value as! UInt8) }
    }
}

extension Bit96: ReflectionDecodable {
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    public static func reflectDecoded() -> (Bit96, Bit96) {
        let left = Bit96 (bits: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))
        let right = Bit96 (bits: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2))
        return (left, right)
    }
}

extension Array where Element == UInt8 {
    public init (_ bit96: Bit96) {
        self.init (Mirror (reflecting: bit96.bits).children.map { $0.value as! Element })
    }
}

extension Bit96: FrontbaseDataConvertible {
    /// See `FrontbaseDataConvertible.convertFromFrontbaseData(_:)`
    public static func convertFromFrontbaseData(_ data: FrontbaseData) throws -> Bit96 {
        switch data {
            case .bits(let bits):
                let bits = bits
                switch bits.count {
                    case 12:
                        return Bit96(bits: (
                            bits[0], bits[1], bits[2], bits[3],
                            bits[4], bits[5], bits[6], bits[7],
                            bits[8], bits[9], bits[10], bits[11]
                        ))
                    default:
                        throw FrontbaseError(problem: .warning, reason: "Could not convert to Bit96: \(bits.description)", source: .capture())
                }
            default: throw FrontbaseError(problem: .warning, reason: "Could not convert to Bit96: \(data)", source: .capture())
        }
    }
    
    /// See `convertToFrontbaseData()`
    public func convertToFrontbaseData() throws -> FrontbaseData {
        let (component1, component2, component3, component4, component5, component6, component7, component8, component9, component10, component11, component12) = bits
        return .bits([
            component1, component2, component3, component4,
            component5, component6, component7, component8,
            component9, component10, component11, component12
        ])
    }
}

extension Bit96: Equatable {
    public static func == (lhs: Bit96, rhs: Bit96) -> Bool {
        let (left1, left2, left3, left4, left5, left6, left7, left8, left9, left10, left11, left12) = lhs.bits
        let (right1, right2, right3, right4, right5, right6, right7, right8, right9, right10, right11, right12) = rhs.bits

        return (left1 == right1) && (left2 == right2) && (left3 == right3) && (left4 == right4) &&
               (left5 == right5) && (left6 == right6) && (left7 == right7) && (left8 == right8) &&
               (left9 == right9) && (left10 == right10) && (left11 == right11) && (left12 == right12)
    }
    
    
}
