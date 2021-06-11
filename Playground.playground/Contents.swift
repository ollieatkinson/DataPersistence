import Foundation
import DataPersistence


struct Example {
    
    @Persisted(
        in: UserDefaults.standard,
        at: "int",
        default: 0
    )
    var defaults: Int
    
    @Persisted(
        in: FileManager["~/.data-persistence"],
        at: "int",
        default: 0
    )
    var file: Int
    
    @Persisted(
        in: [:],
        at: 0, 1, "a", 2, "int",
        default: 0
    )
    var dictionary: Int
    
    @Persisted(
        at: 0, 1, "a", 2, "int",
        default: 0
    )
    var choose: Int
    
    var storage: [String: Any] = [:]
    
    @Persisted(
        in: \Example.storage,
        at: 0, 1, "a", 2, "int",
        default: 0
    )
    var stored: Int
    
}


var example = Example()

example.defaults
example.defaults += 1

example.file
example.file += 1

example.dictionary
example.dictionary += 1
print(example.$dictionary.persistence)

example.$choose.persistence = UserDefaults.standard
