import Foundation
import Argo
import Curry
import Runes

struct SearchResult: Equatable {
    let artist: String
    let songTitle: String
    let resultUrl: URL?
    let iconUrl: URL?
    
    static let emptyResult = SearchResult(artist: "", songTitle: "", resultUrl: URL(string: ""), iconUrl: URL(string: ""))
}

typealias SearchResults = [SearchResult]

func ==(lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.artist == rhs.artist && lhs.songTitle == rhs.songTitle && lhs.resultUrl == rhs.resultUrl && lhs.iconUrl == rhs.iconUrl
}

// MARK: JSON parsing

extension SearchResult: Decodable {
	static func decode(_ json: JSON) -> Decoded<SearchResult> {
		let previewUrl: Decoded<URL> = json <| "previewUrl" >>- URL.decodedFromString
		
		let smallArtworkPath: Decoded<String> = json <| "artworkUrl100"
        let artworkPath = smallArtworkPath.map { $0.replacingOccurrences(of: "100x100", with: "600x600") }
		let iconUrl = artworkPath.flatMap(URL.decodedFromString)
		
		return curry(SearchResult.init)
			<^> json <| "artistName"
			<*> json <| "trackName"
			<*> previewUrl
			<*> iconUrl
	}
}

extension URL {
	static func decodedFromString(_ string: String) -> Decoded<URL> {
		guard let url = URL.init(string: string) else {
			return Argo.Decoded<URL>.failure(DecodeError.custom("Failure parsing URL"))
		}
		return Argo.Decoded.success(url)
	}
}
