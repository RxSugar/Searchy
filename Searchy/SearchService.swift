import Foundation
import RxSwift
import Argo

let resultLimit = 50

protocol SearchService {
    func search(_ searchTerm: String) -> Observable<[SearchResult]>
}

struct ItunesSearchService: SearchService {
    fileprivate let networkLayer: NetworkLayer
    
    init(networkLayer: NetworkLayer) {
        self.networkLayer = networkLayer
    }
	
	func search(_ searchTerm: String) -> Observable<[SearchResult]> {
		let escapedSearchTerm = escapedQuery(searchTerm)
		let url = "http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music"
		return networkLayer
			.jsonFromUrl(url)
			.map(ItunesSearchService.searchResultsFromJson)
	}
	
	fileprivate static func searchResultsFromJson(_ jsonObject: Any) throws -> SearchResults {
        let decodedResults: Decoded<SearchResults> = JSON(jsonObject) <|| "results"
		guard let results = decodedResults.value
			else { throw NSError(domain: "com.asynchrony.searchy.invalidData", code: 42, userInfo: nil) }
		
		return results
	}

	fileprivate func escapedQuery(_ query:String) -> String {
		return query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
	}
}
