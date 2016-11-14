import UIKit
import RxSwift

struct SearchyDisplayItem {
    private let disposeBag = DisposeBag()
    let result: SearchResult
    let image: Observable<UIImage?>
    
    init(result: SearchResult, imageProvider: ImageProvider) {
        self.result = result
        if let iconURL = result.iconUrl {
            let fetchImage = imageProvider.imageFromURL(iconURL)
            
            let connectableImage = fetchImage.toOptional().replay(1)
            _ = connectableImage.connect()
            image = connectableImage
        } else {
            image = Observable.just(nil)
        }
    }
}
