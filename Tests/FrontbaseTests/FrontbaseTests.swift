import Frontbase
import SQLBenchmark
import XCTest
import MemoryTools

class FrontbaseTests: XCTestCase {
    func testBenchmark() throws {
        let conn = try FrontbaseConnection.makeFilebasedTest(); defer { conn.destroyFilebasedTest() }
        let benchmarker = SQLBenchmarker(on: conn)
        try benchmarker.run()
    }
    
    func testVersion() throws {
        let conn = try FrontbaseConnection.makeFilebasedTest(); defer { conn.destroyFilebasedTest() }
        
        let res = try conn.query("VALUES server_name;").wait()
        print(res)
    }

    func testVersionBuild() throws {
        let conn = try FrontbaseConnection.makeFilebasedTest(); defer { conn.destroyFilebasedTest() }

        let res = try conn.select()
            .column(.function("server_name", []))
            .all().wait()
        print(res)
    }

    func testTables() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        _ = try database.query("CREATE TABLE foo (bar INT, baz VARCHAR(16), biz FLOAT)").wait()
        _ = try database.query("INSERT INTO foo VALUES (42, 'Life', 0.44)").wait()
        _ = try database.query("INSERT INTO foo VALUES (1337, 'Elite', 209.234)").wait()
        _ = try database.query("INSERT INTO foo VALUES (9, NULL, 34.567)").wait()
        
        if let resultBar = try database.query("SELECT * FROM foo WHERE bar = 42").wait().first {
            XCTAssertEqual(resultBar.firstValue(forColumn: "bar"), .integer(42))
            XCTAssertEqual(resultBar.firstValue(forColumn: "baz"), .text("Life"))
            XCTAssertEqual(resultBar.firstValue(forColumn: "biz"), .float(0.44))
        } else {
            XCTFail("Could not get bar result")
        }


        if let resultBaz = try database.query("SELECT * FROM foo where baz = 'Elite'").wait().first {
            XCTAssertEqual(resultBaz.firstValue(forColumn: "bar"), .integer(1_337))
            XCTAssertEqual(resultBaz.firstValue(forColumn: "baz"), .text("Elite"))
        } else {
            XCTFail("Could not get baz result")
        }

        if let resultBaz = try database.query("SELECT * FROM foo where bar = 9").wait().first {
            XCTAssertEqual(resultBaz.firstValue(forColumn: "bar"), .integer(9))
            XCTAssertEqual(resultBaz.firstValue(forColumn: "baz"), .null)
        } else {
            XCTFail("Could not get null result")
        }
    }

    func testUnicode() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        /// This string includes characters from most Unicode categories
        /// such as Latin, Latin-Extended-A/B, Cyrrilic, Greek etc.
        let unicode = "®¿ÐØ×ĞƋƢǂǊǕǮȐȘȢȱȵẀˍΔῴЖ♆"
        _ = try database.query("CREATE TABLE \"foo\" (bar CHARACTER VARYING (1000))").wait()

        _ = try database.raw("INSERT INTO \"foo\" VALUES(?)").bind(unicode).run().wait()
        let selectAllResults = try database.query("SELECT * FROM \"foo\"").wait().first
        XCTAssertNotNil(selectAllResults)
        XCTAssertEqual(selectAllResults!.firstValue(forColumn: "bar"), .text(unicode))

        let selectWhereResults = try database.raw("SELECT * FROM \"foo\" WHERE bar = '\(unicode)'").all().wait().first
        XCTAssertNotNil(selectWhereResults)
        XCTAssertEqual(selectWhereResults!.firstValue(forColumn: "bar"), .text(unicode))
    }

    func testTinyInts() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let max = Int8.max

        _ = try database.query ("CREATE TABLE foo (\"max\" TINYINT)").wait()
        _ = try database.raw ("INSERT INTO foo VALUES (?)").bind (max).run().wait()

        if let result = try! database.query ("SELECT * FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "max"), FrontbaseData.integer (Int64 (max)))
        }
    }

    func testSmallInts() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let max = Int16.max

        _ = try database.query ("CREATE TABLE foo (\"max\" SMALLINT)").wait()
        _ = try database.raw ("INSERT INTO foo VALUES (?)").bind (max).run().wait()

        if let result = try! database.query ("SELECT * FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "max"), FrontbaseData.integer (Int64 (max)))
        }
    }

    func testInts() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let max = Int32.max

        _ = try database.query ("CREATE TABLE foo (\"max\" INTEGER)").wait()
        _ = try database.raw ("INSERT INTO foo VALUES (?)").bind (max).run().wait()

        if let result = try! database.query ("SELECT * FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "max"), FrontbaseData.integer (Int64 (max)))
        }
    }

    func testLongInts() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let max = Int64.max

        _ = try database.query ("CREATE TABLE foo (\"max\" LONGINT)").wait()
        _ = try database.raw ("INSERT INTO foo VALUES (?)").bind (max).run().wait()

        if let result = try! database.query ("SELECT * FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "max"), FrontbaseData.integer (max))
        }
    }

    func testDecimals() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let max = 42000000.0
        let min = 1.23

        _ = try database.query ("CREATE TABLE foo (\"max\" DECIMAL, \"min\" DECIMAL (30, 3))").wait()
        _ = try database.raw ("INSERT INTO foo VALUES (?, ?)").binds ([max, min]).run().wait()

        if let result = try! database.query ("SELECT * FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "max"), FrontbaseData.float (max))
            XCTAssertEqual (result.firstValue (forColumn: "min"), FrontbaseData.float (min))
        }
    }

    func testNumerics() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let max = 42000000.0
        let min = 1.23
        
        _ = try database.query ("CREATE TABLE foo (\"max\" NUMERIC, \"min\" NUMERIC (10, 3))").wait()
        _ = try database.raw ("INSERT INTO foo VALUES (?, ?)").binds ([max, min]).run().wait()
        
        if let result = try! database.query ("SELECT * FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "max"), FrontbaseData.float (max))
            XCTAssertEqual (result.firstValue (forColumn: "min"), FrontbaseData.float (min))
        }
    }

    func testFloats() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let max = 42000000.0
        let min = 1.23
        
        _ = try database.query ("CREATE TABLE foo (\"max\" FLOAT, \"min\" FLOAT)").wait()
        _ = try database.raw ("INSERT INTO foo VALUES (?, ?)").binds ([max, min]).run().wait()
        
        if let result = try! database.query ("SELECT * FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "max"), FrontbaseData.float (max))
            XCTAssertEqual (result.firstValue (forColumn: "min"), FrontbaseData.float (min))
        }
    }

    func testReals() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let max = 42000000.0
        let min = 1.23
        
        _ = try database.query ("CREATE TABLE foo (\"max\" REAL, \"min\" REAL)").wait()
        _ = try database.raw ("INSERT INTO foo VALUES (?, ?)").binds ([max, min]).run().wait()
        
        if let result = try! database.query ("SELECT * FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "max"), FrontbaseData.float (max))
            XCTAssertEqual (result.firstValue (forColumn: "min"), FrontbaseData.float (min))
        }
    }

    func testDoubles() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let max = 42000000.0
        let min = 1.23
        
        _ = try database.query ("CREATE TABLE foo (\"max\" DOUBLE PRECISION, \"min\" DOUBLE PRECISION)").wait()
        _ = try database.raw ("INSERT INTO foo VALUES (?, ?)").binds ([max, min]).run().wait()
        
        if let result = try! database.query ("SELECT * FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "max"), FrontbaseData.float (max))
            XCTAssertEqual (result.firstValue (forColumn: "min"), FrontbaseData.float (min))
        }
    }

    func testCharacters() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let string = "The lazy dog jumps of over the quick fox"
        
        _ = try database.query ("CREATE TABLE foo (\"string\" CHARACTER (100))").wait()
        _ = try database.raw ("INSERT INTO foo VALUES (?)").bind (string).run().wait()
        
        if let result = try! database.query ("SELECT * FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "string"), FrontbaseData.text (string))
        }
    }

    func testBooleans() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let value = true
        
        _ = try database.query ("CREATE TABLE foo (\"value\" BOOLEAN)").wait()
        _ = try database.raw ("INSERT INTO foo VALUES (?)").bind (value).run().wait()
        
        if let result = try! database.query ("SELECT * FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "value"), FrontbaseData.boolean (value))
        }
    }

    func testBlobs() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let data = Data ([0, 1, 2])

        _ = try database.query("CREATE TABLE foo (bar BLOB)").wait()
        _ = try database.raw("INSERT INTO foo VALUES (?)").bind(data).run().wait()

        if let result = try database.query("SELECT * FROM foo").wait().first {
            XCTAssertEqual(result.firstValue (forColumn: "bar")?.blobData, data)
        } else {
            XCTFail()
        }
    }

    func testTimestamps() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let timestamp = Date()

        _ = try database.query("CREATE TABLE foo (bar TIMESTAMP)").wait()
        _ = try database.raw("INSERT INTO foo VALUES (?)").bind (timestamp).run().wait()

        if let result = try database.query("SELECT * FROM foo").wait().first {
            XCTAssert (abs ((result.firstValue (forColumn: "bar")?.timestampDate?.timeIntervalSinceReferenceDate ?? Double.infinity) - timestamp.timeIntervalSinceReferenceDate) < 0.001)
        } else {
            XCTFail()
        }
    }

    func testTimeZones() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let timestamp = Date()

        FrontbaseData.timeZone = TimeZone (abbreviation: "UTC")
        _ = try database.query("CREATE TABLE foo (bar TIMESTAMP)").wait()
        _ = try database.raw("INSERT INTO foo VALUES (?)").bind (timestamp).run().wait()

        if let result = try database.query("SELECT * FROM foo").wait().first {
            XCTAssert (abs ((result.firstValue (forColumn: "bar")?.timestampDate?.timeIntervalSinceReferenceDate ?? Double.infinity) - timestamp.timeIntervalSinceReferenceDate) < 0.001)
        } else {
            XCTFail()
        }
    }

    func testBits() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let bits: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 124, 125, 126, 127]
        let bitz: [UInt8] = [0x94, 0x71, 0xF1, 0xD9, 0x24, 0x59, 0xD6, 0x51, 0x56, 0x15]

        _ = try database.query("CREATE TABLE foo (bar BIT (96), baz BIT VARYING (80))").wait()
        _ = try database.raw("INSERT INTO foo VALUES (?, ?)").binds ([ bits, bitz ]).run().wait()

        if let result = try database.query("SELECT * FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "bar"), FrontbaseData.bits (bits))
            XCTAssertEqual (result.firstValue (forColumn: "baz"), FrontbaseData.bits (bitz))
        } else {
            XCTFail()
        }
    }

    func testBit96() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let bits = Bit96 (bits: (0, 1, 2, 3, 4, 5, 6, 7, 124, 125, 126, 127))
        let bitz = Bit96 (bits: (0x94, 0x71, 0xF1, 0xD9, 0x24, 0x59, 0xD6, 0x51, 0x56, 0x15, 0x83, 0x1E))
        
        _ = try database.query("CREATE TABLE foo (bar BIT (96), baz BIT (96))").wait()
        _ = try database.raw("INSERT INTO foo VALUES (?, ?)").binds ([ bits, bitz ]).run().wait()
        
        if let result = try database.query("SELECT * FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "bar"), FrontbaseData.bits ([UInt8] (bits)))
            XCTAssertEqual (result.firstValue (forColumn: "baz"), FrontbaseData.bits ([UInt8] (bitz)))
        } else {
            XCTFail()
        }
    }

    func testIntervals() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let interval = TimeInterval (900.0)
        let start = Date()
        let end = start.addingTimeInterval (interval)
        
        _ = try database.query ("CREATE TABLE foo (\"start\" TIMESTAMP, \"end\" TIMESTAMP)").wait()
        _ = try database.raw ("INSERT INTO foo VALUES (?, ?)").binds ([ start, end ]).run().wait()
        
        if let result = try! database.query ("SELECT \"end\" - \"start\" AS \"timespan\" FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "timespan"), FrontbaseData.float (interval))
        }
    }

    func testError() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        do {
            _ = try database.query("asdf").wait()
            XCTFail("Should have errored")
        } catch let error as FrontbaseError {
            print(error)
            XCTAssert(error.reason.contains("Syntax error"))
        } catch {
            XCTFail("wrong error")
        }
    }

    func testDecodeSameColumnName() throws {
        let row: [FrontbaseColumn: FrontbaseData] = [
            FrontbaseColumn(table: "foo", name: "id"): .text("foo"),
            FrontbaseColumn(table: "bar", name: "id"): .text("bar"),
        ]
        struct User: Decodable {
            var id: String
        }
        try XCTAssertEqual(FrontbaseRowDecoder().decode(User.self, from: row, table: "foo").id, "foo")
        try XCTAssertEqual(FrontbaseRowDecoder().decode(User.self, from: row, table: "bar").id, "bar")
    }

    func testMultiThreading() throws {
        let db = try FrontbaseConnection.makeNetworkedDatabase(); defer { FrontbaseConnection.destroyNetworkedTest (database: db) }
        let elg = MultiThreadedEventLoopGroup(numberOfThreads: 2)
        let a = elg.next()
        let b = elg.next()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            let conn = try! db.newConnection (on: a).wait()
            for i in 0 ..< 100 {
                print("a \(i)")
                let res = try! conn.query("VALUES (1 + 1);").wait()
                print(res)
            }
            conn.close()
            group.leave()
        }
        group.enter()
        DispatchQueue.global().async {
            let conn = try! db.newConnection (on: b).wait()
            for i in 0 ..< 100 {
                print("b \(i)")
                let res = try! conn.query("VALUES (1 + 1);").wait()
                print(res)
            }
            conn.close()
            group.leave()
        }
        group.wait()
    }

    func testSingleThreading() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let string1 = "The lazy dog jumps of over the quick fox"
        let string2 = "Mauris ac est et nulla luctus vehicula sit amet vel justo"

        _ = try database.query ("CREATE TABLE foo (\"string\" CHARACTER (100))").wait()
        _ = try database.raw ("INSERT INTO foo VALUES (?)").bind (string1).run().wait()
        _ = try database.query ("CREATE TABLE bar (\"string\" CHARACTER (100))").wait()
        _ = try database.raw ("INSERT INTO bar VALUES (?)").bind (string2).run().wait()

        let (foo, bar) = try! database.query ("SELECT * FROM foo")
            .and (database.query ("SELECT * FROM bar"))
            .wait()
        XCTAssertEqual (foo.first!.firstValue (forColumn: "string"), FrontbaseData.text (string1))
        XCTAssertEqual (bar.first!.firstValue (forColumn: "string"), FrontbaseData.text (string2))
    }

    func testNonEmptyArrayEncodingDecoding() throws {
        let nonEmptyArray = ["foo", "bar"]
        let encoder = FrontbaseDataEncoder()
        
        let data = try encoder.encode(nonEmptyArray)
        
        let decoder = FrontbaseDataDecoder()
        
        let result = try decoder.decode([String].self, from: data)
        XCTAssertEqual(result, nonEmptyArray, "Should convert back to original array")
    }
    
    func testEmptyArrayEncodingDecoding() throws {
        let emptyArray = [String]()
        let encoder = FrontbaseDataEncoder()
        
        let data = try encoder.encode(emptyArray)
        
        let decoder = FrontbaseDataDecoder()
        
        let result = try decoder.decode([String].self, from: data)
        XCTAssertEqual(result, emptyArray, "Should convert back to empty Array")
    }

    func testAnyType() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let values: [Encodable] = [
            true,
            37,
            3.1415926535898,
            "Kilroy was here!"
        ]

        _ = try database.query ("CREATE TABLE foo (bar ANY TYPE)").wait()
        for value in values {
            _ = try database.raw ("INSERT INTO foo VALUES (?)").bind (value).run().wait()
        }

        let results: [[FrontbaseColumn: FrontbaseData]] = try database.query ("SELECT index, bar FROM foo ORDER BY 1").wait()
        var index = 0
        for result in results {
            if let value = values[index] as? FrontbaseDataConvertible {
                XCTAssertEqual (result.firstValue (forColumn: "bar"), try value.convertToFrontbaseData())
            }
            index += 1
        }
    }

    func testTransactions() throws {
        let database = try FrontbaseConnection.makeFilebasedTest(); defer { database.destroyFilebasedTest() }
        let string = "Lorem ipsum set dolor mit amet"

        _ = try database.query ("CREATE TABLE foo (\"string\" CHARACTER (100))").wait()

        _ = try database.raw ("INSERT INTO foo VALUES (?)").bind (string).run().wait()
        _ = try database.raw ("ROLLBACK").run().wait()
        if let result = try! database.query ("SELECT COUNT (*) AS counter, MIN (string) AS value FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "counter"), FrontbaseData.float (1.0))
            XCTAssertEqual (result.firstValue (forColumn: "value"), FrontbaseData.text (string))
        }

        database.autoCommit = false
        _ = try database.raw ("INSERT INTO foo VALUES (?)").bind ("Sed euismod lacus a magna aliquam").run().wait()
        _ = try database.raw ("ROLLBACK").run().wait()
        if let result = try! database.query ("SELECT COUNT (*) AS counter, MIN (string) AS value FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "counter"), FrontbaseData.float (1.0))
            XCTAssertEqual (result.firstValue (forColumn: "value"), FrontbaseData.text (string))
        }
        _ = try database.raw ("INSERT INTO foo VALUES (?)").bind ("Donec eget sollicitudin odio").run().wait()
        _ = try database.raw ("COMMIT").run().wait()
        if let result = try! database.query ("SELECT COUNT (*) AS counter, MIN (string) AS value FROM foo").wait().first {
            XCTAssertEqual (result.firstValue (forColumn: "counter"), FrontbaseData.float (2.0))
            XCTAssertEqual (result.firstValue (forColumn: "value"), FrontbaseData.text ("Donec eget sollicitudin odio"))
        }
    }

    func testAllocation() throws {
        let database = try FrontbaseConnection.makeFilebasedTest();
        let before = getMemoryUsed()
        let string = "Lorem ipsum set dolor mit amet"

        database.logger = nil
        _ = try database.query ("CREATE TABLE foo (\"string\" CHARACTER (100))").wait()
        _ = try database.raw ("INSERT INTO foo VALUES (?)").bind (string).run().wait()
        _ = try database.raw ("COMMIT").run().wait()

        for _ in 1...10000 {
            if let result = try! database.query ("SELECT COUNT (*) AS counter, MIN (string) AS value FROM foo").wait().first {
                XCTAssertEqual (result.firstValue (forColumn: "counter"), FrontbaseData.float (1.0))
                XCTAssertEqual (result.firstValue (forColumn: "value"), FrontbaseData.text (string))
            }
        }
        database.destroyFilebasedTest()
        let after = getMemoryUsed()
        let used = after > before ? after - before : 0

        XCTAssertLessThan (used, 500000)
    }

    static let allTests = [
        ("testBenchmark", testBenchmark),
        ("testVersion", testVersion),
        ("testVersionBuild", testVersionBuild),
        ("testTables", testTables),
        ("testUnicode", testUnicode),
        ("testTinyInts", testTinyInts),
        ("testSmallInts", testSmallInts),
        ("testInts", testInts),
        ("testLongInts", testLongInts),
        ("testDecimals", testDecimals),
        ("testNumerics", testNumerics),
        ("testFloats", testFloats),
        ("testReals", testReals),
        ("testDoubles", testDoubles),
        ("testCharacters", testCharacters),
        ("testBooleans", testBooleans),
        ("testBlobs", testBlobs),
        ("testTimestamps", testTimestamps),
        ("testTimeZones", testTimeZones),
        ("testBits", testBits),
        ("testBit96", testBit96),
        ("testBits", testBits),
        ("testIntervals", testIntervals),
        ("testError", testError),
        ("testDecodeSameColumnName", testDecodeSameColumnName),
        ("testMultiThreading", testMultiThreading),
        ("testSingleThreading", testSingleThreading),
        ("testNonEmptyArrayEncodingDecoding", testNonEmptyArrayEncodingDecoding),
        ("testEmptyArrayEncodingDecoding", testEmptyArrayEncodingDecoding),
        ("testAnyType", testAnyType),
        ("testTransactions", testTransactions),
        ("testAllocation", testAllocation)
    ]
}
