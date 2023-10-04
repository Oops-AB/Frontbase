import Logging
import Frontbase
import NIO
import SQLKitBenchmark
import XCTest

class FrontbaseTests: XCTestCase {
    func testPlanets() throws {
        try self.db.create(table: "galaxies")
            .column("id", type: .int, .primaryKey)
            .column("name", type: .custom (SQLRaw ("VARCHAR (1000)")))
            .run().wait()
        try self.db.create(table: "planets")
            .column("id", type: .int, .primaryKey)
            .column("galaxyID", type: .int, .references("galaxies", "id"))
            .run().wait()
        try self.db.alter(table: "planets")
            .column("name", type: .custom (SQLRaw ("VARCHAR (1000)")), .default(SQLLiteral.string("Unamed Planet")))
            .run().wait()
        try self.db.create(index: "test_index")
            .on("planets")
            .column("id")
            .column("name")
            .unique()
            .run().wait()
        // INSERT INTO "galaxies" ("id", "name") VALUES (DEFAULT, $1)
        try self.db.insert(into: "galaxies")
            .columns("id", "name")
            .values(SQLLiteral.default, SQLBind("Milky Way"))
            .values(SQLLiteral.default, SQLBind("Andromeda"))
            // .value(Galaxy(name: "Milky Way"))
            .run().wait()
        // SELECT * FROM galaxies WHERE name IS NOT NULL AND (name == ? OR name == ?)
        _ = try self.db.select()
            .column("*")
            .from("galaxies")
            .where("name", .isNot, SQLLiteral.null)
            .where {
                $0.where("name", .equal, SQLBind("Milky Way"))
                    .orWhere("name", .equal, SQLBind("Andromeda"))
            }
            .all().wait()

        _ = try self.db.select()
            .column("*")
            .from("galaxies")
            .where(SQLColumn("name"), .equal, SQLBind("Milky Way"))
            .orderBy("name", .descending)
            .all().wait()

        try self.db.insert(into: "planets")
            .columns("id", "name")
            .values(SQLLiteral.default, SQLBind("Earth"))
            .run().wait()

        try self.db.insert(into: "planets")
            .columns("id", "name")
            .values(SQLLiteral.default, SQLBind("Mercury"))
            .values(SQLLiteral.default, SQLBind("Venus"))
            .values(SQLLiteral.default, SQLBind("Mars"))
            .values(SQLLiteral.default, SQLBind("Jpuiter"))
            .values(SQLLiteral.default, SQLBind("Pluto"))
            .run().wait()

        try self.db.select()
            .column(SQLFunction("count", args: "name"))
            .from("planets")
            .where("galaxyID", .equal, SQLBind(5))
            .run().wait()

        try self.db.select()
            .column(SQLFunction("count", args: SQLLiteral.all))
            .from("planets")
            .where("galaxyID", .equal, SQLBind(5))
            .run().wait()
    }

    struct Moon: Decodable {
        let name: String
        let cheese: String?
        let radius: Decimal?
    }

    func testNull() throws {
        try self.db.create (table: "moons")
            .column ("id", type: .int, .primaryKey)
            .column ("name", type: .custom (SQLRaw ("VARCHAR (1000)")))
            .column ("cheese", type: .custom (SQLRaw ("VARCHAR (100)")))
            .run().wait()
        try self.db.insert (into: "moons")
            .columns ("id", "name", "cheese")
            .values (SQLLiteral.default, SQLBind ("Luna"), SQLBind ("Roquefort"))
            .values (SQLLiteral.default, SQLBind ("Phobos"), SQLLiteral.null)
            .run().wait()
        let moons = try self.db.select()
            .column ("*")
            .from ("moons")
            .orderBy ("name", .ascending)
            .all (decoding: Moon.self)
            .wait()
        XCTAssertEqual (moons.count, 2)
        XCTAssertEqual (moons[0].name, "Luna")
        XCTAssertEqual (moons[0].cheese, "Roquefort")
        XCTAssertEqual (moons[1].name, "Phobos")
        XCTAssertEqual (moons[1].cheese, nil)
    }

    func testDecimal() throws {
        try self.db.create (table: "moons")
            .column ("id", type: .int, .primaryKey)
            .column ("name", type: .custom (SQLRaw ("VARCHAR (1000)")))
            .column ("radius", type: .custom (SQLRaw ("DECIMAL (10, 4)")))
            .run().wait()
        try self.db.insert (into: "moons")
            .columns ("id", "name", "radius")
            .values (SQLLiteral.default, SQLBind ("Luna"), SQLBind (Decimal (1737.4)))
            .values (SQLLiteral.default, SQLBind ("Phobos"), SQLBind (Decimal (11.2667)))
            .run().wait()
        let moons = try self.db.select()
            .column ("*")
            .from ("moons")
            .orderBy ("name", .ascending)
            .all (decoding: Moon.self)
            .wait()
        XCTAssertEqual (moons.count, 2)
        XCTAssertEqual (moons[0].name, "Luna")
        XCTAssertEqual (moons[0].radius, 1737.4)
        XCTAssertEqual (moons[1].name, "Phobos")
        XCTAssertEqual (moons[1].radius, 11.2667)
    }

    var db: SQLDatabase {
        self.connection.sql()
    }
    var benchmark: SQLBenchmarker {
        .init(on: self.db)
    }
    
    var eventLoopGroup: EventLoopGroup!
    var threadPool: NIOThreadPool!
    var database: TestDatabase!
    var connection: FrontbaseConnection!

    override func setUp() {
        XCTAssertTrue(isLoggingConfigured)
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)
        self.threadPool = NIOThreadPool(numberOfThreads: 2)
        self.threadPool.start()
        do {
            let database = try FrontbaseConnection.makeNetworkedDatabase()
            self.database = database
        } catch {
            print ("FrontbaseTests.setUp() failed with \(error)")
            return
        }
        self.connection = try! FrontbaseConnectionSource(
            configuration: .init(storage: self.database.storage),
            threadPool: self.threadPool
        ).makeConnection(logger: .init(label: "se.oops.frontbase.test"), on: self.eventLoopGroup.next()).wait()
    }

    override func tearDown() {
        try! self.connection.close().wait()
        self.connection = nil
        self.database.destroyTest()
        self.database = nil
        try! self.threadPool.syncShutdownGracefully()
        self.threadPool = nil
        try! self.eventLoopGroup.syncShutdownGracefully()
        self.eventLoopGroup = nil
    }
}

let isLoggingConfigured: Bool = {
    LoggingSystem.bootstrap { label in
        var handler = StreamLogHandler.standardOutput(label: label)
        handler.logLevel = .trace
        return handler
    }
    return true
}()
