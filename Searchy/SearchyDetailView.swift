import UIKit
import RxSwift

class SearchyDetailView: UIView, SearchyImageTransitionable {
    fileprivate let margin:CGFloat = 10.0
    fileprivate let imageView = UIImageView()
    fileprivate let titleLabel = UILabel()
    fileprivate let item:SearchyDisplayItem
    fileprivate let backgroundSnapshot:UIView
    fileprivate let blurView:UIVisualEffectView
    fileprivate let blurEffect = UIBlurEffect(style: .light)
    fileprivate let disposeBag = DisposeBag()
    
    init(item: SearchyDisplayItem, backgroundSnapshot: UIView) {
        self.item = item
        self.backgroundSnapshot = backgroundSnapshot
        self.blurView = UIVisualEffectView(effect: blurEffect)
        
        super.init(frame: CGRect.zero)
        
        addSubview(backgroundSnapshot)
        addSubview(blurView)
        addSubview(titleLabel)
        
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
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
        titleLabel.frame = CGRect(x: 0, y: margin, width: bounds.width, height: labelHeight).insetBy(dx: margin, dy: 0)
        
        let imageSide = bounds.insetBy(dx: margin, dy: 0).width
        imageView.frame = CGRect(x: margin, y: titleLabel.frame.maxY + margin, width: imageSide, height: imageSide)
    }
    
    func imageViewForItem(_ item: SearchResult) -> UIImageView? {
        return imageView
    }
    
    func setVisibleTransitionState(_ visible: Bool) {
        blurView.effect = visible ? blurEffect : nil
        titleLabel.alpha = visible ? 1.0 : 0.0
    }
}
