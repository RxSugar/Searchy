import Foundation

struct SearchResult {
    let text:String
    let resultUrl:NSURL
    let iconUrl:NSURL?
}

typealias SearchResults = [SearchResult]
