import UIKit

protocol SearchyTransitionable {
    func imageRectForItem(item: SearchResult) -> CGRect
}

class Transition : NSObject, UIViewControllerAnimatedTransitioning {
    let selectedItem: SearchResult
    
    init(selectedItem: SearchResult) {
        self.selectedItem = selectedItem
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey),
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey),
        let containerView = transitionContext.containerView(),
        let fromTransitionable = fromView as? SearchyTransitionable,
        let toTransitionable = toView as? SearchyTransitionable else { return }
        
        toView.frame = transitionContext.finalFrameForViewController(transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
        toView.layoutIfNeeded()
        toView.alpha = 0.0
        containerView.addSubview(toView)
        
        let imageSnapshot = UIView()
        imageSnapshot.frame = fromView.convertRect(fromTransitionable.imageRectForItem(selectedItem), toView: containerView)
        print("from: \(imageSnapshot.frame)")
        imageSnapshot.backgroundColor = UIColor.greenColor()
        containerView.addSubview(imageSnapshot)
        
        UIView.animateWithDuration(0.3, animations: {
            toView.alpha = 1.0
            imageSnapshot.frame = toView.convertRect(toTransitionable.imageRectForItem(self.selectedItem), toView: containerView)
            print("to: \(imageSnapshot.frame)")
            }, completion: { _ in
                imageSnapshot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
}