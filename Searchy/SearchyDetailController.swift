import UIKit
import AVFoundation

class SearchyDetailController: UIViewController, UINavigationControllerDelegate {
    let item:SearchyDisplayItem
    let snapshot:UIView
    private var interactivePopTransition:UIPercentDrivenInteractiveTransition?
    private let popGesture = UIScreenEdgePanGestureRecognizer()
    
    init(item: SearchyDisplayItem, snapshot:UIView) {
        self.item = item
        self.snapshot = snapshot
        super.init(nibName: nil, bundle: nil)

        popGesture.addTarget(self, action: "handlePopGesture:")
        popGesture.edges = .Left;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.title = "searchy"
        self.view = SearchyDetailView(item: item, backgroundSnapshot: snapshot)
        view.addGestureRecognizer(popGesture)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.delegate = nil
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Transition(selectedItem: self.item.result, navigationController: navigationController)
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard animationController is Transition else { return nil }
        return self.interactivePopTransition;
    }
    
    func handlePopGesture(popGesture: UIScreenEdgePanGestureRecognizer) {
        let translationPercent = popGesture.translationInView(view).x / view.bounds.width;
        let progress = max(min(translationPercent, 1.0), 0.0)
        
        switch popGesture.state {
        case .Began:
            interactivePopTransition = UIPercentDrivenInteractiveTransition()
            navigationController?.popViewControllerAnimated(true)
        case .Changed:
            interactivePopTransition?.updateInteractiveTransition(progress)
        case .Ended:
            if progress > 0.5 {
                interactivePopTransition?.finishInteractiveTransition()
            } else {
                interactivePopTransition?.cancelInteractiveTransition()
            }
            interactivePopTransition = nil
        case .Cancelled: fallthrough
        case .Failed:
            interactivePopTransition?.cancelInteractiveTransition()
            interactivePopTransition = nil
        default:
            break
        }
    }

}
