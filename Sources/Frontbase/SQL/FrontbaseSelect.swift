/// Frontbase specific implementation of `SQLSelect`.
public struct FrontbaseSelect: SQLSelect {
    public typealias Distinct = FrontbaseDistinct
    public typealias SelectExpression = FrontbaseSelectExpression
    public typealias TableIdentifier = FrontbaseTableIdentifier
    public typealias Join = FrontbaseJoin
    public typealias Expression = FrontbaseExpression
    public typealias GroupBy = FrontbaseGroupBy
    public typealias OrderBy = FrontbaseOrderBy

    /// Convenience typealias for self.
    public typealias `Self` = FrontbaseSelect
    
    /// See `SQLSelect`.
    public var distinct: Distinct?
    
    /// See `SQLSelect`.
    public var columns: [SelectExpression]
    
    /// See `SQLSelect`.
    public var tables: [TableIdentifier]
    
    /// See `SQLSelect`.
    public var joins: [Join]
    
    /// See `SQLSelect`.
    public var predicate: Expression?
    
    /// See `SQLSelect`.
    public var groupBy: [GroupBy]
    
    /// See `SQLSelect`.
    public var orderBy: [OrderBy]
    
    /// See `SQLSelect`.
    public var limit: Int?
    
    /// See `SQLSelect`.
    public var offset: Int?
    
    /// See `SQLSelect`.
    public static func select() -> Self {
        return .init(distinct: nil, columns: [], tables: [], joins: [], predicate: nil, groupBy: [], orderBy: [], limit: nil, offset: nil)
    }
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        if tables.isEmpty {
            // Frontbase doesn’t handle SELECTs without tables,
            // but there is a VALUES statement that will handle
            // simpler cases
            sql.append("VALUES")
            sql.append(columns.serialize(&binds))
        } else {
            sql.append("SELECT")
            if let distinct = self.distinct {
                sql.append(distinct.serialize(&binds))
            }
            if let limit = self.limit, let offset = self.offset {
                sql.append("TOP(")
                sql.append(offset.description)
                sql.append(",")
                sql.append(limit.description)
                sql.append(")")
            } else if let limit = self.limit {
                sql.append("TOP(0,")
                sql.append(limit.description)
                sql.append(")")
            } else if let offset = self.offset {
                sql.append("TOP(")
                sql.append(offset.description)
                sql.append(",")
                sql.append(Int64.max.description)
                sql.append(")")
            }
            sql.append(columns.serialize(&binds))
            if !tables.isEmpty {
                sql.append("FROM")
                sql.append(tables.serialize(&binds))
            }
            if !joins.isEmpty {
                sql.append(joins.serialize(&binds, joinedBy: " "))
            }
            if let predicate = self.predicate {
                sql.append("WHERE")
                sql.append(predicate.serialize(&binds))
            }
            if !groupBy.isEmpty && !columns.contains (where: { $0.isAll }) {
                sql.append("GROUP BY")
                sql.append(groupBy.serialize(&binds))
            }
            if !orderBy.isEmpty {
                sql.append("ORDER BY")
                sql.append(orderBy.serialize(&binds))
            }
        }
        return sql.joined(separator: " ")
    }
}
