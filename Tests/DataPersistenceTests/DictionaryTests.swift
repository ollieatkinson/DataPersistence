import XCTest
@testable import DataPersistence

class DictionaryTests: XCTestCase {

    var sut: DataPersistence!

    override func setUp() {
        super.setUp()
        sut = [:]
    }

    let data = "data".data(using: .utf8)!

    func test_read() throws {
        let square = CGRect(origin: .zero, size: .init(width: 100, height: 100))
        try square.write(to: &sut, at: ["square"])
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

    func test_collection_subscript() {

        let expectations: [CodingPath] = [
            "a.", // ["a": ["": 1]]
            "a..", // ["a": ["": ["": 1]]]
            "a..b", // ["a": ["": ["b": 1]]]
            "a..b.", // ["a": ["": ["b": ["": 1]]]]
            "a..b..", // ["a": ["": ["b": ["": ["": 1]]]]]
            "a", // ["a": 1]
            "a.b", // ["a": ["b": 1]]
            "a.b.c", // ["a": ["b": ["c": 1]]]
            "[0]", // ["0": 1]
            "-0", // ["-0": 1]
            "[0]", // ["": [1]]
            ".[0]", // ["": [1]]
            "a[0]", // ["a": [1]]
            "a[0][0]", // ["a": [[1]]]
            "a[0][0][0]", // ["a": [[[1]]]]
            "a.b[0]", // ["a": ["b": [1]]]
            "a[0].b", // ["a": [["b": 1]]]
            "a[0].b[0]", // ["a": [["b": [1]]]]
            "2", // ["2": 1]
            "-2", // ["-2": 1]
            ".[2]", // ["": [<null>, <null>, 1]]
            ".-2", // ["": ["-2": 1]]
            ".[2].[2]", // ["": [<null>, <null>, [<null>, <null>, 1]]]
            "a[2]", // ["a": [<null>, <null>, 1]]
            "a[2].b", // ["a": [<null>, <null>, ["b": 1]]]
            "a[2].b[2]", // ["a": [<null>, <null>, ["b": [<null>, <null>, 1]]]]
        ]
        for path in expectations {
            var d: [String: Any] = [:]
            guard d[path] == nil else {
                XCTFail("Found a value in an empty dictionary at '\(path)': \(String(describing: d[path])).")
                continue
            }
            d[path] = 1
            guard d[path] as? Int == 1 else {
                XCTFail("Failed for path '\(path)'.")
                continue
            }
        }
    }

    func test_bidirectional_index() throws {

        let empty = [Any]()
        XCTAssertEqual(empty.bidirectionalIndex(4), 4)
        XCTAssertEqual(empty.bidirectionalIndex(10), 10)
        XCTAssertEqual(empty.bidirectionalIndex(11), 11)
        XCTAssertEqual(empty.bidirectionalIndex(-1), 0)

        let array1 = Array(0...5) as [Any]
        XCTAssertEqual(array1.count, 6)
        XCTAssertEqual(array1.bidirectionalIndex(5), 5)
        XCTAssertEqual(array1.bidirectionalIndex(-1), 5)

        let array2 = Array(0...10) as [Any]
        XCTAssertEqual(array2.count, 11)
        XCTAssertEqual(array2.bidirectionalIndex(4), 4)
        XCTAssertEqual(array2.bidirectionalIndex(9), 9)
        XCTAssertEqual(array2.bidirectionalIndex(10), 10)
    }
}
