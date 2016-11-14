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
    
    private static func stripWhitespace(_ term: String) -> String {
        return term.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    private static func searchTerm(_ searchService:SearchService) -> (String) -> Observable<SearchResults> {
        return { term in
            guard term.characters.count > 0 else { return Observable.just(SearchResults()) }
            return searchService.search(term)
        }
	}
}
