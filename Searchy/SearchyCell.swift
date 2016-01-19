import UIKit
import ReactiveCocoa
import RxSwift

class SearchyCell : UICollectionViewCell {
    static let reuseIdentifier = "\(SearchyCell.self)"
    
    override var reuseIdentifier:String {
        return SearchyCell.reuseIdentifier
    }
    
    let imageSubject = PublishSubject<UIImage?>()
    var disposeBag2 = DisposeBag()
    var disposeBag = DisposeBag()
    let imageView = UIImageView()
    private let label = UILabel()
    
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
        label.font = label.font.fontWithSize(14.0)
        label.textColor = UIColor.darkGrayColor()
        label.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(label)
        
        item.producer.startWithNext { [unowned self] item in
            self.label.text = "\(item.artist) - \(item.songTitle)"
        }
        
        imageSubject.subscribeNext {
            print("setting image: \($0)")
            self.imageView.image = $0
        }.addDisposableTo(disposeBag2)
    }
    
    func populateCell(cellItem: SearchyDisplayItem) {
        self.cellItem = cellItem
        item.value = cellItem.result
        
//        cellItem.image.subscribe(imageSubject).addDisposableTo(disposeBag)
        
        cellItem.image.subscribeNext {
            self.imageSubject.onNext($0)
        }.addDisposableTo(disposeBag)
        
        
//        cellItem.image.subscribeNext {
//            self.imageView.image = $0
//        }.addDisposableTo(disposeBag)
    }
    
    override func prepareForReuse() {
        imageSubject.onNext(nil)
        print("disposed? \(imageSubject.disposed)")
        //disposeBag = DisposeBag()
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