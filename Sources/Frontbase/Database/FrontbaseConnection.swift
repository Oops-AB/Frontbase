import CFrontbaseSupport

/// A connection to a Frontbase database, created by `FrontbaseDatabase`.
///
///     let conn = try frontbaseDB.newConnection(on: ...).wait()
///
/// Use this connection to execute queries on the database.
///
///     try conn.query("VALUES server_name;").wait()
///
/// You can also build queries, using the available query builders.
///
///     let res = try conn.select()
///         .column(function: "server_name", as: "version")
///         .run().wait()
///
public final class FrontbaseConnection: BasicWorker, DatabaseConnection, DatabaseQueryable, SQLConnection {
    /// See `DatabaseConnection`.
    public typealias Database = FrontbaseDatabase

    /// See `DatabaseConnection`.
    public var isClosed: Bool {
        return connection == nil
    }

    /// See `DatabaseConnection`.
    public var extend: Extend

    /// Optional logger, if set queries should be logged to it.
    public var logger: DatabaseLogger?

    /// Reference to parent `FrontbaseDatabase` that created this connection.
    /// This reference will ensure the DB stays alive since this connection uses
    /// it's C pointer handle.
    internal let database: FrontbaseDatabase

    /// Open database connection
    internal var connection: FBSConnection?

    /// See `BasicWorker`.
    public let eventLoop: EventLoop

    /// Thread pool for performing blocking IO work. See `BlockingIOThreadPool`.
    internal let blockingIO: BlockingIOThreadPool

    /// When set to true, will execute statements with the auto commit flag set
    public var autoCommit = true

    /// Create a new Frontbase connection.
    internal init (database: FrontbaseDatabase, on worker: Worker) throws {
        self.extend = [:]
        self.database = database
        self.connection = try database.openConnection()
        self.eventLoop = worker.eventLoop
        self.blockingIO = BlockingIOThreadPool (numberOfThreads: 1)
        self.blockingIO.start()
    }

    deinit {
        close()
    }

    /// Returns the last error message, if one exists.
    internal var errorMessage: String? {
        guard let connection = connection else {
            return nil
        }
        return String (cString: fbsErrorMessage (connection))
    }
    
    /// See `SQLConnection`.
    public func decode<D>(_ type: D.Type,
                          from row: [FrontbaseColumn: FrontbaseData],
                          table: GenericSQLTableIdentifier<FrontbaseIdentifier>?) throws -> D where D: Decodable {
        return try FrontbaseRowDecoder().decode(D.self, from: row, table: table)
    }

    /// Executes the supplied `FrontbaseQuery` on the connection, calling the supplied closure for each row returned.
    ///
    ///     try conn.query("SELECT * FROM users") { row in
    ///         print(row)
    ///     }.wait()
    ///
    /// - parameters:
    ///     - query: `FrontbaseQuery` to execute.
    ///     - onRow: Callback for handling each row.
    /// - returns: A `Future` that signals completion of the query.
    public func query (_ query: FrontbaseQuery, _ onRow: @escaping ([FrontbaseColumn: FrontbaseData]) throws -> ()) -> Future<Void> {
        var binds: [Encodable] = []
        let sql = query.serialize (&binds)
        let promise = eventLoop.newPromise (Void.self)
        let data = try! binds.map { try FrontbaseDataEncoder().encode ($0) }
        // log before anything happens, in case there's an error
        logger?.record (query: sql, values: data.map { $0.description })
        blockingIO.submit { state in
            do {
                let statement = try FrontbaseStatement (query: sql, on: self)
                try statement.bind (data)
                try statement.executeQuery()
                guard self.connection != nil else {
                    return promise.fail (error: FrontbaseError (problem: .error, reason: "Connection has closed", source: .capture()))
                }
                while let row = try statement.nextRow() {
                    do {
                        try onRow (row)
                    } catch {
                        promise.fail (error: error)
                    }
                }
                return promise.succeed (result: ())
            } catch {
                return promise.fail (error: error)
            }
        }
        return promise.futureResult
    }
    
    /// See `DatabaseConnection`.
    public func close() {
        if let databaseConnection = connection {
            fbsCloseConnection (databaseConnection)
            connection = nil
        }
    }

    internal func blob (handle: String, size: UInt32) -> Data {
        return Data (bytes: fbsGetBlobData (connection, handle), count: Int (size))
    }

    internal func blob (data: Data) throws -> (String, FBSBlob) {
        return try data.withUnsafeBytes { bytes in
            if let blobHandle = fbsCreateBlobHandle (bytes.baseAddress, UInt32 (data.count), self.connection) {
                let handleString = String (cString: fbsGetBlobHandleString (blobHandle))

                return (handleString, blobHandle)
            } else {
                throw BlobError.createFailed
            }
        }
    }

    internal func release (blob: FBSBlob) {
        fbsReleaseBlobHandle (blob)
    }

    public func withTransaction<R> (_ closure: @escaping (_ connection: FrontbaseConnection) throws -> Future<R>) -> Future<R> {
        return self.raw ("VALUES 0")
            .run()
            .flatMap { (Void) throws -> Future<R> in
                guard self.autoCommit == true else {
                    throw FrontbaseError (problem: .openTransaction, reason: "A transaction is already in progress", source: .capture())
                }

                do {
                    self.autoCommit = false
                    return try closure (self)
                } catch {
                    self.autoCommit = true
                    throw error
                }
            }
            .flatMap { (result: R) throws -> Future<R> in
                self.autoCommit = true
                return self.raw ("COMMIT")
                    .run()
                    .map {
                        return result
                    }
            }
            .catchFlatMap { error in
                return self.raw ("ROLLBACK")
                    .run()
                    .map {
                        self.autoCommit = true
                        throw error
                    }
            }
    }
}
