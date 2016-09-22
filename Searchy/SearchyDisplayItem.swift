import UIKit
import RxSwift

struct SearchyDisplayItem {
	fileprivate let disposeBag = DisposeBag()
    let result:SearchResult
	let image:Observable<UIImage?>
    
    init(result:SearchResult, imageProvider:ImageProvider) {
        self.result = result
		let iconURL = result.iconUrl
        let fetchImage = imageProvider.imageFromURL(iconURL)
		
		let connectableImage = fetchImage.toOptional().replay(1)
		connectableImage.connect()
		image = connectableImage
    }
}
