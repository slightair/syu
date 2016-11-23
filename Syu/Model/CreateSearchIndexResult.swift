import Foundation
import Result

// Avoid conflict Result.Result and SQLite.Result

typealias CreateSearchIndexResult = Result<URL, SearchIndexCreatorError>
