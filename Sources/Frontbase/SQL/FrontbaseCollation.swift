/// Frontbase specific `SQLCollation`.
public enum FrontbaseCollation: SQLCollation {
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return "X"
    }
}
