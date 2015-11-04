import Foundation
import ReactiveCocoa

class SearchyModel {
	private let networkLayer = NetworkLayer()
	private let fetchSearchTerms:(String, (ServiceResponse<[SearchResult]>)->())->()
//	let searchTerm = MutableProperty<AnyObject?>(nil)
	//let possibleResults:AnyProperty<SearchResults>

	init() {
		fetchSearchTerms = SearchService.searchPopularRepositories(networkLayer)

		//possibleResults = AnyProperty(initialValue: [], producer: searchTerm.producer)
	}

	func searchTerm(term:String, completion:[SearchResult] -> ()) {
		self.fetchSearchTerms(term) { serverResponse in
			switch serverResponse {
			case .Success(let results):
				return completion(results)
			case .Error(let error):
				print("\(error)")
				return completion([])
			}
		}
	}
	
//	func searchTerm(term:String) -> SignalProducer<[SearchResult], NoError> {
//		return SignalProducer { observer, disposable in
//			self.fetchSearchTerms(term) { serverResponse in
//				switch serverResponse {
//				case .Success(let results):
//					observer.sendNext(results)
//					observer.sendCompleted()
//				case .Error(let error):
//					print("\(error)")
//					observer.sendNext([])
//				}
//			}
//		}
//	}
}
