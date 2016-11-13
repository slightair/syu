import Foundation

struct Xcode {
    static var currentPath: URL? {
        let process = Process()
        process.launchPath = "/usr/bin/xcode-select"
        process.arguments = ["-p"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            let resultData = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let result = String(data: resultData, encoding: String.Encoding.utf8) else {
                return nil
            }

            return URL(fileURLWithPath: result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        } else {
            return nil
        }
    }
}
