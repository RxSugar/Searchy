import UIKit
import RxSwift

class ImageProvider {
    private let networkLayer:NetworkLayer
    private let imageCache = NSCache()
    
    init(networkLayer: NetworkLayer) {
        self.networkLayer = networkLayer
    }
	
    func imageFromURL(url: NSURL) -> Observable<UIImage> {
		let cache = imageCache
		if let image = cache.objectForKey(url.absoluteString) as? UIImage {
			return Observable.just(image)
		} else {
			return networkLayer
				.dataFromUrl(url.absoluteString)
				.map(UIImage.init)
				.ignoreNil()
				.map {
					cache.setObject($0, forKey: url.absoluteString)
					return $0
			}
		}
    }
}