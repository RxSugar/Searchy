import UIKit
import ReactiveCocoa

class SearchyController: UIViewController {
	let model:SearchyModel = SearchyModel()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Searchy"
		SearchyPresenter.bind(model: model, view: self.view as! SearchyView)
	}

	override func loadView() {
		super.loadView()
		self.view = SearchyView()
	}
}
