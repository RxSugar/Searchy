import UIKit
import ReactiveCocoa
import SafariServices

class SearchyController: UIViewController {
	let model:SearchyModel = SearchyModel(searchService: DuckDuckGoSearchService(networkLayer: NetworkLayer()))

    override func loadView() {
        self.title = "Searchy"
        
		let view = SearchyView()
		SearchyBinding.bind(model: model, view: view, selectionHandler: self.selectionHandler)
		self.view = view
	}
    
    lazy var selectionHandler:(SearchResult)->() = { [weak self] in
        self?.presentViewController(SFSafariViewController(URL: $0.resultUrl), animated: true, completion: nil)
    }
}
