/// Represents an `ALTER TABLE ...` query.
public struct FrontbaseAlterTable: SQLAlterTable {
    /// See `SQLAlterTable`.
    public typealias ColumnDefinition = FrontbaseColumnDefinition
    
    /// See `SQLAlterTable`.
    public typealias TableIdentifier = FrontbaseTableIdentifier

    /// See `SQLAlterTable`.
    public static func alterTable(_ table: FrontbaseTableIdentifier) -> FrontbaseAlterTable {
        return .init(table: table, value: .rename(table))
    }

    /// Supported `ALTER TABLE` methods.
    public enum Value: SQLSerializable {
        /// Renames the table.
        case rename(FrontbaseTableIdentifier)

        /// Adds a new column to the table.
        case addColumn(FrontbaseColumnDefinition)

        /// See `SQLSerializable`.
        public func serialize(_ binds: inout [Encodable]) -> String {
            var sql: [String] = []
            switch self {
                case .rename(let name):
                    sql.append("RENAME TO")
                    sql.append(name.serialize(&binds))
                case .addColumn(let columnDefinition):
                    sql.append("ADD")
                    sql.append(columnDefinition.serialize(&binds))
            }
            return sql.joined(separator: " ")
        }
    }

    /// Name of table to alter.
    public var table: FrontbaseTableIdentifier

    /// Type of `ALTER` to perform.
    public var value: Value
    
    /// See `SQLAlterTable`.
    public var columns: [FrontbaseColumnDefinition] {
        get {
            switch value {
                case .addColumn(let col): return [col]
                default: return []
            }
        }
        set {
            switch newValue.count {
                case 1: value = .addColumn(newValue[0])
                default:
                    assertionFailure("Frontbase only supports adding one column during ALTER TABLE query.")
                    break
            }
        }
    }
    

    /// Creates a new `AlterTable`.
    ///
    /// - parameters:
    ///     - table: Name of table to alter.
    ///     - value: Type of `ALTER` to perform.
    public init(table: FrontbaseTableIdentifier, value: Value) {
        self.table = table
        self.value = value
    }

    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("ALTER TABLE")
        sql.append(table.serialize(&binds))
        sql.append(value.serialize(&binds))
        return sql.joined(separator: " ")
    }
}
