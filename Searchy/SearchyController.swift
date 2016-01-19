import UIKit
import SafariServices
import AVFoundation

class SearchyController: UIViewController, UINavigationControllerDelegate {
	let model:SearchyModel = SearchyModel(searchService: ItunesSearchService(networkLayer: URLSessionNetworkLayer()))
    let player = AVQueuePlayer()
    private let context: ApplicationContext
    private var transition:Transition?
    
    init(context: ApplicationContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.title = "searchy"
        
		let view = SearchyView(imageProvider: context.imageProvider)
		SearchyBinding.bind(model: model, view: view, selectionHandler: self.selectionHandler)
		self.view = view
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.delegate = nil
    }
    
    lazy var selectionHandler:(SearchResult)->() = { [weak self] in
        guard let this = self,
            let navigationController = this.navigationController else { self?.transition = nil; return }
        
        this.transition = Transition(selectedItem: $0, navigationController: navigationController)
        let item = SearchyDisplayItem(result: $0, imageProvider: this.context.imageProvider)
        let snapshot = this.view.snapshotViewAfterScreenUpdates(false)
        navigationController.pushViewController(SearchyDetailController(item: item, snapshot: snapshot), animated: true)
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
}
