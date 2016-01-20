import Foundation
import RxSwift
import RxCocoa

let resultLimit = 50

protocol SearchService {
    func search(searchTerm: String) -> Observable<[SearchResult]>
}

struct ItunesSearchService: SearchService {
    private let networkLayer: NetworkLayer
    
    init(networkLayer: NetworkLayer) {
        self.networkLayer = networkLayer
    }
	
	func search(searchTerm: String) -> Observable<[SearchResult]> {
		let escapedSearchTerm = escapedQuery(searchTerm)
		let url = "http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music"
		return networkLayer
			.jsonFromUrl(url)
			.map(ItunesSearchService.searchResultsFromJSON)
	}
	
	private static func searchResultsFromJSON(json: AnyObject) throws -> [SearchResult] {
		guard let jsonDictionary = json as? Dictionary<String, AnyObject>,
			let itemJsonObjects = jsonDictionary["results"] as? Array<Dictionary<String, AnyObject>>
			else {
			throw NSError(domain: "com.asynchrony.searchy.invalidData", code: 42, userInfo: nil)
		}
		
		return try itemJsonObjects.map(SearchResult.decode).flatMap { return $0 }
	}

	private func escapedQuery(query:String) -> String {
		return query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
	}
}

extension SearchResult {
    static func decode(json:Dictionary<String, AnyObject>) throws -> SearchResult? {
        guard let
			artist = json["artistName"] as? String,
			songTitle = json["trackName"] as? String,
			url = json["previewUrl"] as? String,
			resultUrl =  NSURL(string: url)
			else { throw NSError(domain: "com.asynchrony.searchy.invalidData", code: 42, userInfo: nil) }
        
        let imageString100px = json["artworkUrl100"] as? String ?? ""
        let imageString600px = imageString100px.stringByReplacingOccurrencesOfString("100x100", withString: "600x600")
        let iconURL = NSURL(string: imageString600px) ?? NSURL()

        return SearchResult(artist: artist, songTitle: songTitle, resultUrl: resultUrl, iconUrl: iconURL)
	}
}
