import Foundation
import ReactiveCocoa

final class SearchyPresenter {
	static func bind(model model:SearchyModel, view:SearchyController) {

		view.searchTermStream.startWithNext { searchTerm in
			model.searchTerm(searchTerm) { searchResults in
				view.results = searchResults
			}
		}

//		view.viewState <~ model.searchResultChanges.producer.map { searchResults in
//			.Normal(searchResults)
//		}
	}
}