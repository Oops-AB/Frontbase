/// Frontbase specific `SQLDefaultLiteral`.
public struct FrontbaseDefaultLiteral: SQLDefaultLiteral {
    /// See `SQLDefaultLiteral`.
    public static var `default`: FrontbaseDefaultLiteral {
        return self.init()
    }
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return "DEFAULT"
    }
}
