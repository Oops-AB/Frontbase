/// Frontbase specific implementation of `SQLColumnDefinition`.
public struct FrontbaseColumnDefinition: SQLColumnDefinition
{
    public typealias ColumnIdentifier = FrontbaseColumnIdentifier
    public typealias DataType = FrontbaseDataType
    public typealias ColumnConstraint = FrontbaseColumnConstraint

    /// Convenience alias for self.
    public typealias `Self` = FrontbaseColumnDefinition

    /// See `SQLColumnDefinition`.
    public static func columnDefinition(_ column: ColumnIdentifier, _ dataType: DataType, _ constraints: [ColumnConstraint]) -> Self {
        return .init(column: column, dataType: dataType, constraints: constraints)
    }

    /// See `SQLColumnDefinition`.
    public var column: ColumnIdentifier

    /// See `SQLColumnDefinition`.
    public var dataType: DataType

    /// See `SQLColumnDefinition`.
    public var constraints: [ColumnConstraint]

    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append(column.identifier.serialize(&binds))
        sql.append(dataType.serialize(&binds))
        sql.append(constraints.sorted().serialize(&binds, joinedBy: " "))
        return sql.joined(separator: " ")
    }
}
