import Foundation

struct SearchResult: Equatable {
    let text:String
    let resultUrl:NSURL
    let iconUrl:NSURL?
}

typealias SearchResults = [SearchResult]

func ==(lhs:SearchResult, rhs:SearchResult) -> Bool {
    return lhs.text == rhs.text && lhs.resultUrl == rhs.resultUrl && lhs.iconUrl == rhs.iconUrl
}