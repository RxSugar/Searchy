import Foundation
import UIKit
import Result

protocol NetworkLayer {
    func getServiceResponseWithUrl(url:String, completion:(Result<AnyObject, NSError>) -> ())
    func fetchDataFromUrl(url:String, completion:(Result<NSData, NSError>) -> ())
}

class URLSessionNetworkLayer : NetworkLayer {
	func getServiceResponseWithUrl(url:String, completion:(Result<AnyObject, NSError>) -> ()) {
        fetchDataFromUrl(url) { result in
            switch result {
            case .Success(let data):
                guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else {
                    completion(Result(error: NSError(domain: "Searchy", code: 0, userInfo: nil)))
                    return
                }
                completion(Result(json))
            case .Failure(let error):
                completion(Result(error: error))
            }
        }
	}
    
    func fetchDataFromUrl(url:String, completion:(Result<NSData, NSError>) -> ()) {
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: NSURL(string: url)!)
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue(), {
                guard let data = data else {
                    let error = error ?? NSError(domain: "Searchy", code: 0, userInfo: nil)
                    completion(Result(error: error))
                    return
                }
                
                completion(Result(data))
            })
        }
        task.resume()
    }
}