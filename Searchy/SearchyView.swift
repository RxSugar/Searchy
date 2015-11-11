import UIKit
import ReactiveCocoa

let StandardTouchSize = CGFloat(44)

class SearchyView: UIView, UITableViewDelegate, UITableViewDataSource {
	private let tableView = UITableView()
	private let textField = UITextField()
    
    let selectionStream:Signal<SearchResult, NoError>
    private let selectionObserver:Observer<SearchResult, NoError>

	let searchResults = MutableProperty<SearchResults>([])
    
	var searchTerm:SignalProducer<String, NoError>

	override init(frame: CGRect) {
        (selectionStream, selectionObserver) = Signal<SearchResult, NoError>.pipe()
        
		searchTerm = textField.textChanges().throttle(0.33, onScheduler: QueueScheduler.mainQueueScheduler)

		super.init(frame: frame)

		searchResults.producer.startWithNext { [unowned self] _ in
			self.tableView.reloadData()
		}

		self.backgroundColor = UIColor.whiteColor()

		textField.placeholder = "Search..."
		textField.backgroundColor = UIColor.whiteColor()
		textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
		textField.leftViewMode = .Always
		textField.layer.borderWidth = 0.5
		textField.layer.borderColor = UIColor.lightGrayColor().CGColor
		self.addSubview(textField)

		tableView.delegate = self
		tableView.dataSource = self
		self.addSubview(tableView)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		let contentSize = self.bounds
		let textFieldHeight = max(textField.sizeThatFits(CGSize(width: contentSize.width, height: CGFloat.max)).height, StandardTouchSize)

		textField.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: textFieldHeight)
		tableView.frame = CGRect(x: 0, y: textFieldHeight, width: contentSize.width, height: contentSize.height - textFieldHeight)
	}

	func tableView(tableView: UITableView, numberOfRowsInSection: Int) -> Int {
		return searchResults.value.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell") ?? UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")

		let result = searchResults.value[indexPath.row]
		cell.textLabel!.text = result.text
		cell.detailTextLabel!.text = result.resultUrl.absoluteString

		return cell
	}
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectionObserver.sendNext(searchResults.value[indexPath.row])
    }
}