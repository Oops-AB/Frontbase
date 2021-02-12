/// Frontbase specific `SQLFunction`.
public struct FrontbaseFunction: SQLFunction {
    /// See `SQLFunction`.
    public typealias Argument = GenericSQLFunctionArgument<FrontbaseExpression>
    
    /// `COUNT(*)`.
    public static var count: FrontbaseFunction {
        return .init(name: "COUNT", arguments: [.all])
    }
    
    /// See `SQLFunction`.
    public static func function(_ name: String, _ args: [Argument]) -> FrontbaseFunction {
        return .init(name: name, arguments: args)
    }
    
    /// See `SQLFunction`.
    public let name: String
    
    /// See `SQLFunction`.
    public let arguments: [Argument]
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        if arguments.isEmpty {
            return name
        } else {
            return name + "(" + arguments.map { $0.serialize(&binds) }.joined(separator: ", ") + ")"
        }
    }
}

extension SQLSelectExpression where Expression.Function == FrontbaseFunction, Identifier == FrontbaseIdentifier {
    /// `COUNT(*) as ...`.
    public static func count(as alias: FrontbaseIdentifier? = nil) -> Self {
        return .expression(.function(.count), alias: alias)
    }
}
