import Combine
import XCTest
@testable import DataPersistence

class PersistedTests: XCTestCase {

    static var store: StringAnyDataPersistenceObject = .init()
    var store: StringAnyDataPersistenceObject {
        get { PersistedTests.store }
        set { PersistedTests.store = newValue }
    }

    var bag: Set<AnyCancellable> = []

    @Persisted(
        in: PersistedTests.store,
        at: "value", "string",
        default: "default"
    )
    var string: String

    func test_persisted() throws {

        XCTAssertEqual(string, "default")
        XCTAssertThrowsError(try store.read(at: "value", "string"))

        string = "Dorothy"
        XCTAssertEqual(try store.read(at: "value", "string"), "\"Dorothy\"".data(using: .utf8))

        XCTAssertEqual(string, "Dorothy")
    }

    @Persisted(
        in: PersistedTests.store,
        at: "value", "stream",
        default: "default"
    )
    var stream: String

    func test_stream() throws {

        let error = expectation(description: #function)
        $stream
            .on.error
            .sink{ _ in error.fulfill() }
            .store(in: &bag)

        let read = expectation(description: #function)
        read.expectedFulfillmentCount = 2 // read & delete
        $stream
            .on.read
            .sink{ _ in read.fulfill() }
            .store(in: &bag)

        let write = expectation(description: #function)
        $stream
            .on.write
            .sink{ _ in write.fulfill() }
            .store(in: &bag)

        let delete = expectation(description: #function)
        $stream
            .on.delete
            .sink{ _ in delete.fulfill() }
            .store(in: &bag)

        // Error, because no value exists
        XCTAssertEqual(stream, "default")
        XCTAssertThrowsError(try store.read(at: "value", "stream"))

        // write
        stream = "Dorothy"
        XCTAssertEqual(try store.read(at: "value", "stream"), "\"Dorothy\"".data(using: .utf8))

        // read
        XCTAssertEqual(stream, "Dorothy")

        // delete (and an additional read to send the oldValue)
        $stream.delete()

        waitForExpectations(timeout: 0.1)
    }

    @Persisted(
        in: PersistedTests.store,
        at: "maybe", "string"
    )
    var optional: String?

    func test_nullable() throws {

        XCTAssertNil(optional)
        XCTAssertThrowsError(try store.read(at: "maybe", "string"))

        optional = "ø"
        XCTAssertEqual(optional, "ø")
        XCTAssertEqual(try store.read(at: "maybe", "string"), "\"ø\"".data(using: .utf8))

        optional = nil
        XCTAssertNil(optional)
        XCTAssertEqual(try store.read(at: "maybe", "string"), "null".data(using: .utf8))

        $optional.delete()
        XCTAssertNil(optional)
        XCTAssertThrowsError(try store.read(at: "maybe", "string"))

    }
}
