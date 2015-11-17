import UIKit
import ReactiveCocoa
import AVFoundation

class SearchyDetailController: UIViewController {
    let item:SearchResult
    
    init(item: SearchResult) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.title = "searchy"
        
        let view = UIView()
        view.backgroundColor = UIColor.orangeColor()
        //SearchyBinding.bind(model: model, view: view, selectionHandler: self.selectionHandler)
        self.view = view
    }
}
