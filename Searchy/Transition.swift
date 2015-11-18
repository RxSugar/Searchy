import UIKit

protocol SearchyTransitionable {
    func imageViewForItem(item: SearchResult) -> UIImageView?
    func setVisibleTransitionState(visible:Bool)
    func view() -> UIView
}

extension SearchyTransitionable where Self: UIView {
    func view() -> UIView {
        return self
    }
}

class Transition : NSObject, UIViewControllerAnimatedTransitioning {
    let selectedItem: SearchResult
    let navigationController: UINavigationController
    
    init(selectedItem: SearchResult, navigationController: UINavigationController) {
        self.selectedItem = selectedItem
        self.navigationController = navigationController
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromTransitionable = transitionContext.viewForKey(UITransitionContextFromViewKey) as? SearchyTransitionable,
            let toTransitionable = transitionContext.viewForKey(UITransitionContextToViewKey) as? SearchyTransitionable,
            let containerView = transitionContext.containerView(),
            let fromImageView = fromTransitionable.imageViewForItem(selectedItem),
            let toImageView = toTransitionable.imageViewForItem(selectedItem) else {
                print("FAIL!!!")
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                return
        }
        
        let fromView = fromTransitionable.view()
        let toView = toTransitionable.view()
        
        let isPush = navigationController.viewControllers.reduce(false) { isPush, viewController in
            return isPush || viewController.isViewLoaded() && viewController.view == fromView
        }
        let topView = isPush ? toView : fromView
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(topView)
        
        toTransitionable.setVisibleTransitionState(false)
        fromTransitionable.setVisibleTransitionState(true)
        
        toView.frame = transitionContext.finalFrameForViewController(transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
        toView.layoutIfNeeded()
        
        let imageSnapshot = UIImageView(image: fromImageView.image)
        imageSnapshot.contentMode = fromImageView.contentMode
        imageSnapshot.frame = fromImageView.convertRect(fromImageView.bounds, toView: containerView)
        containerView.addSubview(imageSnapshot)
        
        fromImageView.hidden = true
        toImageView.hidden = true
        
        UIView.animateWithDuration(0.3, animations: {
            toTransitionable.setVisibleTransitionState(true)
            fromTransitionable.setVisibleTransitionState(false)
            imageSnapshot.frame = toImageView.convertRect(toImageView.bounds, toView: containerView)
            }, completion: { _ in
                fromImageView.hidden = false
                toImageView.hidden = false
                imageSnapshot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
}