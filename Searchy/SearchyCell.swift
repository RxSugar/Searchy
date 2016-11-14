import UIKit
import RxSwift
import RxSugar

class SearchyCell : UICollectionViewCell {
    static let reuseIdentifier = "\(SearchyCell.self)"
	fileprivate var cellReuseDisposeBag = DisposeBag()
    
    override var reuseIdentifier:String {
        return SearchyCell.reuseIdentifier
    }
    
    let image = Variable<UIImage?>(nil)
    let imageView = UIImageView()
    fileprivate let label = UILabel()
    
    fileprivate let item = Variable(SearchResult.emptyResult)
    fileprivate var cellItem:SearchyDisplayItem?
    
    func imageRect() -> CGRect {
        return imageView.convert(imageView.bounds, to: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imageView)
        
        label.textAlignment = .center
        label.font = label.font.withSize(14.0)
        label.textColor = UIColor.darkGray
        label.backgroundColor = UIColor.white
        self.contentView.addSubview(label)
        
        rxs.disposeBag
            ++ self.label.rxs.text <~ item.asObservable().map { "\($0.artist) - \($0.songTitle)" }
            ++ self.imageView.rxs.image <~ image.asObservable()
    }
    
    func populateCell(_ cellItem: SearchyDisplayItem) {
        self.cellItem = cellItem
        item.value = cellItem.result
		cellReuseDisposeBag ++ image <~ cellItem.image
    }
    
    override func prepareForReuse() {
		cellReuseDisposeBag = DisposeBag()
        super.prepareForReuse()
		self.cellItem = nil
		image.value = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelHeight = self.label.sizeThatFits(self.bounds.size).height
        label.frame = CGRect(x: 0, y: 0, width: bounds.width, height: labelHeight)
        imageView.frame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(labelHeight, 0, 0, 0))
    }
}
