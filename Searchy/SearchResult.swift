import Foundation

struct SearchResult: Equatable {
    let artist:String
    let songTitle:String
    let resultUrl:NSURL
    let iconUrl:NSURL?
}

typealias SearchResults = [SearchResult]

func ==(lhs:SearchResult, rhs:SearchResult) -> Bool {
    return lhs.artist == rhs.artist && lhs.songTitle == rhs.songTitle && lhs.resultUrl == rhs.resultUrl && lhs.iconUrl == rhs.iconUrl
}