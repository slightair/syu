import Foundation
import Compression
import SQLite
import Mustache
import Himotoki

struct ResponseData {
    fileprivate let jsonObject: [String: Any]

    var content: Content? {
        return try? decodeValue(jsonObject)
    }

    init(data: Data) {
        if let object = try? JSONSerialization.jsonObject(with: data), let jsonObject = object as? [String: Any] {
            self.jsonObject = jsonObject
        } else {
            jsonObject = [:]
        }
    }
}

extension ResponseData: CustomStringConvertible {
    var description: String {
        return jsonObject.description
    }
}

extension ResponseData: Value {
    static var declaredDatatype: String {
        return Blob.declaredDatatype
    }

    static func fromDatatypeValue(_ datatypeValue: Blob) -> ResponseData {
        let encodedData = Data.fromDatatypeValue(datatypeValue)
        let result = encodedData.withUnsafeBytes { (sourceBuffer: UnsafePointer<UInt8>) -> Data in
            let sourceBufferSize = encodedData.count
            let destBufferSize = 1048576
            let destBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destBufferSize)
            let size = compression_decode_buffer(destBuffer, destBufferSize, sourceBuffer, sourceBufferSize, nil, COMPRESSION_LZFSE)

            return Data(bytesNoCopy: destBuffer, count: size, deallocator: .free)
        }
        return ResponseData(data: result)
    }

    var datatypeValue: Blob {
        // readonly
        return Data().datatypeValue
    }
}

extension Row {
    subscript(column: Expression<ResponseData>) -> ResponseData {
        return get(column)
    }

    subscript(column: Expression<ResponseData?>) -> ResponseData? {
        return get(column)
    }
}
