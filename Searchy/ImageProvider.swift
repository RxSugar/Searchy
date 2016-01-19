import UIKit
import RxSwift

class ImageProvider {
    private let networkLayer:NetworkLayer
    var imageCache = NSCache()
    
    init(networkLayer: NetworkLayer) {
        self.networkLayer = networkLayer
    }
	
    func imageFromURL(url: NSURL) -> Observable<UIImage> {
        return Observable.create { observer in
            if let image = self.imageCache.objectForKey(url.absoluteString) as? UIImage {
                observer.on(.Next(image))
            } else {
                self.networkLayer.fetchDataFromUrl(url.absoluteString, completion: { result in
                    if case .Success(let data) = result, let image = UIImage(data: data) {
                        self.imageCache.setObject(image, forKey: url.absoluteString)
                        observer.on(.Next(image))
                        observer.on(.Completed)
                    }
                })
            }
            
            return AnonymousDisposable {}
        }
    }
}