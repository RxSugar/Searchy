import Foundation

class NetworkLayer {
	func getServiceResponseWithUrl(url:String, completion:(jsonResponse:AnyObject?, error:NSError?) -> ()) {
		let session = NSURLSession.sharedSession()
		let request = NSURLRequest(URL: NSURL(string: url)!)
		let task = session.dataTaskWithRequest(request) { (data, response, error) -> () in
			dispatch_async(dispatch_get_main_queue(), {
				let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)
				completion(jsonResponse: json, error: error)
			})
		}
		task.resume()
	}
}