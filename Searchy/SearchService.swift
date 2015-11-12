import Foundation
import ReactiveCocoa

enum ServiceResponse<T> {
	case Success(T)
	case Error(NSError)

	init(value:T?) {
		guard let value = value else {
			self = .Error(NSError(domain: "com.asynchrony.serviceError", code: 11, userInfo: [NSLocalizedDescriptionKey: "Bad response"]))
			return
		}
		self = .Success(value)
	}
    
    init(error:NSError) {
        self = .Error(error)
    }
}

let resultLimit = 50

protocol SearchService {
    func search(searchTerm:String, completion: (ServiceResponse<[SearchResult]>) -> ())
}

struct DuckDuckGoSearchService: SearchService {
    private let networkLayer:NetworkLayer
    
    init(networkLayer:NetworkLayer) {
        self.networkLayer = networkLayer
    }
    
	func search(searchTerm:String, completion: (ServiceResponse<[SearchResult]>) -> ()) {
		let escapedSearchTerm = escapedQuery(searchTerm)
        let url = "http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music"

		networkLayer.getServiceResponseWithUrl(url) { jsonResponse, error in
			guard error == nil else {
				print("Error ocurred while retrieving results")
				completion(.Error(error!));
				return
			}

			guard let json = jsonResponse as? Dictionary<String,AnyObject>, let itemJsonObjects = json["results"] as? Array<Dictionary<String,AnyObject>> else {
				print("Request succeeded, but no data was returned: \(jsonResponse)")
				completion(.Success([]));
				return
			}

			let results:[SearchResult] = itemJsonObjects.map(SearchResult.buildFromJson).flatMap { return $0 }
			completion(.Success(results))
		}
	}

	private func escapedQuery(query:String) -> String {
		return query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
	}
}

extension SearchResult {
    static func buildFromJson(json:Dictionary<String,AnyObject>) -> SearchResult? {
        guard let artist = json["artistName"] as? String else { return nil }
        guard let songTitle = json["trackName"] as? String else { return nil }
        guard let url = json["previewUrl"] as? String, resultUrl =  NSURL(string: url) else { return nil }
        
        let iconUrlString = json["artworkUrl100"] as? String ?? ""
        let iconURL = NSURL(string: iconUrlString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))

        return SearchResult(artist: artist, songTitle: songTitle, resultUrl: resultUrl, iconUrl: iconURL)
	}
}
