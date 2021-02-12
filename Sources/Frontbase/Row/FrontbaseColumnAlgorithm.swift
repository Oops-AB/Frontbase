public enum FrontbaseColumnConstraintAlgorithm: SQLColumnConstraintAlgorithm {
    public typealias Expression = FrontbaseExpression
    public typealias Collation = FrontbaseCollation
    public typealias PrimaryKeyDefault = FrontbasePrimaryKeyDefault
    public typealias ForeignKey = FrontbaseForeignKey

    /// Convenience typealias for self.
    public typealias `Self` = FrontbaseColumnConstraintAlgorithm
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func primaryKey(_ `default`: PrimaryKeyDefault?) -> Self {
        return ._primaryKey(`default`)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static var notNull: Self {
        return ._notNull
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static var unique: Self {
        return ._unique
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func check(_ expression: Expression) -> Self {
        return ._check(expression)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func collate(_ collation: Collation) -> Self {
        return ._collate(collation)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func `default`(_ expression: Expression) -> Self {
        return ._default(expression)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func foreignKey(_ foreignKey: ForeignKey) -> Self {
        return ._foreignKey(foreignKey)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    case _primaryKey(PrimaryKeyDefault?)
    
    /// See `SQLColumnConstraintAlgorithm`.
    case _notNull
    
    /// See `SQLColumnConstraintAlgorithm`.
    case _unique
    
    /// See `SQLColumnConstraintAlgorithm`.
    case _check(Expression)
    
    /// See `SQLColumnConstraintAlgorithm`.
    case _collate(Collation)
    
    /// See `SQLColumnConstraintAlgorithm`.
    case _default(Expression)
    
    /// See `SQLColumnConstraintAlgorithm`.
    case _foreignKey(ForeignKey)
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
            case ._primaryKey(let `default`):
                if let d = `default` {
                    return d.serialize(&binds) + " PRIMARY KEY"
                } else {
                    return "PRIMARY KEY"
                }
            case ._notNull: return "NOT NULL"
            case ._unique: return "UNIQUE"
            case ._check(let expression):
                return "CHECK (" + expression.serialize(&binds) + ")"
            case ._collate(let collation):
                return "COLLATE " + collation.serialize(&binds)
            case ._default(let expression):
                return "DEFAULT " + expression.serialize(&binds)
            case ._foreignKey(let foreignKey): return "REFERENCES " + foreignKey.serialize(&binds)
        }
    }

}

extension FrontbaseColumnConstraintAlgorithm: Comparable {

    var weight: Int32 {
        switch self {
            case ._primaryKey: return 4
            case ._notNull: return 3
            case ._unique: return 2
            case ._check: return 5
            case ._collate: return 6
            case ._default: return 1
            case ._foreignKey: return 7
        }
    }
    
    public static func == (lhs: FrontbaseColumnConstraintAlgorithm, rhs: FrontbaseColumnConstraintAlgorithm) -> Bool {
        return lhs.weight == rhs.weight
    }

    public static func < (lhs: FrontbaseColumnConstraintAlgorithm, rhs: FrontbaseColumnConstraintAlgorithm) -> Bool {
        return !(lhs == rhs) && (lhs.weight < rhs.weight)
    }
}
