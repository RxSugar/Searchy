import Foundation
import RxSwift

class SearchyModel {
	let searchTerm = Variable<String>("")
	let searchResults:Observable<SearchResults>

    init(searchService:SearchService) {
        searchResults = searchTerm.asObservable()
            .map(SearchyModel.stripWhitespace)
            .flatMapLatest(SearchyModel.searchTerm(searchService))
			.catchErrorJustReturn([])
			.share()
	}
    
    private static func stripWhitespace(term: String) -> String {
        return term.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }

    private static func searchTerm(searchService:SearchService)(term:String) -> Observable<SearchResults> {
		guard term.characters.count > 0 else { return Observable.just(SearchResults()) }
		
		return searchService.search(term)
	}
}
