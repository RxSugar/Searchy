import Foundation
import ReactiveCocoa

class SearchyModel {
    private let searchService: SearchService

	let searchTerm = MutableProperty<String>("")
	let searchResults:AnyProperty<SearchResults>

    init(searchService:SearchService) {
        self.searchService = searchService
		searchResults = AnyProperty(initialValue: [], producer: searchTerm.producer.flatMap(.Latest, transform: SearchyModel.searchTerm(searchService)))
	}

    private static func searchTerm(searchService:SearchService)(term:String) -> SignalProducer<SearchResults, NoError> {
		return SignalProducer { observer, disposable in
            guard term.characters.count > 0 else { observer.sendNext([]); observer.sendCompleted(); return }
            searchService.search(term) { serverResponse in
				switch serverResponse {
				case .Success(let results):
					observer.sendNext(results)
					observer.sendCompleted()
				case .Error(let error):
					print("\(error)")
                    observer.sendNext([])
                    observer.sendCompleted()
				}
			}
		}
	}
}
