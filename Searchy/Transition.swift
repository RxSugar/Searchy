import UIKit

protocol SearchyImageTransitionable : SearchyReversableTransitionable {
    func imageViewForItem(item: SearchResult) -> UIImageView?
}

protocol SearchyReversableTransitionable {
    func setVisibleTransitionState(visible:Bool)
    func view() -> UIView
}

extension SearchyReversableTransitionable where Self: UIView {
    func view() -> UIView {
        return self
    }
}

class Transition : NSObject, UIViewControllerAnimatedTransitioning {
    let imageTransition: (UIViewControllerContextTransitioning) -> ImageTransition?
    
    init(selectedItem: SearchResult, navigationController: UINavigationController) {
       self.imageTransition = ImageTransition.build(selectedItem, navigationController: navigationController)
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        imageTransition(transitionContext)?.animate()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return ImageTransition.duration
    }
}

struct ImageTransition {
    static let duration = 0.3
    private let navigationController:UINavigationController
    private let selectedItem:SearchResult
    private let fromView: UIView
    private let toView: UIView
    private let containerView: UIView
    private let fromImageView: UIImageView
    private let toImageView: UIImageView
    private let fromTransitionable: SearchyImageTransitionable
    private let toTransitionable: SearchyImageTransitionable
    private let context: UIViewControllerContextTransitioning
    
    init?(selectedItem: SearchResult, navigationController: UINavigationController, transitionContext: UIViewControllerContextTransitioning) {
        guard let fromTransitionable = transitionContext.viewForKey(UITransitionContextFromViewKey) as? SearchyImageTransitionable,
            let toTransitionable = transitionContext.viewForKey(UITransitionContextToViewKey) as? SearchyImageTransitionable,
            let containerView = transitionContext.containerView(),
            let fromImageView = fromTransitionable.imageViewForItem(selectedItem),
            let toImageView = toTransitionable.imageViewForItem(selectedItem) else {
                print("FAIL!!!")
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                return nil
        }
        
        self.fromTransitionable = fromTransitionable
        self.toTransitionable = toTransitionable
        self.containerView = containerView
        self.fromImageView = fromImageView
        self.toImageView = toImageView
        self.fromView = fromTransitionable.view()
        self.toView = toTransitionable.view()
        self.context = transitionContext
        self.navigationController = navigationController
        self.selectedItem = selectedItem
    }
    
    func animate() {
        let isPush = navigationController.viewControllers.reduce(false) { isPush, viewController in
            return isPush || viewController.isViewLoaded() && viewController.view == fromView
        }
        let topView = isPush ? toView : fromView
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(topView)
        
        toTransitionable.setVisibleTransitionState(false)
        fromTransitionable.setVisibleTransitionState(true)
        
        toView.frame = context.finalFrameForViewController(context.viewControllerForKey(UITransitionContextToViewControllerKey)!)
        toView.layoutIfNeeded()
        
        let imageSnapshot = UIImageView(image: fromImageView.image)
        imageSnapshot.contentMode = fromImageView.contentMode
        imageSnapshot.frame = fromImageView.convertRect(fromImageView.bounds, toView: containerView)
        containerView.addSubview(imageSnapshot)
        
        fromImageView.hidden = true
        toImageView.hidden = true
        
        UIView.animateWithDuration(ImageTransition.duration, animations: {
            self.toTransitionable.setVisibleTransitionState(true)
            self.fromTransitionable.setVisibleTransitionState(false)
            imageSnapshot.frame = self.toImageView.convertRect(self.toImageView.bounds, toView: self.containerView)
            }, completion: { _ in
                self.fromImageView.hidden = false
                self.toImageView.hidden = false
                imageSnapshot.removeFromSuperview()
                self.context.completeTransition(!self.context.transitionWasCancelled())
        })
    }
    
    static func build(selectedItem: SearchResult, navigationController: UINavigationController)(transitionContext: UIViewControllerContextTransitioning) -> ImageTransition? {
        return self.init(selectedItem: selectedItem, navigationController: navigationController, transitionContext: transitionContext)
    }
}