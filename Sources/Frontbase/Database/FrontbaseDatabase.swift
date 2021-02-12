import CFrontbaseSupport

/// An open Frontbase database using in-memory or file-based storage.
///
///     let frontbaseDB = FrontbaseDatabase(storage: .memory)
///
/// Use this database to create new connections for executing queries.
///
///     let conn = try frontbaseDB.newConnection(on: ...).wait()
///     try conn.query("VALUES server_name;").wait()
///
public final class FrontbaseDatabase: Database, LogSupporting {
    /// Internal Frontbase database parameters.
    internal let databaseName: String

    internal let filePath: String?

    internal let hostName: String?

    internal let databasePassword: String?

    internal let username: String

    internal let password: String

    internal var defaultSessionName: String

    public enum SessionMode {
        public enum LockingMode: String {
            case pessimistic = "PESSIMISTIC"
            case optimistic = "OPTIMISTIC"
            case deferred = "DEFERRED"
        }

        public enum AccessMode: String {
            case readWrite = "READ WRITE"
            case readOnly = "READ ONLY"
        }

        case serializable (LockingMode, AccessMode)
        case repeatableRead (LockingMode, AccessMode)
        case readCommitted (LockingMode, AccessMode)
        case versioned (LockingMode, AccessMode)

        var sql: String {
            switch (self) {
                case .serializable (let lockingMode, let accessMode):
                    return "SET TRANSACTION ISOLATION LEVEL SERIALIZABLE, LOCKING \(lockingMode.rawValue), \(accessMode.rawValue);"

                case .repeatableRead (let lockingMode, let accessMode):
                    return "SET TRANSACTION ISOLATION LEVEL REPEATABLE READ, LOCKING \(lockingMode.rawValue), \(accessMode.rawValue);"

                case .readCommitted (let lockingMode, let accessMode):
                    return "SET TRANSACTION ISOLATION LEVEL READ COMMITTED, LOCKING \(lockingMode.rawValue), \(accessMode.rawValue);"

                case .versioned (let lockingMode, let accessMode):
                    return "SET TRANSACTION ISOLATION LEVEL VERSIONED, LOCKING \(lockingMode.rawValue), \(accessMode.rawValue);"
            }
        }
    }

    public var sessionMode: SessionMode

    public init (name: String, pathName: String, username: String, password: String, databasePassword: String? = nil, defaultMode: SessionMode = .serializable (.pessimistic, .readWrite)) {
        self.databaseName = name
        self.filePath = pathName
        self.hostName = nil
        self.databasePassword = databasePassword
        self.username = username
        self.password = password
        self.defaultSessionName = ProcessInfo.processInfo.processName
        self.sessionMode = defaultMode
    }

    public init (name: String, onHost hostName: String, username: String, password: String, databasePassword: String? = nil, defaultMode: SessionMode = .serializable (.pessimistic, .readWrite)) {
        self.databaseName = name
        self.filePath = nil
        self.hostName = hostName
        self.databasePassword = databasePassword
        self.username = username
        self.password = password
        self.defaultSessionName = ProcessInfo.processInfo.processName
        self.sessionMode = defaultMode
    }

    /// See `Database`.
    public func newConnection (on worker: Worker) -> Future<FrontbaseConnection> {
        do {
            let conn = try FrontbaseConnection (database: self, on: worker)
            return worker.future (conn)
        } catch {
            return worker.future (error: error)
        }
    }

    /// See `LogSupporting`.
    public static func enableLogging (_ logger: DatabaseLogger, on conn: FrontbaseConnection) {
        conn.logger = logger
    }

    internal func openConnection() throws -> FBSConnection {
        var errorMessage: UnsafePointer<Int8>? = nil
        var databaseConnection: FBSConnection?
        let dbPassword = { () -> String in
            if let password = self.databasePassword {
                return password
            } else {
                return ""
            }
        }()

        if let hostName = hostName {
            databaseConnection = withUnsafeMutablePointer (to: &errorMessage) { (errorMessagePointer: UnsafeMutablePointer<UnsafePointer<Int8>?>) -> FBSConnection? in
                return fbsConnectDatabaseOnHost (databaseName, hostName, dbPassword, username.uppercased(), password, defaultSessionName, ProcessInfo.processInfo.environment["USER"], errorMessagePointer)
            }
        } else if let filePath = filePath {
            databaseConnection = withUnsafeMutablePointer (to: &errorMessage) { (errorMessagePointer: UnsafeMutablePointer<UnsafePointer<Int8>?>) -> FBSConnection? in
                return fbsConnectDatabaseAtPath (databaseName, filePath, dbPassword, username.uppercased(), password, defaultSessionName, ProcessInfo.processInfo.environment["USER"], errorMessagePointer)
            }
        }

        guard let connection = databaseConnection else {
            throw FrontbaseError (problem: .error, reason: "Could not open database.", source: .capture())
        }

        if let message = errorMessage {
            throw FrontbaseError (problem: .error, reason: "Could not open database (\(message)).", source: .capture())
        }

        let result = withUnsafeMutablePointer (to: &errorMessage) { (errorMessagePointer: UnsafeMutablePointer<UnsafePointer<Int8>?>) -> FBSResult? in
            return fbsExecuteSQL (connection, sessionMode.sql, true, errorMessagePointer)
        }
        defer {
            fbsCloseResult (result)
        }

        if let message = errorMessage {
            throw FrontbaseError (problem: .error, reason: "Could set transaction isolation level on new connection (\(message)).", source: .capture())
        }

        return connection
    }

    public func withDefaultSessionName (_ sessionName: String) -> Self {
        self.defaultSessionName = sessionName

        return self
    }
}
