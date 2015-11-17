import UIKit

class SearchyDetailView: UIView, SearchyTransitionable {
    private static let margin:CGFloat = 10.0
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let item:SearchyDisplayItem
    private let backgroundSnapshot:UIView
    private let blurView:UIView
    
    init(item: SearchyDisplayItem, backgroundSnapshot: UIView) {
        self.item = item
        self.backgroundSnapshot = backgroundSnapshot
        self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        
        super.init(frame: CGRectZero)
        
        addSubview(backgroundSnapshot)
        addSubview(blurView)
        addSubview(titleLabel)
        
        imageView.contentMode = .ScaleAspectFit
        addSubview(imageView)
        backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        
        titleLabel.text = "\(item.result.artist) - \(item.result.songTitle)"
        item.image.producer.startWithNext { [weak self] in
            self?.imageView.image = $0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundSnapshot.frame = self.bounds
        blurView.frame = self.bounds
        
        let margin = SearchyDetailView.margin
        
        let labelHeight = titleLabel.sizeThatFits(self.bounds.size).height
        titleLabel.frame = CGRectMake(0, margin, self.bounds.width, labelHeight).insetBy(dx: margin, dy: 0)
        
        let imageSide = self.bounds.width - margin * 2
        imageView.frame = CGRectMake(margin, titleLabel.frame.maxY + margin, imageSide, imageSide)
        
    }
    
    func imageViewForItem(item: SearchResult) -> UIImageView? {
        return imageView
    }
}