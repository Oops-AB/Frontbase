@available(macOS 12, *)
extension FrontbaseConnection {

    public func structure (sql query: SQLExpression) async throws -> [StructureColumn] {
        var serializer = SQLSerializer (database: self)
        query.serialize (to: &serializer)
        let binds: [FrontbaseData]

        binds = try serializer.binds.map { encodable in
            return try FrontbaseDataEncoder().encode (encodable)
        }

        return try await self.structure (serializer.sql, binds)
    }
}
