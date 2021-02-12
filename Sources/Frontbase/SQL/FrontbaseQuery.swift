/// Frontbase specific `SQLQuery`.
public enum FrontbaseQuery: SQLQuery {
    /// See `SQLQuery`.
    public typealias AlterTable = FrontbaseAlterTable
    
    /// See `SQLQuery`.
    public typealias CreateIndex = FrontbaseCreateIndex

    /// See `SQLQuery`.
    public typealias CreateTable = FrontbaseCreateTable

    /// See `SQLQuery`.
    public typealias Delete = FrontbaseDelete

    /// See `SQLQuery`.
    public typealias DropIndex = FrontbaseDropIndex
    
    /// See `SQLQuery`.
    public typealias DropTable = FrontbaseDropTable

    /// See `SQLQuery`.
    public typealias Insert = FrontbaseInsert

    /// See `SQLQuery`.
    public typealias Select = FrontbaseSelect

    /// See `SQLQuery`.
    public typealias Update = FrontbaseUpdate

    /// See `SQLQuery`.
    public typealias RowDecoder = FrontbaseRowDecoder

    /// See `SQLQuery`.
    public static func alterTable(_ alterTable: FrontbaseAlterTable) -> FrontbaseQuery {
        return ._alterTable(alterTable)
    }
    
    /// See `SQLQuery`.
    public static func createIndex(_ createIndex: FrontbaseCreateIndex) -> FrontbaseQuery {
        return ._createIndex(createIndex)
    }

    /// See `SQLQuery`.
    public static func createTable(_ createTable: FrontbaseCreateTable) -> FrontbaseQuery {
        return ._createTable(createTable)
    }
    
    /// See `SQLQuery`.
    public static func delete(_ delete: FrontbaseDelete) -> FrontbaseQuery {
        return ._delete(delete)
    }
    
    /// See `SQLQuery`.
    public static func dropIndex(_ dropIndex: FrontbaseDropIndex) -> FrontbaseQuery {
        return ._dropIndex(dropIndex)
    }
    
    /// See `SQLQuery`.
    public static func dropTable(_ dropTable: FrontbaseDropTable) -> FrontbaseQuery {
        return ._dropTable(dropTable)
    }
    
    /// See `SQLQuery`.
    public static func insert(_ insert: FrontbaseInsert) -> FrontbaseQuery {
        return ._insert(insert)
    }
    
    /// See `SQLQuery`.
    public static func select(_ select: FrontbaseSelect) -> FrontbaseQuery {
        return ._select(select)
    }
    
    /// See `SQLQuery`.
    public static func update(_ update: FrontbaseUpdate) -> FrontbaseQuery {
        return ._update(update)
    }

    /// See `SQLQuery`.
    public static func raw(_ sql: String, binds: [Encodable]) -> FrontbaseQuery {
        return ._raw(sql, binds)
    }

    /// See `SQLQuery`.
    case _alterTable(FrontbaseAlterTable)
    
    /// See `SQLQuery`.
    case _createIndex(FrontbaseCreateIndex)

    /// See `SQLQuery`.
    case _createTable(FrontbaseCreateTable)
    
    /// See `SQLQuery`.
    case _delete(FrontbaseDelete)
    
    /// See `SQLQuery`.
    case _dropIndex(FrontbaseDropIndex)
    
    /// See `SQLQuery`.
    case _dropTable(FrontbaseDropTable)
    
    /// See `SQLQuery`.
    case _insert(FrontbaseInsert)
    
    /// See `SQLQuery`.
    case _select(FrontbaseSelect)
    
    /// See `SQLQuery`.
    case _update(FrontbaseUpdate)
    
    /// See `SQLQuery`.
    case _raw(String, [Encodable])

    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
            case ._alterTable(let alterTable): return alterTable.serialize(&binds)
            case ._createIndex(let createIndex): return createIndex.serialize(&binds)
            case ._createTable(let createTable): return createTable.serialize(&binds)
            case ._delete(let delete): return delete.serialize(&binds)
            case ._dropIndex(let dropIndex): return dropIndex.serialize(&binds)
            case ._dropTable(let dropTable): return dropTable.serialize(&binds)
            case ._insert(let insert): return insert.serialize(&binds)
            case ._select(let select): return select.serialize(&binds)
            case ._update(let update): return update.serialize(&binds)
            case ._raw(let sql, let values):
                binds = values
                return sql
        }
    }
}

extension FrontbaseQuery: ExpressibleByStringLiteral {
    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self = ._raw(value, [])
    }
}
