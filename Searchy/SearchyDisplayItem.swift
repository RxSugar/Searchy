import Foundation
import ReactiveCocoa

struct SearchyDisplayItem {
    let result:SearchResult
    let image:AnyProperty<UIImage?>
    
    init(result:SearchResult, imageProvider:ImageProvider) {
        self.result = result
        image = AnyProperty<UIImage?>(initialValue: nil, producer: imageProvider.imageFromURL(result.iconUrl).map { .Some($0) })
    }
}