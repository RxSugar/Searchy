import UIKit

protocol SearchyTransitionable {
    func imageViewForItem(item: SearchResult) -> UIImageView?
    
    func blurView() -> UIVisualEffectView?
}

class Transition : NSObject, UIViewControllerAnimatedTransitioning {
    let selectedItem: SearchResult
    let navigationController: UINavigationController
    
    init(selectedItem: SearchResult, navigationController: UINavigationController) {
        self.selectedItem = selectedItem
        self.navigationController = navigationController
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let containerView = transitionContext.containerView() else {
                print("FAIL!!!")
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                return
        }
        
        let fromView = fromViewController.view
        let toView = toViewController.view
        
        guard let fromTransitionable = fromView as? SearchyTransitionable,
            let toTransitionable = toView as? SearchyTransitionable,
            let fromImageView = fromTransitionable.imageViewForItem(selectedItem),
            let toImageView = toTransitionable.imageViewForItem(selectedItem),
            let blurView = toTransitionable.blurView() ?? fromTransitionable.blurView() else {
                print("FAIL!!!")
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                return
        }
        
        let viewControllers = [fromViewController, toViewController]
        let viewsOnStack:[UIView] = navigationController.viewControllers
            .filter { viewControllers.contains($0) }
            .map { $0.view }
        
        let poppedViews = [fromView, toView].filter { !viewsOnStack.contains($0) }
        let views = viewsOnStack + poppedViews
        
        views.forEach {
            containerView.addSubview($0)
        }
        
        let isPush = poppedViews.count == 0
        let blurEffect = UIBlurEffect(style: .Light)
        blurView.effect = isPush ? nil : blurEffect
        
        toView.frame = transitionContext.finalFrameForViewController(transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
        toView.layoutIfNeeded()
        
        let imageSnapshot = UIImageView(image: fromImageView.image)
        imageSnapshot.contentMode = fromImageView.contentMode
        imageSnapshot.frame = fromImageView.convertRect(fromImageView.bounds, toView: containerView)
        print("from: \(imageSnapshot.frame)")
        containerView.addSubview(imageSnapshot)
        
        fromImageView.hidden = true
        toImageView.hidden = true
        
        UIView.animateWithDuration(0.3, animations: {
            blurView.effect = isPush ? blurEffect : nil
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