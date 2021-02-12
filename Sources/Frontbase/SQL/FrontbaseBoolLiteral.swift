/// Frontbase specific `SQLBoolLiteral`.
public enum FrontbaseBoolLiteral: SQLBoolLiteral {
    /// See `SQLBoolLiteral`.
    public static var `true`: FrontbaseBoolLiteral {
        return ._true
    }
    
    /// See `SQLBoolLiteral`.
    public static var `false`: FrontbaseBoolLiteral {
        return ._false
    }
    
    /// See `SQLBoolLiteral`.
    case _true
    
    /// See `SQLBoolLiteral`.
    case _false
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
            case ._false: return "FALSE"
            case ._true: return "TRUE"
        }
    }
}
