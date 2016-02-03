import Foundation
import RxSwift

struct SearchyBinding {
	static func bindView(view:SearchyView, model:SearchyModel, selectionHandler:(SearchResult)->()) {
		view.rx_disposeBag
			++ view.searchResults <~ model.searchResults
			++ model.searchTerm <~ view.searchTerm
			++ selectionHandler <~ view.selectionEvents
	}
}
