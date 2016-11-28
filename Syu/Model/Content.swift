import Foundation
import Himotoki
import Mustache

struct Content {
    enum SyntaxType: String, CustomStringConvertible, MustacheBoxable {
        case globalVariable = "data"
        case typeAlias = "tdef"
        case function = "func"
        case enumeration = "enum"
        case enumerationCase = "enumelt"
        case structure = "struct"
        case `class` = "cl"
        case `protocol` = "intf"
        case instanceMethod = "instm"
        case instanceProperty = "instp"
        case typeMethod = "clm"
        case typeProperty = "structdata"
        case unknown

        var description: String {
            switch self {
            case .globalVariable:
                return "Global Variable"
            case .typeAlias:
                return "Type Alias"
            case .function:
                return "Function"
            case .enumeration:
                return "Enumeration"
            case .enumerationCase:
                return "Enumeration Case"
            case .structure:
                return "Structure"
            case .class:
                return "Class"
            case .protocol:
                return "Protocol"
            case .instanceMethod:
                return "Instance Method"
            case .instanceProperty:
                return "Instance Property"
            case .typeMethod:
                return "Type Method"
            case .typeProperty:
                return "Type Property"
            case .unknown:
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
            let name: String?
            let abstract: String?

            static func decode(_ e: Extractor) throws -> Symbol {
                return try Symbol(
                    title: e <| ["t", "x"],
                    name: e <|? "n",
                    abstract: e <|? ["a", "x"]
                )
            }

            var mustacheBox: MustacheBox {
                return Box([
                    "name": name ?? title,
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
    static let SyntaxTypeTransformer = Transformer<String?, SyntaxType> { string throws -> SyntaxType in
        guard let string = string else {
            return .unknown
        }

        if let type = SyntaxType(rawValue: string) {
            return type
        } else {
            print("unknown syntax type: \(string)")
            return .unknown
        }
    }

    static func decode(_ e: Extractor) throws -> Content {
        return try Content(
            syntaxType: SyntaxTypeTransformer.apply(e <|? "k"),
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
