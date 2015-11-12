import UIKit
import ReactiveCocoa
import SafariServices
import AVFoundation

class SearchyController: UIViewController {
	let model:SearchyModel = SearchyModel(searchService: DuckDuckGoSearchService(networkLayer: NetworkLayer()))
    let player = AVQueuePlayer()

    override func loadView() {
        self.title = "searchy"
        
		let view = SearchyView()
		SearchyBinding.bind(model: model, view: view, selectionHandler: self.selectionHandler)
		self.view = view
	}
    
    lazy var selectionHandler:(SearchResult)->() = { [weak self] in
        self?.player.removeAllItems()
        self?.player.insertItem(AVPlayerItem(URL: $0.resultUrl), afterItem: nil)
        self?.player.play()
//        self?.presentViewController(SFSafariViewController(URL: $0.resultUrl), animated: true, completion: nil)
    }
}
