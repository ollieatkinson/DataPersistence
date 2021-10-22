//
//  Util.swift
//  
//
//  Created by Oliver Atkinson on 15/04/2021.
//

extension String {
    
    func error(_ function: String = #function, _ file: String = #file, _ line: Int = #line) -> Error {
        .init(self, function, file, line)
    }
    
    struct Error: Swift.Error {
        
        let message: String
        let function: String
        let file: String
        let line: Int
        
        init(_ message: String, _ function: String = #function, _ file: String = #file, _ line: Int = #line) {
            self.message = message
            self.function = function
            self.file = file
            self.line = line
        }
    }
}
