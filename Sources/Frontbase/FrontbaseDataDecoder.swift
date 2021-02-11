import Foundation

/// Decodes `Decodable` types from `FrontbaseData`.
///
///     let string = try FrontbaseDecoder().decode(String.self, from: .text("Hello"))
///     print(string) // "Hello"
///
public struct FrontbaseDataDecoder {
    /// Creates a new `FrontbaseDataDecoder`.
    public init() { }
    
    /// Decodes `Decodable` types from `FrontbaseData`.
    ///
    ///     let string = try FrontbaseDecoder().decode(String.self, from: .text("Hello"))
    ///     print(string) // "Hello"
    ///
    /// - parameters:
    ///     - type: `Decodable` type to decode.
    ///     - data: `FrontbaseData` to decode.
    /// - returns: Instance of decoded type.
    public func decode<D> (_ type: D.Type, from data: FrontbaseData) throws -> D where D: Decodable {
        if let convertible = type as? FrontbaseDataConvertible.Type {
            return convertible.init (frontbaseData: data) as! D
        }
        return try D(from: _Decoder(data: data))
    }
    
    // MARK: Private
    
    private struct _Decoder: Decoder {
        let codingPath: [CodingKey] = []
        var userInfo: [CodingUserInfoKey: Any] = [:]
        let data: FrontbaseData
        
        init(data: FrontbaseData) {
            self.data = data
        }
        
        struct DecoderUnwrapper: Decodable {
            let decoder: Decoder
            init (from decoder: Decoder) throws {
                self.decoder = decoder
            }
        }
        
        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            fatalError()
        }
        
        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
            guard case .blob (let blob) = self.data else {
                fatalError()
            }
            let data = blob.data()
            let unwrapper = try JSONDecoder().decode (DecoderUnwrapper.self, from: data)
            return try unwrapper.decoder.container (keyedBy: Key.self)
        }

        func singleValueContainer() throws -> SingleValueDecodingContainer {
            return _SingleValueDecoder (self)
        }
    }
    
    private struct _SingleValueDecoder: SingleValueDecodingContainer {
        var codingPath: [CodingKey] {
            return self.decoder.codingPath
        }
        let decoder: _Decoder
        init(_ decoder: _Decoder) {
            self.decoder = decoder
        }

        func decodeNil() -> Bool {
            return self.decoder.data == .null
        }

        func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
            return try _decode (T.self, decoder: self.decoder, data: self.decoder.data, codingPath: self.codingPath)
        }
    }
}

private func _decode<T> (_ type: T.Type, decoder: Decoder, data: FrontbaseData, codingPath: [CodingKey]) throws -> T where T: Decodable {
    if let type = type as? FrontbaseDataConvertible.Type {
        guard let decoded = type.init (frontbaseData: data) else {
            throw DecodingError.typeMismatch (T.self, DecodingError.Context.init (codingPath: codingPath, debugDescription: "Could not convert \(data) to \(T.self)"))
        }
        return decoded as! T
    } else {
        return try T.init (from: decoder)
    }
}

private struct DecoderUnwrapper: Decodable {
    let decoder: Decoder
    init (from decoder: Decoder) {
        self.decoder = decoder
    }
}
