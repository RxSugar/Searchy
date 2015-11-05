import Foundation
import ReactiveCocoa

class SearchyModel {
	private let networkLayer = NetworkLayer()

	let mutableSearchTerm = MutableProperty<String>("")
	var searchResults:AnyProperty<SearchResults>

	init() {
		searchResults = AnyProperty(initialValue: [], producer: mutableSearchTerm.producer.filter { $0.characters.count > 0 }.flatMap(.Latest, transform: SearchyModel.searchTerm(networkLayer)))
	}

    static func searchTerm(networkLayer:NetworkLayer)(term:String) -> SignalProducer<SearchResults, NoError> {
		return SignalProducer { observer, disposable in
            SearchService.searchPopularRepositories(networkLayer)(searchTerm: term) { serverResponse in
				switch serverResponse {
				case .Success(let results):
					observer.sendNext(results)
					observer.sendCompleted()
				case .Error(let error):
					print("\(error)")
					observer.sendNext([])
				}
			}
		}
	}
}
