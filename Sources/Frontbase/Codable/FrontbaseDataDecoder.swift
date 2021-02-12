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
    public func decode<D>(_ type: D.Type, from data: FrontbaseData) throws -> D where D: Decodable {
        if let convertible = type as? FrontbaseDataConvertible.Type {
            return try convertible.convertFromFrontbaseData(data) as! D
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
            init(from decoder: Decoder) throws {
                self.decoder = decoder
            }
        }
        
        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
            return try jsonDecoder().container(keyedBy: Key.self)
        }
        
        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            return try jsonDecoder().unkeyedContainer()
        }
        
        private func jsonDecoder() throws -> Decoder {
            let json: Data
            switch data {
                case .blob(let data): json = data.data()
                case .text(let string): json = Data(string.utf8)
                default: throw FrontbaseError(problem: .error, reason: "Could not decode json.", source: .capture())
            }
            let unwrapper = try JSONDecoder().decode(DecoderUnwrapper.self, from: json)
            return unwrapper.decoder
        }
        
        func singleValueContainer() throws -> SingleValueDecodingContainer {
            return _SingleValueDecodingContainer(data: data)
        }
    }
    
    private struct _SingleValueDecodingContainer: SingleValueDecodingContainer {
        let codingPath: [CodingKey] = []
        let data: FrontbaseData
        
        init(data: FrontbaseData) {
            self.data = data
        }
        
        public func decodeNil() -> Bool {
            switch data {
                case .null: return true
                default: return false
            }
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
            guard let convertible = type as? FrontbaseDataConvertible.Type else {
                return try T(from: _Decoder(data: data))
            }
            return try convertible.convertFromFrontbaseData(data) as! T
        }
    }
}
