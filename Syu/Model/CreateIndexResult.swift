import Foundation
import Result

// Avoid conflict Result.Result and SQLite.Result

typealias CreateIndexResult = Result<URL, IndexCreatorError>
