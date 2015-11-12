import UIKit
import ReactiveCocoa

let StandardTouchSize = CGFloat(44)

class SearchyView: UIView {
    private let tableHandler = TableHandler()
    private let textField = UITextField()
    
    let searchResults = MutableProperty<SearchResults>([])
    let selectionEvents:Signal<SearchResult, NoError>
    
	var searchTerm:SignalProducer<String, NoError>

	override init(frame: CGRect) {
        selectionEvents = tableHandler.selectionStream
		searchTerm = textField.textChanges().throttle(0.33, onScheduler: QueueScheduler.mainQueueScheduler)
        

		super.init(frame: frame)

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
        private let sizeForSquare = 80
        let view:UICollectionView
        let backView = UIView()
        let data = MutableProperty<SearchResults>([])
        private var cachedImages = [String : UIImage?]()
        private let blankImage = UIImage(named: "blank.png")!
        private var cacheCount = 0
        let (selectionStream, selectionObserver) = Signal<SearchResult, NoError>.pipe()
        
        override init() {
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width: sizeForSquare, height: sizeForSquare)
            
            view = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
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
        
        func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
            let result = data.value[indexPath.row]
            guard let url = result.iconUrl where url.absoluteString != "" else { return }
            guard cachedImages[url.absoluteString] == nil else { return }
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { [weak self] data, response, error in
                guard error == nil else {print("Error: \(error?.localizedDescription) \(url)"); return }
                guard let imageData = data else { print("Bad Data"); return }
                let image = UIImage(data: imageData)
                self?.cachedImages[url.absoluteString] = image
                print("\(self?.cacheCount++)")
                dispatch_async(dispatch_get_main_queue(), {
                    guard let cellToUpdate = self?.view.cellForItemAtIndexPath(indexPath) else { print("Not on screen"); return }
                    cellToUpdate.backgroundView = UIImageView(image: image)
                })
                })
            task.resume()
        }
        
        func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) ?? UICollectionViewCell()
            
            cell.layer.shouldRasterize = true;
            cell.layer.rasterizationScale = UIScreen.mainScreen().scale;
            
            let result = data.value[indexPath.row]
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: sizeForSquare, height: 10))
            label.text = "\(result.artist) - \(result.songTitle)"
            label.textAlignment = .Center
            label.font = label.font.fontWithSize(10.0)
            label.backgroundColor = UIColor.whiteColor()
            cell.contentView.addSubview(label)
            
            guard let url = result.iconUrl, let image = cachedImages[url.absoluteString] else {
                cell.backgroundView = UIImageView(image: blankImage)
                return cell
            }
            
            cell.backgroundView = UIImageView(image: image)
            
            return cell
        }
        
        func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            
            UIView.animateWithDuration(1.0, animations: {
                print("starting animation")
                UIView.transitionFromView((cell?.contentView)!, toView: UIView(), duration: 0.5, options: .TransitionFlipFromRight, completion: nil)
            })
            
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
            selectionObserver.sendNext(data.value[indexPath.row])
        }
    }
    
//    class TableHandler : NSObject, UITableViewDelegate, UITableViewDataSource {
//        let view = UITableView()
//        let data = MutableProperty<SearchResults>([])
//        private var cachedImages = [String : UIImage?]()
//        private let blankImage = UIImage(named: "blank.png")!
//        private var cacheCount = 0
//        let (selectionStream, selectionObserver) = Signal<SearchResult, NoError>.pipe()
//        
//        override init() {
//            super.init()
//            
//            view.delegate = self
//            view.dataSource = self
//            
//            data.producer.startWithNext { [unowned self] _ in
//                self.view.reloadData()
//            }
//        }
//        
//        func tableView(tableView: UITableView, numberOfRowsInSection: Int) -> Int {
//            return data.value.count
//        }
//        
//        func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//            
//            let result = data.value[indexPath.row]
//            guard let url = result.iconUrl where url.absoluteString != "" else { return }
//            guard cachedImages[url.absoluteString] == nil else { return }
//            
//            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { [weak self] data, response, error in
//                guard error == nil else {print("Error: \(error?.localizedDescription) \(url)"); return }
//                guard let imageData = data else { print("Bad Data"); return }
//                let image = UIImage(data: imageData)
//                self?.cachedImages[url.absoluteString] = image
//                print("\(self?.cacheCount++)")
//                dispatch_async(dispatch_get_main_queue(), {
//                    guard let cellToUpdate = self?.view.cellForRowAtIndexPath(indexPath) else { print("Not on screen"); return }
//                    cellToUpdate.imageView?.image = image
//                })
//                })
//            task.resume()
//        }
//        
//        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//            let cell = tableView.dequeueReusableCellWithIdentifier("Cell") ?? UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
//            
//            let result = data.value[indexPath.row]
//            cell.textLabel?.text = result.artist
//            cell.detailTextLabel?.text = "Title: \(result.songTitle)"
//            
//            guard let url = result.iconUrl, let image = cachedImages[url.absoluteString] else { cell.imageView?.image = blankImage; return cell }
//            
//            cell.imageView?.image = image
//            
//            return cell
//        }
//        
//        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//            selectionObserver.sendNext(data.value[indexPath.row])
//        }
//    }
}