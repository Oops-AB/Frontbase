/// Frontbase specific `SQLDropIndex`.
public struct FrontbaseDropIndex: SQLDropIndex {
    /// See `SQLDropIndex`.
    public var identifier: FrontbaseIdentifier
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("DROP INDEX")
        sql.append(identifier.serialize(&binds))
        return sql.joined(separator: " ")
    }
}

/// Frontbase specific drop index builder.
public final class FrontbaseDropIndexBuilder<Connectable>: SQLQueryBuilder
where Connectable: SQLConnectable, Connectable.Connection.Query == FrontbaseQuery
{
    /// `AlterTable` query being built.
    public var dropIndex: FrontbaseDropIndex
    
    /// See `SQLQueryBuilder`.
    public var connectable: Connectable
    
    /// See `SQLQueryBuilder`.
    public var query: FrontbaseQuery {
        return .dropIndex(dropIndex)
    }
    
    /// Creates a new `SQLCreateIndexBuilder`.
    public init(_ dropIndex: FrontbaseDropIndex, on connectable: Connectable) {
        self.dropIndex = dropIndex
        self.connectable = connectable
    }
}


extension SQLConnectable where Connection.Query == FrontbaseQuery {
    /// Drops an index from a Frontbase database.
    public func drop(index identifier: FrontbaseIdentifier) -> FrontbaseDropIndexBuilder<Self> {
        return .init(FrontbaseDropIndex(identifier: identifier), on: self)
    }
}
