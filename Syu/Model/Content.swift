import Foundation
import Himotoki
import Mustache

struct Content {
    enum SyntaxType: String, CustomStringConvertible, MustacheBoxable {
        case `class` = "cl"
        case function = "func"
        case instanceMethod = "instm"
        case typeAlias = "tdef"
        case unknown

        var description: String {
            switch self {
            case .class:
                return "Class"
            case .function:
                return "Function"
            case .instanceMethod:
                return "Instance Method"
            case .typeAlias:
                return "Type Alias"
            default:
                return "Unknown"
            }
        }

        var mustacheBox: MustacheBox {
            return Box(self.description)
        }
    }

    struct Section: Decodable, MustacheBoxable {
        struct Symbol: Decodable, MustacheBoxable {
            let title: String
            let abstract: String?

            static func decode(_ e: Extractor) throws -> Symbol {
                return try Symbol(
                    title: e <| ["t", "x"],
                    abstract: e <|? ["a", "x"]
                )
            }

            var mustacheBox: MustacheBox {
                return Box([
                    "title": title,
                    "abstract": abstract ?? ""
                ])
            }
        }

        let title: String
        let symbols: [Symbol]?

        static func decode(_ e: Extractor) throws -> Section {
            return try Section(
                title: e <| ["t", "x"],
                symbols: e <||? ["s"]
            )
        }

        var mustacheBox: MustacheBox {
            return Box([
                "title": title,
                "symbols": symbols ?? []
            ])
        }
    }

    let syntaxType: SyntaxType
    let name: String
    let abstract: String?
    let overview: String?
    let sections: [Section]?
}

extension Content: Decodable {
    static let SyntaxTypeTransformer = Transformer<String, SyntaxType> { string throws -> SyntaxType in
        if let type = SyntaxType(rawValue: string) {
            return type
        } else {
            print("unknown syntax type: \(string)")
            return .unknown
        }
    }

    static func decode(_ e: Extractor) throws -> Content {
        return try Content(
            syntaxType: SyntaxTypeTransformer.apply(e <| "k"),
            name: e <| ["t", "x"],
            abstract: e <|? ["a", "x"],
            overview: e <|? ["o", "x"],
            sections: e <||? "c"
        )
    }
}

extension Content: MustacheBoxable {
    var mustacheBox: MustacheBox {
        return Box([
            "syntaxType": syntaxType,
            "name": name,
            "abstract": abstract ?? "",
            "overview": overview ?? "",
            "sections": sections ?? []
        ])
    }
}
