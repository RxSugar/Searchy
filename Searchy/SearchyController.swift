import UIKit
import ReactiveCocoa

class SearchyController: UIViewController {
	let model:SearchyModel = SearchyModel()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Searchy"
	}

	override func loadView() {
		super.loadView()
		let view = SearchyView()
		SearchyPresenter.bind(model: model, view: view)
		self.view = view
	}
}
