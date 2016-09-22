import UIKit

protocol SearchyImageTransitionable : SearchyReversableTransitionable {
    func imageViewForItem(_ item: SearchResult) -> UIImageView?
}

protocol SearchyReversableTransitionable {
    func setVisibleTransitionState(_ visible:Bool)
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
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        imageTransition(transitionContext)?.animate()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return ImageTransition.duration
    }
}

struct ImageTransition {
    static let duration = 0.3
    fileprivate let navigationController:UINavigationController
    fileprivate let selectedItem:SearchResult
    fileprivate let fromView: UIView
    fileprivate let toView: UIView
    fileprivate let containerView: UIView
    fileprivate let fromImageView: UIImageView
    fileprivate let toImageView: UIImageView
    fileprivate let fromTransitionable: SearchyImageTransitionable
    fileprivate let toTransitionable: SearchyImageTransitionable
    fileprivate let context: UIViewControllerContextTransitioning
    
    init?(selectedItem: SearchResult, navigationController: UINavigationController, transitionContext: UIViewControllerContextTransitioning) {
        guard let fromTransitionable = transitionContext.view(forKey: UITransitionContextViewKey.from) as? SearchyImageTransitionable,
            let toTransitionable = transitionContext.view(forKey: UITransitionContextViewKey.to) as? SearchyImageTransitionable,
            let fromImageView = fromTransitionable.imageViewForItem(selectedItem),
            let toImageView = toTransitionable.imageViewForItem(selectedItem) else {
                print("FAIL!!!")
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return nil
        }
        let containerView = transitionContext.containerView
        
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
            return isPush || viewController.isViewLoaded && viewController.view == fromView
        }
        let topView = isPush ? toView : fromView
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: topView)
        
        toTransitionable.setVisibleTransitionState(false)
        fromTransitionable.setVisibleTransitionState(true)
        
        toView.frame = context.finalFrame(for: context.viewController(forKey: UITransitionContextViewControllerKey.to)!)
        toView.layoutIfNeeded()
        
        let imageSnapshot = UIImageView(image: fromImageView.image)
        imageSnapshot.contentMode = fromImageView.contentMode
        imageSnapshot.frame = fromImageView.convert(fromImageView.bounds, to: containerView)
        containerView.addSubview(imageSnapshot)
        
        fromImageView.isHidden = true
        toImageView.isHidden = true
        
        UIView.animate(withDuration: ImageTransition.duration, animations: {
            self.toTransitionable.setVisibleTransitionState(!self.cancelled())
            self.fromTransitionable.setVisibleTransitionState(self.cancelled())
            imageSnapshot.frame = self.toImageView.convert(self.toImageView.bounds, to: self.containerView)
            }, completion: { _ in
                self.fromImageView.isHidden = false
                self.toImageView.isHidden = false
                self.toTransitionable.setVisibleTransitionState(!self.cancelled())
                self.fromTransitionable.setVisibleTransitionState(self.cancelled())
                imageSnapshot.removeFromSuperview()
                self.context.completeTransition(!self.cancelled())
        })
    }
    
    func cancelled() -> Bool {
        return self.context.transitionWasCancelled
    }
    
    static func build(_ selectedItem: SearchResult, navigationController: UINavigationController) -> (UIViewControllerContextTransitioning) -> ImageTransition? {
        return {
            transitionContext in
            self.init(selectedItem: selectedItem, navigationController: navigationController, transitionContext: transitionContext)
        }
    }
}
