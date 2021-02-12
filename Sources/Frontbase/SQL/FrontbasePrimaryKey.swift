/// Frontbase specific `SQLPrimaryKeyDefault`.
public enum FrontbasePrimaryKeyDefault: SQLPrimaryKeyDefault {
    /// See `SQLPrimaryKey`.
    public static var `default`: FrontbasePrimaryKeyDefault {
        return .autoIncrement
    }
    
    /// Default. Uses ROWID as default primary key.
    case rowID
    
    case autoIncrement

    case uid

    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
            case .rowID: return ""
            case .autoIncrement: return "DEFAULT UNIQUE"
            case .uid: return "DEFAULT NEW_UID"
        }
    }
}
