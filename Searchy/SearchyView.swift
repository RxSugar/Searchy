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
    
    class TableHandler : NSObject, UITableViewDelegate, UITableViewDataSource {
        let view = UITableView()
        let data = MutableProperty<SearchResults>([])
        var cachedImages = [String : UIImage]()
        let blankImage = UIImage(named: "blank.png")
        let (selectionStream, selectionObserver) = Signal<SearchResult, NoError>.pipe()
        
        override init() {
            super.init()
            
            view.delegate = self
            view.dataSource = self
            
            data.producer.startWithNext { [unowned self] _ in
                self.view.reloadData()
            }
        }
        
        func tableView(tableView: UITableView, numberOfRowsInSection: Int) -> Int {
            return data.value.count
        }
        
        func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
            
            let result = data.value[indexPath.row]
            guard let url = result.iconUrl where url.absoluteString != "" else { return }
            guard cachedImages[url.absoluteString] == nil else { return }
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { [weak self] data, response, error in
                guard error == nil else {print("Error: \(error?.localizedDescription) \(url)"); return }
                guard let imageData = data else { print("Bad Data"); return }
                let image = UIImage(data: imageData)
                self?.cachedImages[url.absoluteString] = image
                dispatch_async(dispatch_get_main_queue(), {
                    guard let cellToUpdate = self?.view.cellForRowAtIndexPath(indexPath) else { print("Not on screen"); return }
                    cellToUpdate.imageView?.image = image
                })
                })
            task.resume()
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell") ?? UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
            
            let result = data.value[indexPath.row]
            cell.textLabel!.text = result.text
            cell.detailTextLabel!.text = result.resultUrl.absoluteString
            
            guard let url = result.iconUrl, let image = cachedImages[url.absoluteString] else { cell.imageView?.image = blankImage; return cell }
            
            cell.imageView?.image = image
            
            return cell
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            selectionObserver.sendNext(data.value[indexPath.row])
        }
    }
}