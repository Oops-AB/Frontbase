extension SQLCreateTableBuilder where Connectable.Connection.Query.CreateTable == FrontbaseCreateTable {
    /// By default, every row in Frontbase has a special column, usually called the "rowid", that uniquely identifies that row within
    /// the table. However if the phrase "WITHOUT ROWID" is added to the end of a CREATE TABLE statement, then the special "rowid"
    /// column is omitted. There are sometimes space and performance advantages to omitting the rowid.
    ///
    /// https://www.sqlite.org/withoutrowid.html
    public func withoutRowID() -> Self {
        createTable.withoutRowID = true
        return self
    }
}

/// The `CREATE TABLE` command is used to create a new table in an Frontbase database.
///
public struct FrontbaseCreateTable: SQLCreateTable {
    /// See `SQLCreateTable`.
    public static func createTable(_ table: FrontbaseTableIdentifier) -> FrontbaseCreateTable {
        return .init(createTable: .createTable(table), withoutRowID: false)
    }
    
    /// See `SQLCreateTable`.
    public var createTable: GenericSQLCreateTable<
        FrontbaseTableIdentifier, FrontbaseColumnDefinition, FrontbaseTableConstraint
    >
    
    
    /// See `SQLCreateTable`.
    public var temporary: Bool {
        get { return createTable.temporary }
        set { return createTable.temporary = newValue }
    }
    
    /// See `SQLCreateTable`.
    public var ifNotExists: Bool {
        get { return createTable.ifNotExists }
        set { return createTable.ifNotExists = false }
    }
    
    /// See `SQLCreateTable`.
    public var table: FrontbaseTableIdentifier {
        get { return createTable.table }
        set { return createTable.table = newValue }
    }
    
    /// See `SQLCreateTable`.
    public var columns: [FrontbaseColumnDefinition] {
        get { return createTable.columns }
        set { return createTable.columns = newValue }
    }
    
    /// See `SQLCreateTable`.
    public var tableConstraints: [FrontbaseTableConstraint] {
        get { return createTable.tableConstraints }
        set { return createTable.tableConstraints = newValue }
    }
    
    /// By default, every row in Frontbase has a special column, usually called the "rowid", that uniquely identifies that row within
    /// the table. However if the phrase "WITHOUT ROWID" is added to the end of a CREATE TABLE statement, then the special "rowid"
    /// column is omitted. There are sometimes space and performance advantages to omitting the rowid.
    ///
    /// https://www.sqlite.org/withoutrowid.html
    public var withoutRowID: Bool
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append(createTable.serialize(&binds))
        if withoutRowID {
            sql.append("WITHOUT ROWID")
        }
        return sql.joined(separator: " ") + "; SET UNIQUE=0 FOR " + table.serialize(&binds)
    }
}
