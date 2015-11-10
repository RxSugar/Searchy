import Foundation
import ReactiveCocoa

class SearchyModel {
	private let networkLayer = NetworkLayer()

	let searchTerm = MutableProperty<String>("")
	var searchResults:AnyProperty<SearchResults>

	init() {
		searchResults = AnyProperty(initialValue: [], producer: searchTerm.producer.flatMap(.Latest, transform: SearchyModel.searchTerm(networkLayer)))
	}

    static func searchTerm(networkLayer:NetworkLayer)(term:String) -> SignalProducer<SearchResults, NoError> {
		return SignalProducer { observer, disposable in
            guard term.characters.count > 0 else { observer.sendNext([]); observer.sendCompleted(); return }
            SearchService.search(networkLayer)(searchTerm: term) { serverResponse in
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
