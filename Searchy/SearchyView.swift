import UIKit
import RxSwift
import RxSugar

let StandardTouchSize = CGFloat(44)

class SearchyView: UIView, SearchyImageTransitionable {
	fileprivate let disposeBag = DisposeBag()
    fileprivate let tableHandler:TableHandler
    fileprivate let textField = UITextField()
    
    let searchResults = Variable<SearchResults>([])
    let selectionEvents:Observable<SearchResult>
    
    var searchTerm:Observable<String>
    
    init(imageProvider: ImageProvider) {
        tableHandler = TableHandler(imageProvider: imageProvider)
        selectionEvents = tableHandler.selectionEvents
        searchTerm = textField.rxs.text.debounce(0.33, scheduler: MainScheduler.instance)
        
        super.init(frame: CGRect.zero)
        
        tableHandler.parent = self
        
        disposeBag ++ tableHandler.data <~ searchResults
        
        textField.placeholder = "Search..."
        textField.backgroundColor = UIColor(white: 0.925, alpha: 1.0)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.clearButtonMode = .always
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        self.addSubview(textField)
        
        self.addSubview(tableHandler.view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setVisibleTransitionState(_:Bool) {}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentSize = self.bounds
        let textFieldHeight = max(textField.sizeThatFits(CGSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)).height, StandardTouchSize)
        
        textField.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: textFieldHeight)
        tableHandler.view.frame = CGRect(x: 0, y: textFieldHeight, width: contentSize.width, height: contentSize.height - textFieldHeight)
        
        let sizeForSquare = (self.bounds.width - 30) / 2
        tableHandler.layout.itemSize = CGSize(width: sizeForSquare, height: sizeForSquare + 20)
    }
    
    func imageRectForItem(_ item: SearchResult) -> CGRect {
        let rowIndex = searchResults.value.index(of: item) ?? 0
        guard let cell = tableHandler.view.cellForItem(at: IndexPath(row: rowIndex, section: 0)) as? SearchyCell else { return CGRect.zero }
        
        return cell.convert(cell.imageRect(), to: self)
    }
    
    func imageViewForItem(_ item: SearchResult) -> UIImageView? {
        let rowIndex = searchResults.value.index(of: item) ?? 0
        guard let cell = tableHandler.view.cellForItem(at: IndexPath(row: rowIndex, section: 0)) as? SearchyCell else { return nil }
        
        return cell.imageView
    }
    
    class TableHandler : UICollectionViewFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
		fileprivate let disposeBag = DisposeBag()
        weak var parent:SearchyView?
        let view:UICollectionView
        let data = Variable<SearchResults>([])
        fileprivate let imageProvider:ImageProvider
		fileprivate let selectionEventsPublisher = PublishSubject<SearchResult>()
		let selectionEvents:Observable<SearchResult>
        let layout = UICollectionViewFlowLayout()
        
        init(imageProvider: ImageProvider) {
			selectionEvents = selectionEventsPublisher.asObservable()
            self.imageProvider = imageProvider
            view = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
            
            super.init()
            
            layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
            
            view.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            view.register(SearchyCell.self, forCellWithReuseIdentifier: SearchyCell.reuseIdentifier)
            view.dataSource = self
            view.delegate = self
            view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
            view.backgroundColor = UIColor.white
            
            data.asObservable().subscribeNext { [unowned self] _ in
                self.view.reloadData()
            }.addDisposableTo(disposeBag)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return data.value.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchyCell.reuseIdentifier, for: indexPath) as? SearchyCell else {
                fatalError()
            }
            
            cell.populateCell(SearchyDisplayItem(result: data.value[indexPath.row], imageProvider: imageProvider))
            
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            parent?.textField.resignFirstResponder()
            selectionEventsPublisher.onNext(data.value[indexPath.row])
        }
    }
}
