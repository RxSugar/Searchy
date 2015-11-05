import Foundation
import ReactiveCocoa

final class SearchyPresenter {
	static func bind(model model:SearchyModel, view:SearchyView) {
		view.viewState <~ model.searchResults
		model.mutableSearchTerm <~ view.searchTermUpdates
    }
}
