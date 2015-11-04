import UIKit
import ReactiveCocoa

let StandardTouchSize = CGFloat(44)

enum ViewState<T> {
	case Loading
	case Normal(T)
	case Error(String)
	case None
}

class SearchyController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	let textField = UITextField()
	let tableView = UITableView()

	let model:SearchyModel = SearchyModel()
	let viewState = MutableProperty<ViewState<SearchResults>>(.None)
	var searchTermStream = SignalProducer<String, NSError>(value: "")

	var results:[SearchResult] = []{
		didSet {
			tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = "Searchy"

		textField.placeholder = "Search..."
		textField.backgroundColor = UIColor.whiteColor()
		textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
		textField.leftViewMode = .Always
		textField.layer.borderWidth = 0.5
		textField.layer.borderColor = UIColor.lightGrayColor().CGColor
		searchTermStream = textField.rac_textSignal().toSignalProducer().map { $0 as! String }.throttle(0.33, onScheduler: QueueScheduler.mainQueueScheduler)

		tableView.delegate = self
		tableView.dataSource = self

		SearchyPresenter.bind(model: model, view: self)
	}

	override func loadView() {
		super.loadView()
		let contentSize = UIScreen.mainScreen().bounds
		let textFieldHeight = max(textField.sizeThatFits(CGSize(width: contentSize.width, height: CGFloat.max)).height, StandardTouchSize)
		textField.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: textFieldHeight)
		tableView.frame = CGRect(x: 0, y: textFieldHeight, width: contentSize.width, height: contentSize.height - textFieldHeight)
		self.view.addSubview(textField)
		self.view.addSubview(tableView)
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection: Int) -> Int {
		return results.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier("Cell")

		if cell == nil {
			cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
		}

		let result = results[indexPath.row]

		cell!.textLabel!.text = result.name
		cell!.detailTextLabel!.text = result.description

		return cell!
	}

	// TODO: make this more RACified

//	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//		return 1
//	}
//
//	func tableView(tableView: UITableView, numberOfRowsInSection: Int) -> Int {
//		if case .Error = viewState.value { return 0 } // TODO: show an error
//		if case .Loading = viewState.value { return 1 }
//		if case .None = viewState.value { return 0 } // TODO: all of this kind of sucks
//		guard case .Normal(let results) = viewState.value else { return 0 }
//		return results.count
//	}
//
//	// I don't love this at all....
//	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//		var name:String = ""
//		var description:String?
//
//		switch viewState.value {
//		case .Error(_):
//			fatalError()
//			break
//		case .Loading:
//			name = "Loading.."
//			break
//		case .Normal(let results):
//			name = results[indexPath.row].name
//			description = results[indexPath.row].description
//			break
//		case .None:
//			break;
//		}
//
//		var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
//
//		if cell == nil {
//			cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
//		}
//
//		cell!.textLabel!.text = name
//		cell!.detailTextLabel!.text = description
//
//		return cell!
//	}
}
