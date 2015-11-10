import UIKit
import ReactiveCocoa
import SafariServices

class SearchyController: UIViewController {
	let model:SearchyModel = SearchyModel()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Searchy"
	}

	override func loadView() {
		super.loadView()
		let view = SearchyView()
		SearchyBinding.bind(model: model, view: view, selectionHandler: self.selectionHandler)
		self.view = view
	}
    
    lazy var selectionHandler:(SearchResult)->() = { [weak self] in
        self?.presentViewController(SFSafariViewController(URL: $0.resultUrl), animated: true, completion: nil)
    }
}
