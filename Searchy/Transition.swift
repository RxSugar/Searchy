import UIKit

protocol SearchyTransitionable {
    func imageViewForItem(item: SearchResult) -> UIImageView?
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
            let toTransitionable = toView as? SearchyTransitionable,
            let fromImageView = fromTransitionable.imageViewForItem(selectedItem),
            let toImageView = toTransitionable.imageViewForItem(selectedItem) else {
                print("FAIL!!!")
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                return
        }
        
        toView.frame = transitionContext.finalFrameForViewController(transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
        toView.layoutIfNeeded()
        toView.alpha = 0.0
        containerView.addSubview(toView)
        
        let imageSnapshot = UIImageView(image: fromImageView.image)
        imageSnapshot.contentMode = fromImageView.contentMode
        imageSnapshot.frame = fromImageView.convertRect(fromImageView.bounds, toView: containerView)
        print("from: \(imageSnapshot.frame)")
        containerView.addSubview(imageSnapshot)
        
        fromImageView.hidden = true
        toImageView.hidden = true
        
        UIView.animateWithDuration(0.3, animations: {
            toView.alpha = 1.0
            imageSnapshot.frame = toImageView.convertRect(toImageView.bounds, toView: containerView)
            print("to: \(imageSnapshot.frame)")
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