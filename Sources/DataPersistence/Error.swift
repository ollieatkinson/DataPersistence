//
//  Util.swift
//  
//
//  Created by Oliver Atkinson on 15/04/2021.
//

extension String {

    func error(_ function: String = #function, _ file: String = #file, _ line: Int = #line) -> DataPersistenceError {
        .init(.description(self), function, file, line)
    }
}

public struct DataPersistenceError: Error {

    let message: Message
    let function: String
    let file: String
    let line: Int

    public enum Message {
        case doesNotExist(CodingPath)
        case typeMismatch(expected: Any.Type, actual: Any.Type)
        case description(String)
    }

    init(_ message: Message, _ function: String = #function, _ file: String = #file, _ line: Int = #line) {
        self.message = message
        self.function = function
        self.file = file
        self.line = line
    }
}
