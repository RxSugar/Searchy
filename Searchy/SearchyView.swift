import UIKit
import ReactiveCocoa

let StandardTouchSize = CGFloat(44)

class SearchyView: UIView {
    private let tableHandler:TableHandler
    private let textField = UITextField()
    
    let searchResults = MutableProperty<SearchResults>([])
    let selectionEvents:Signal<SearchResult, NoError>
    
	var searchTerm:SignalProducer<String, NoError>

    init(imageProvider: ImageProvider) {
        tableHandler = TableHandler(imageProvider: imageProvider)
        selectionEvents = tableHandler.selectionStream
		searchTerm = textField.textChanges().throttle(0.33, onScheduler: QueueScheduler.mainQueueScheduler)

        super.init(frame: CGRectZero)

        tableHandler.data <~ searchResults

		textField.placeholder = "Search..."
		textField.backgroundColor = UIColor(white: 0.925, alpha: 1.0)
		textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
		textField.leftViewMode = .Always
        textField.clearButtonMode = .Always
        textField.returnKeyType = .Done
		self.addSubview(textField)

		self.addSubview(tableHandler.view)
	}
    
	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		let contentSize = self.bounds
		let textFieldHeight = max(textField.sizeThatFits(CGSize(width: contentSize.width, height: CGFloat.max)).height, StandardTouchSize)

		textField.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: textFieldHeight)
		tableHandler.view.frame = CGRect(x: 0, y: textFieldHeight, width: contentSize.width, height: contentSize.height - textFieldHeight)
	}
    
    class TableHandler : UICollectionViewFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
        private let sizeForSquare = 100
        let view:UICollectionView
        let backView = UIView()
        let data = MutableProperty<SearchResults>([])
        private var cachedImages = NSCache()
        private let blankImage = UIImage(named: "blank.png")!
        private var cacheCount = 0
        private let imageProvider:ImageProvider
        let (selectionStream, selectionObserver) = Signal<SearchResult, NoError>.pipe()
        
        init(imageProvider: ImageProvider) {
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width: sizeForSquare, height: sizeForSquare)
            
            self.imageProvider = imageProvider
            
            view = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
            view.registerClass(SearchyCell.self, forCellWithReuseIdentifier: SearchyCell.reuseIdentifier)
            super.init()
            

            view.dataSource = self
            view.delegate = self
            view.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
            view.backgroundColor = UIColor.whiteColor()
            
            backView.backgroundColor = UIColor.whiteColor()
            
            
            data.producer.startWithNext { [unowned self] _ in
                self.view.reloadData()
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return data.value.count
        }
        
        func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SearchyCell.reuseIdentifier, forIndexPath: indexPath) as? SearchyCell else {
                fatalError()
            }
            
            let result = data.value[indexPath.row]
            let image = AnyProperty<UIImage?>(initialValue: nil, producer: imageProvider.imageFromURL(result.iconUrl).map { .Some($0) })
            cell.populateCell(SearchyCellItem(result: result, image: image))
            
            return cell
        }
        
        func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            selectionObserver.sendNext(data.value[indexPath.row])
        }
    }
}