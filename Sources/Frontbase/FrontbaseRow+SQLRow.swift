//
//  FrontbaseRow+SQLRow.swift
//  
//
//  Created by Johan Carlberg on 2019-10-09.
//

extension FrontbaseRow: SQLRow {

    public func contains (column: String) -> Bool {
        return self.column (column) != nil
    }

    public func decode<D> (column: String, as type: D.Type) throws -> D where D : Decodable {
        guard let data = self.column (column) else {
            fatalError("no value found for \(column)")
        }
        return try FrontbaseDataDecoder().decode (D.self, from: data)
    }

    public func decodeNil (column: String) throws -> Bool {
        if let data = self.column (column) {
            return data == .null
        } else {
            return true
        }
    }
}
