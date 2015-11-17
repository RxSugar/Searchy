import UIKit
import ReactiveCocoa
import AVFoundation

class SearchyDetailController: UIViewController {
    let item:SearchyDisplayItem
    
    init(item: SearchyDisplayItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.title = "searchy"
        
        let view = SearchyDetailView(item: item)
        self.view = view
    }
}
