/// Frontbase specific `SQLBind`.
public struct FrontbaseBind: SQLBind {
    /// See `SQLBind`.
    public static func encodable<E>(_ value: E) -> FrontbaseBind
        where E: Encodable
    {
        if let expr = value as? FrontbaseQueryExpressionRepresentable {
            return self.init(value: .expression(expr.frontbaseQueryExpression))
        } else {
            return self.init(value: .encodable(value))
        }
    }
    
    /// Supported bind values.
    public enum Value {
        /// A sub-expression.
        case expression(FrontbaseExpression)
        
        /// Encodable value.
        case encodable(Encodable)
    }
    
    /// Bind value.
    public var value: Value
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch value {
            case .expression(let expr): return expr.serialize(&binds)
            case .encodable(let value):
                binds.append(value)
                return "?"
        }
    }
}
