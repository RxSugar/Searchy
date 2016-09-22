import UIKit
import RxSwift

class ImageProvider {
    fileprivate let networkLayer:NetworkLayer
    fileprivate let imageCache = NSCache<NSString, UIImage>()
    
    init(networkLayer: NetworkLayer) {
        self.networkLayer = networkLayer
    }
	
    func imageFromURL(_ url: URL?) -> Observable<UIImage> {
		let cache = imageCache
		if let image = cache.object(forKey: url.absoluteStringOrEmpty as NSString) {
			return Observable.just(image)
		} else {
			return networkLayer
				.dataFromUrl(url.absoluteStringOrEmpty)
				.map(UIImage.init)
				.ignoreNil()
				.map {
					cache.setObject($0, forKey: url.absoluteStringOrEmpty as NSString)
					return $0
			}
		}
    }
}

protocol HasAbsoluteString {
    var absoluteString: String { get }
}

extension URL: HasAbsoluteString {
}

extension Optional where Wrapped: HasAbsoluteString {
    var absoluteStringOrEmpty: String {
        return self?.absoluteString ?? ""
    }
}
