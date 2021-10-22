import XCTest
@testable import DataPersistence

class FileManagerTests: XCTestCase {

    var sut: DataPersistenceObject!

    override func setUp() {
        super.setUp()
        sut = FileManager.default
    }

    let data = "data".data(using: .utf8)!

    func test_read() throws {
        let square = CGRect(origin: .zero, size: .init(width: 100, height: 100))
        try square.write(to: sut, at: ["square"])
        XCTAssertEqual(try CGRect.read(from: sut, at: "square"), square)
    }

    func test_write() throws {
        try sut.write(data, to: ["path", "to", "data"])
        try XCTAssertEqual("data", XCTUnwrap(String(data: sut.read(at: ["path", "to", "data"]), encoding: .utf8)))
    }

    func test_delete() throws {
        try sut.write(data, to: "data")
        XCTAssertNoThrow(try sut.read(at: "data"))
        try sut.delete(at: "data")
        XCTAssertThrowsError(try sut.read(at: "data"))
    }
}
