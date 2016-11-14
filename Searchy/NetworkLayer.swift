import Foundation
import UIKit
import RxSwift

protocol NetworkLayer {
	func dataFromUrl(_ urlString: String) -> Observable<Data>
	func jsonFromUrl(_ urlString: String) -> Observable<Any>
}

enum SearchyNetworkError: Error {
    case badResponse
    case deserializationError(Error)
    case fatal
}

class URLSessionNetworkLayer : NetworkLayer {
	let session = URLSession.shared
    
    func fetchRequest(_ request: URLRequest) -> Observable<(Data, HTTPURLResponse)> {
        return Observable.create { observer in
            let task = self.session.dataTask(with: request as URLRequest) { (data, response, error) in
                guard let response = response, let data = data else {
                    observer.on(.error(error ?? SearchyNetworkError.fatal))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.on(.error(SearchyNetworkError.badResponse))
                    return
                }
                
                observer.on(.next(data, httpResponse))
                observer.on(.completed)
            }
            
            let t = task
            t.resume()
            
            return Disposables.create { _ in task.cancel() }
        }
    }
    
	func dataFromUrl(_ urlString: String) -> Observable<Data> {
		return fetchRequest(requestForPath(urlString))
            .map { data, _ in return data }
            .observeOn(MainScheduler.instance)
        
	}
	
	func jsonFromUrl(_ urlString: String) -> Observable<Any> {
		return fetchRequest(requestForPath(urlString))
            .map { data, response in
                do {
                    return try JSONSerialization.jsonObject(with: data, options: [])
                } catch let error {
                    throw SearchyNetworkError.deserializationError(error)
                }
            }
            .observeOn(MainScheduler.instance)
	}
	
	fileprivate func requestForPath(_ urlString: String) -> URLRequest {
		return URLRequest(url: URL(string: urlString)!)
	}
}
