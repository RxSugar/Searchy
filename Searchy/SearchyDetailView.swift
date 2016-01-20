import UIKit
import RxSwift

class SearchyDetailView: UIView, SearchyImageTransitionable {
    private let margin:CGFloat = 10.0
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let item:SearchyDisplayItem
    private let backgroundSnapshot:UIView
    private let blurView:UIVisualEffectView
    private let blurEffect = UIBlurEffect(style: .Light)
    private let disposeBag = DisposeBag()
    
    init(item: SearchyDisplayItem, backgroundSnapshot: UIView) {
        self.item = item
        self.backgroundSnapshot = backgroundSnapshot
        self.blurView = UIVisualEffectView(effect: blurEffect)
        
        super.init(frame: CGRectZero)
        
        addSubview(backgroundSnapshot)
        addSubview(blurView)
        addSubview(titleLabel)
        
        imageView.contentMode = .ScaleAspectFit
        addSubview(imageView)
        backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        
        titleLabel.text = "\(item.result.artist) - \(item.result.songTitle)"
        item.image.asObservable().subscribeNext { [weak self] in
            self?.imageView.image = $0
        }.addDisposableTo(disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundSnapshot.frame = bounds
        blurView.frame = bounds
        
        let labelHeight = titleLabel.sizeThatFits(bounds.size).height
        titleLabel.frame = CGRectMake(0, margin, bounds.width, labelHeight).insetBy(dx: margin, dy: 0)
        
        let imageSide = bounds.insetBy(dx: margin, dy: 0).width
        imageView.frame = CGRectMake(margin, titleLabel.frame.maxY + margin, imageSide, imageSide)
    }
    
    func imageViewForItem(item: SearchResult) -> UIImageView? {
        return imageView
    }
    
    func setVisibleTransitionState(visible: Bool) {
        blurView.effect = visible ? blurEffect : nil
        titleLabel.alpha = visible ? 1.0 : 0.0
    }
}