import UIKit
import ReactiveCocoa

class ImageProvider {
    private let networkLayer:NetworkLayer
    var imageCache = NSCache()
    
    init(networkLayer: NetworkLayer) {
        self.networkLayer = networkLayer
    }
    
    func imageFromURL(url: NSURL) -> SignalProducer<UIImage, NoError> {
        return SignalProducer { observer, _ in
            if let image = self.imageCache.objectForKey(url.absoluteString) as? UIImage {
                observer.sendNext(image)
            } else {
                self.networkLayer.fetchDataFromUrl(url.absoluteString, completion: { result in
                    if case .Success(let data) = result, let image = UIImage(data: data) {
                        self.imageCache.setObject(image, forKey: url.absoluteString)
                        observer.sendNext(image)
                    }
                })
            }
            
        }
    }
}