import CFrontbaseSupport
import Dispatch
import NIO
@testable import FrontbaseNIO
import XCTest

enum UtilitiesError: Error {
    case noTemporaryDirectory
}

struct TestDatabase {
    let storage: FrontbaseConnection.Storage
    let threadPool: NIOThreadPool

    internal init (name: String) {
        threadPool = NIOThreadPool (numberOfThreads: 1)
        fbsCreateDatabaseWithUrl ("frontbase://localhost/\(name)")
        fbsStartDatabaseWithUrl ("frontbase://localhost/\(name)")
        storage = .named (name: name, hostName: "localhost", username: "_system", password: "")
    }

    internal func newConnection (on eventLoop: EventLoop) throws -> FrontbaseConnection {
        return try FrontbaseConnection.open (storage: storage, threadPool: threadPool, logger: .init (label: "FrontbaseTests"), on: eventLoop).wait()
    }

    internal func destroyTest() {
        switch self.storage {
            case .named (let name, let hostName, _, _, _, _):
                fbsDeleteDatabaseWithUrl ("frontbase://\(hostName)/\(name)")

            default:
                print ("This was unexpected")
        }
    }
}

extension FrontbaseConnection {
    /// Create a temporary in-process, file-based database and create the complete schema defined in DatabaseDefinition.
    ///
    /// - Parameter name: A string used as part of the filename of the database file.
    /// - Returns: A tuple with an open `FrontbaseConnection`,
    ///   the `MultiThreadedEventLoopGroup` that the connection run on,
    ///   and a `FrontbaseConnection.Storage` that can be used to open new connections to the same database.
    ///
    ///   The event loop group should be properly shutdown after the last connection has been closed.
    public static func makeFilebasedTest (name: String) async throws -> (FrontbaseConnection, MultiThreadedEventLoopGroup, FrontbaseConnection.Storage) {
        let group = MultiThreadedEventLoopGroup (numberOfThreads: 1)
        let threadPool = NIOThreadPool (numberOfThreads: 1)
        let storage = FrontbaseConnection.Storage.file (name: name, pathName: try temporaryDirectory (template: "/tmp/\(name)-XXXXXXXXXX") + "/database.fb", username: "_system", password: "", databasePassword: "")
        let conn = try await FrontbaseConnection.open (storage: storage, threadPool: threadPool, logger: .init (label: name), on: group.next())
            .get()

        return (conn, group, storage)
    }

    func destroyTest() {
        do {
            try close().wait()
        } catch {
            print ("Failed to close database: \(error)")
        }

        switch self.storage {
            case .named (let name, let hostName, _, _, _, _):
                fbsDeleteDatabaseWithUrl ("frontbase://\(hostName)/\(name)")

            case .port (let hostName, let port, _, _, _, _):
                fbsDeleteDatabaseWithUrl ("frontbase://\(hostName):\(port)")

            case.file (_, let pathName, _, _, _, _):
                if let endIndex = pathName.lastIndex (of: "/") {
                    let path = String (pathName[pathName.startIndex ..< endIndex])
                    do {
                        try FileManager.default.removeItem (atPath: path)
                    } catch {
                        print ("Unable to delete directory at \(path): \(error)")
                    }
            }
        }
    }

    static func makeNetworkedDatabase() throws -> TestDatabase {
        return TestDatabase (name: try temporaryDatabaseName (template: "FrontbaseTests-XXXXXXXXXX"))
    }

    static func temporaryDatabaseName (template: String) throws -> String {
        return template
    }

    static func temporaryDirectory (template: String) throws -> String {
        if let templatePointer = template.cString (using: .utf8) {
            let buffer = UnsafeMutablePointer<Int8>.allocate (capacity: templatePointer.count)

            buffer.update (from: templatePointer, count: templatePointer.count)
            if let result = mkdtemp (buffer) {
                return String (cString: result)
            }
        }

        throw UtilitiesError.noTemporaryDirectory
    }
}

extension FrontbaseData {
    var blobData: Data? {
        switch (self) {
            case .blob (let blob):
                return try? blob.data()

            default:
                return nil
        }
    }

    var timestampDate: Date? {
        switch (self) {
            case .timestamp (let timestamp):
                return timestamp

            default:
                return nil
        }
    }
}
