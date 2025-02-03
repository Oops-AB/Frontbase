//
//  FrontbaseRow+SQLRow.swift
//  
//
//  Created by Johan Carlberg on 2019-10-09.
//

extension FrontbaseRow: @retroactive SQLRow {

    public func contains (column: String) -> Bool {
        return self.column (column) != nil
    }

    public func decode<D> (column: String, as type: D.Type) throws -> D where D : Decodable {
        guard let data = self.column (column) else {
            let context = DecodingError.Context (codingPath: [], debugDescription: "No value found for column \(column)")
            throw DecodingError.valueNotFound (type, context)
        }
        do {
            return try FrontbaseDataDecoder().decode (D.self, from: data)
        } catch FrontbaseDataDecoder.FrontbaseDataError.inconvertible {
            let context = DecodingError.Context (codingPath: [], debugDescription: "Value not convertible (\(column))")
            throw DecodingError.typeMismatch (type, context)
        }
    }

    public func decodeNil (column: String) throws -> Bool {
        if let data = self.column (column) {
            return data == .null
        } else {
            return true
        }
    }
}
