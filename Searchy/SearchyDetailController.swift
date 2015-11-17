import UIKit
import ReactiveCocoa
import AVFoundation

class SearchyDetailController: UIViewController, UINavigationControllerDelegate {
    let item:SearchyDisplayItem
    let snapshot:UIView
    
    init(item: SearchyDisplayItem, snapshot:UIView) {
        self.item = item
        self.snapshot = snapshot
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.title = "searchy"
        
        self.view = SearchyDetailView(item: item, backgroundSnapshot: snapshot)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.delegate = nil
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Transition(selectedItem: self.item.result)
    }
}
