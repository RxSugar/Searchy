import Foundation
import ReactiveCocoa

enum ServiceResponse<T> {
	case Success(T)
	case Error(NSError)

	init(value:T?, error:NSError?) {
		guard error == nil else {
			self = .Error(error!)
			return
		}
		guard let value = value else {
			self = .Error(NSError(domain: "com.asynchrony.serviceError", code: 11, userInfo: [NSLocalizedDescriptionKey: "Bad response"]))
			return
		}

		self = .Success(value)
	}
}

let resultLimit = 50

class SearchService {
	static func searchPopularRepositories(networkLayer:NetworkLayer)(searchTerm:String, completion: (ServiceResponse<[SearchResult]>) -> ()) {
		let escapedSearchTerm = SearchService.EscapedQuery(searchTerm)
		let url = "https://api.github.com/search/repositories?q=\(escapedSearchTerm)&sort=stars&order=desc&per_page=\(resultLimit)"

		networkLayer.getServiceResponseWithUrl(url) { jsonResponse, error in
			guard error == nil else {
				print("Error ocurred while retrieving results")
				completion(.Error(error!));
				return
			}

			guard let json = jsonResponse as? Dictionary<String,AnyObject>, let itemJsonObjects = json["items"] as? Array<Dictionary<String,AnyObject>> else {
				print("Request succeeded, but no data was returned: \(jsonResponse)")
				completion(.Success([]));
				return
			}

			let results:[SearchResult] = itemJsonObjects.map(SearchResult.FromJson).flatMap { return $0 }
			completion(.Success(results))
		}
	}

	static func EscapedQuery(query:String) -> String {
		return query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
	}
}

extension SearchResult {
	static func FromJson(json:Dictionary<String,AnyObject>) -> SearchResult? {
		guard let name = json["full_name"] as? String,
			let description = json["description"] as? String else {
				return nil
		}

		return SearchResult(name: name, description: description)
	}
}
