import UIKit
import SafariServices
import AVFoundation

class SearchyController: UIViewController, UINavigationControllerDelegate {
	let model: SearchyModel = SearchyModel(searchService: ItunesSearchService(networkLayer: URLSessionNetworkLayer()))
    let player = AVQueuePlayer()
    private let context: ApplicationContext
    private var transition: Transition?
    
    init(context: ApplicationContext) {
        self.context = context
		super.init(nibName: nil, bundle: nil)
		title = "searchy"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	// if using Storyboards/XIBs the bindView(...) call would live in viewDidLoad()
	override func loadView() {
		let searchyView = SearchyView(imageProvider: context.imageProvider)
		SearchyBinding.bindView(searchyView, model: model, selectionHandler: self.selectionHandler)
		view = searchyView
	}
	
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.delegate = nil
    }
    
    lazy var selectionHandler:(SearchResult)->() = { [weak self] in
        guard let this = self,
            let navigationController = this.navigationController else { self?.transition = nil; return }
        
        this.transition = Transition(selectedItem: $0, navigationController: navigationController)
        let item = SearchyDisplayItem(result: $0, imageProvider: this.context.imageProvider)
        let snapshot = this.view.snapshotView(afterScreenUpdates: false)
        navigationController.pushViewController(SearchyDetailController(item: item, snapshot: snapshot!), animated: true)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
}
