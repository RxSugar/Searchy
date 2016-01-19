import UIKit
import RxSwift

struct SearchyDisplayItem {
    let result:SearchResult
    let image:Observable<UIImage?>
    
    init(result:SearchResult, imageProvider:ImageProvider) {
        self.result = result
        let fetchImage = imageProvider.imageFromURL2(result.iconUrl)
        
        let connectableImage = fetchImage.replay(1)
        connectableImage.connect()
        
        image = connectableImage.map {
            print("\(result.iconUrl) - \($0)")
            return .Some($0)
        }
    }
}