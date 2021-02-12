/// Column in a Frontbase result set.
public struct FrontbaseColumn {
    /// The table name.
    public var table: String?

    /// The columns string name.
    public var name: String

    /// Create a new Frontbase column from the name.
    public init(table: String? = nil, name: String) {
        self.table = table
        self.name = name
    }
}

extension Dictionary where Key == FrontbaseColumn {
    /// Returns the first matching value for a `FrontbaseColumn` in a dictionary.
    public func firstValue(forColumn name: String, inTable table: String? = nil) -> Value? {
        for (col, val) in self {
            if (col.table == nil || table == nil || col.table == table) && col.name == name {
                return val
            }
        }
        return nil
    }
}

extension FrontbaseColumn: ExpressibleByStringLiteral {
    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.init(name: value)
    }
}

extension FrontbaseColumn: Hashable {
    /// See `Hashable`.
    public func hash (into hasher: inout Hasher) {
        if let table = table {
            hasher.combine (table)
        }
        hasher.combine (name)
    }
}


extension FrontbaseColumn: Equatable {
    /// See `Equatable`.
    public static func == (lhs: FrontbaseColumn, rhs: FrontbaseColumn) -> Bool {
        return lhs.table == rhs.table && lhs.name == rhs.name
    }
}

extension FrontbaseColumn: CustomStringConvertible {
    /// See `CustomStringConvertible`.
    public var description: String {
        if let table = table {
            return table + "." + name
        } else {
            return name
        }
    }
}
