import UIKit
import ReactiveCocoa

class SearchyCell : UICollectionViewCell {
    static let reuseIdentifier = "\(SearchyCell.self)"
    
    override var reuseIdentifier:String {
        return SearchyCell.reuseIdentifier
    }
    
    let imageView = UIImageView()
    private let label = UILabel()
    
    private let image = MutableProperty<UIImage?>(nil)
    private let item = MutableProperty(SearchResult.emptyResult)
    private var cellItem:SearchyDisplayItem?
    
    func imageRect() -> CGRect {
        return imageView.convertRect(imageView.bounds, toView: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRectZero)
        
        imageView.contentMode = .ScaleAspectFit
        self.contentView.addSubview(imageView)
        
        label.textAlignment = .Center
        label.font = label.font.fontWithSize(8.0)
        label.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(label)
        
        item.producer.startWithNext { [unowned self] item in
            self.label.text = "\(item.artist) - \(item.songTitle)"
        }
        
        image.producer.startWithNext {
            self.imageView.image = $0
        }
    }
    
    func populateCell(cellItem: SearchyDisplayItem) {
        self.cellItem = cellItem
        item.value = cellItem.result
        image <~ cellItem.image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellItem = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelHeight = self.label.sizeThatFits(self.bounds.size).height
        label.frame = CGRectMake(0, 0, self.bounds.width, labelHeight)
        imageView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(labelHeight, 0, 0, 0))
    }
}