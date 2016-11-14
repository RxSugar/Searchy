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

        popGesture.addTarget(self, action: #selector(SearchyDetailController.handlePopGesture(_:)))
        popGesture.edges = .left;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.title = "searchy"
        self.view = SearchyDetailView(item: item, backgroundSnapshot: snapshot)
        view.addGestureRecognizer(popGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.delegate = nil
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Transition(selectedItem: self.item.result, navigationController: navigationController)
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard animationController is Transition else { return nil }
        return self.interactivePopTransition;
    }
    
    func handlePopGesture(_ popGesture: UIScreenEdgePanGestureRecognizer) {
        let translationPercent = popGesture.translation(in: view).x / view.bounds.width;
        let progress = max(min(translationPercent, 1.0), 0.0)
        
        switch popGesture.state {
        case .began:
            interactivePopTransition = UIPercentDrivenInteractiveTransition()
            _ = navigationController?.popViewController(animated: true)
        case .changed:
            interactivePopTransition?.update(progress)
        case .ended:
            if progress > 0.5 {
                interactivePopTransition?.finish()
            } else {
                interactivePopTransition?.cancel()
            }
            interactivePopTransition = nil
        case .cancelled: fallthrough
        case .failed:
            interactivePopTransition?.cancel()
            interactivePopTransition = nil
        default:
            break
        }
    }

}
