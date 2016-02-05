import Foundation
import RxSwift
import RxSugar

struct SearchyBinding {
	static func bindView(view:SearchyView, model:SearchyModel, selectionHandler:(SearchResult)->()) {
		view.rxs.disposeBag
			++ view.searchResults <~ model.searchResults
			++ model.searchTerm <~ view.searchTerm
			++ selectionHandler <~ view.selectionEvents
	}
}
