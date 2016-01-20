import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol NetworkLayer {
	func dataFromUrl(urlString: String) -> Observable<NSData>
	func jsonFromUrl(urlString: String) -> Observable<AnyObject>
}

class URLSessionNetworkLayer : NetworkLayer {
	let session = NSURLSession.sharedSession()
	
	func dataFromUrl(urlString: String) -> Observable<NSData> {
		return session.rx_data(requestForPath(urlString)).observeOn(MainScheduler.instance)
	}
	
	func jsonFromUrl(urlString: String) -> Observable<AnyObject> {
		return session.rx_JSON(requestForPath(urlString)).observeOn(MainScheduler.instance)
	}
	
	private func requestForPath(urlString: String) -> NSURLRequest {
		return NSURLRequest(URL: NSURL(string: urlString)!)
	}
}