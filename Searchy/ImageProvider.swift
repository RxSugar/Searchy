import UIKit
import RxSwift

class ImageProvider {
    private let networkLayer: NetworkLayer
    private let imageCache = NSCache<NSString, UIImage>()
    
    init(networkLayer: NetworkLayer) {
        self.networkLayer = networkLayer
    }
	
    func imageFromURL(_ url: URL) -> Observable<UIImage> {
		let cache = imageCache
		if let image = cache.object(forKey: url.absoluteString as NSString) {
			return Observable.just(image)
		} else {
			return networkLayer
				.dataFromUrl(url.absoluteString)
				.map(UIImage.init)
				.ignoreNil()
				.map {
					cache.setObject($0, forKey: url.absoluteString as NSString)
					return $0
			}
		}
    }
}
