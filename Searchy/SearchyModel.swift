import Foundation
import RxSwift

class SearchyModel {
    private let searchService: SearchService

	let searchTerm = Variable<String>("")
	let searchResults:Observable<SearchResults>

    init(searchService:SearchService) {
        self.searchService = searchService
        
        let searchResultsStream = searchTerm.asObservable()
            .map(SearchyModel.stripWhitespace)
            .flatMapLatest(SearchyModel.searchTerm(searchService))
			.share()
        
		searchResults = searchResultsStream
	}
    
    private static func stripWhitespace(term: String) -> String {
        return term.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }

    private static func searchTerm(searchService:SearchService)(term:String) -> Observable<SearchResults> {
		return Observable.create { observer in
            guard term.characters.count > 0 else { observer.on(.Next([])); observer.on(.Completed); return NopDisposable.instance }
            searchService.search(term) { serverResponse in
				switch serverResponse {
                case .Success(let results):
					observer.on(.Next(results))
					observer.on(.Completed)
				case .Error(let error):
					print("\(error)")
                    observer.on(.Next([]))
                    observer.on(.Completed)
				}
			}
			return AnonymousDisposable {}
		}
	}
}
