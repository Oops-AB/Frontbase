/// Frontbase specific `SQLDropTable`.
public struct FrontbaseDropTable: SQLDropTable
{
    /// See `SQLDropTable`.
    public static func dropTable(_ table: FrontbaseTableIdentifier) -> FrontbaseDropTable {
        return .init(table: table, ifExists: false, action: GenericSQLForeignKeyAction.restrict)
    }
    
    /// See `SQLDropTable`.
    public var table: FrontbaseTableIdentifier
    
    /// See `SQLDropTable`.
    public var ifExists: Bool

    // Actions top perform on foreign keys when dropping table
    public var action: GenericSQLForeignKeyAction

    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("DROP TABLE")
        sql.append(table.serialize(&binds))
        sql.append(action.serialize(&binds))
        return sql.joined(separator: " ")
    }
}
