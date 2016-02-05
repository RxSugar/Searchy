import UIKit
import RxSwift
import RxSugar

class SearchyCell : UICollectionViewCell {
    static let reuseIdentifier = "\(SearchyCell.self)"
	private var cellReuseDisposeBag = DisposeBag()
    
    override var reuseIdentifier:String {
        return SearchyCell.reuseIdentifier
    }
    
    let image = Variable<UIImage?>(nil)
    let imageView = UIImageView()
    private let label = UILabel()
    
    private let item = Variable(SearchResult.emptyResult)
    private var cellItem:SearchyDisplayItem?
    
    func imageRect() -> CGRect {
        return imageView.convertRect(imageView.bounds, toView: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRectZero)
        
        imageView.contentMode = .ScaleAspectFit
        self.contentView.addSubview(imageView)
        
        label.textAlignment = .Center
        label.font = label.font.fontWithSize(14.0)
        label.textColor = UIColor.darkGrayColor()
        label.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(label)
        
        item.asObservable().subscribeNext { [unowned self] item in
            self.label.text = "\(item.artist) - \(item.songTitle)"
        }.addDisposableTo(rxs.disposeBag)
		
        image.asObservable().subscribeNext {
            self.imageView.image = $0
        }.addDisposableTo(rxs.disposeBag)
    }
    
    func populateCell(cellItem: SearchyDisplayItem) {
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
        label.frame = CGRectMake(0, 0, bounds.width, labelHeight)
        imageView.frame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(labelHeight, 0, 0, 0))
    }
}