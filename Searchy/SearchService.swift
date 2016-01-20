import Foundation
import RxSwift
import Argo

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
			.map(ItunesSearchService.searchResultsFromJson)
	}
	
	private static func searchResultsFromJson(jsonObject: AnyObject) throws -> SearchResults {
		guard let results:SearchResults = JSON.parse(jsonObject) <|| "results"
			else { throw NSError(domain: "com.asynchrony.searchy.invalidData", code: 42, userInfo: nil) }
		
		return results
	}

	private func escapedQuery(query:String) -> String {
		return query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
	}
}
