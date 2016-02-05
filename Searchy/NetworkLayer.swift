import Foundation
import UIKit
import RxSwift

protocol NetworkLayer {
	func dataFromUrl(urlString: String) -> Observable<NSData>
	func jsonFromUrl(urlString: String) -> Observable<AnyObject>
}

enum SearchyNetworkError: ErrorType {
    case BadResponse
    case DeserializationError(ErrorType)
    case Fatal
}

class URLSessionNetworkLayer : NetworkLayer {
	let session = NSURLSession.sharedSession()
    
    func fetchRequest(request: NSURLRequest) -> Observable<(NSData, NSHTTPURLResponse)> {
        return Observable.create { observer in
            let task = self.session.dataTaskWithRequest(request) { (data, response, error) in
                guard let response = response, data = data else {
                    observer.on(.Error(error ?? SearchyNetworkError.Fatal))
                    return
                }
                
                guard let httpResponse = response as? NSHTTPURLResponse else {
                    observer.on(.Error(SearchyNetworkError.BadResponse))
                    return
                }
                
                observer.on(.Next(data, httpResponse))
                observer.on(.Completed)
            }
            
            let t = task
            t.resume()
            
            return AnonymousDisposable {
                task.cancel()
            }
        }
    }
    
	func dataFromUrl(urlString: String) -> Observable<NSData> {
		return fetchRequest(requestForPath(urlString))
            .map { data, _ in return data }
            .observeOn(MainScheduler.instance)
        
	}
	
	func jsonFromUrl(urlString: String) -> Observable<AnyObject> {
		return fetchRequest(requestForPath(urlString))
            .map { data, response in
                do {
                    return try NSJSONSerialization.JSONObjectWithData(data ?? NSData(), options: [])
                } catch let error {
                    throw SearchyNetworkError.DeserializationError(error)
                }
            }
            .observeOn(MainScheduler.instance)
	}
	
	private func requestForPath(urlString: String) -> NSURLRequest {
		return NSURLRequest(URL: NSURL(string: urlString)!)
	}
}
