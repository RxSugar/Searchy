import Foundation
import Argo
import Curry

struct SearchResult: Equatable {
    let artist:String
    let songTitle:String
    let resultUrl:NSURL
    let iconUrl:NSURL
    
    static let emptyResult = SearchResult(artist: "", songTitle: "", resultUrl: NSURL(), iconUrl: NSURL())
}

typealias SearchResults = [SearchResult]

func ==(lhs:SearchResult, rhs:SearchResult) -> Bool {
    return lhs.artist == rhs.artist && lhs.songTitle == rhs.songTitle && lhs.resultUrl == rhs.resultUrl && lhs.iconUrl == rhs.iconUrl
}

// MARK: JSON parsing

extension SearchResult: Decodable {
	static func decode(json: JSON) -> Decoded<SearchResult> {
		let previewUrl:Decoded<NSURL> = json <| "previewUrl" >>- NSURL.decodedFromString
		
		let smallArtworkPath:Decoded<String> = json <| "artworkUrl100"
		let artworkPath = smallArtworkPath.map { $0.stringByReplacingOccurrencesOfString("100x100", withString: "600x600") }
		let iconUrl = artworkPath.flatMap(NSURL.decodedFromString)
		
		return curry(SearchResult.init)
			<^> json <| "artistName"
			<*> json <| "trackName"
			<*> previewUrl
			<*> iconUrl
	}
}

extension NSURL {
	static func decodedFromString(string: String) -> Decoded<NSURL> {
		guard let url = NSURL.init(string: string) else {
			return Argo.Decoded<NSURL>.Failure(DecodeError.Custom("Failure parsing URL"))
		}
		return Argo.Decoded.Success(url)
	}
}