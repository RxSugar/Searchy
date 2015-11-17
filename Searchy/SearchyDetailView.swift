import UIKit

class SearchyDetailView: UIView {
    static let margin:CGFloat = 10.0
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let item:SearchyDisplayItem
    
    init(item: SearchyDisplayItem) {
        self.item = item
        
        super.init(frame: CGRectZero)
        addSubview(titleLabel)
        addSubview(imageView)
        backgroundColor = UIColor.whiteColor()
        
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
        let margin = SearchyDetailView.margin
        
        let labelHeight = titleLabel.sizeThatFits(self.bounds.size).height
        titleLabel.frame = CGRectMake(0, margin, self.bounds.width, labelHeight).insetBy(dx: margin, dy: 0)
        
        let imageSide = self.bounds.width - margin * 2
        imageView.frame = CGRectMake(margin, titleLabel.frame.maxY + margin, imageSide, imageSide)
        
    }
    
}