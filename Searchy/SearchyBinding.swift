import Foundation
import RxSwift

final class SearchyBinding {
    static func bind(model model:SearchyModel, view:SearchyView, selectionHandler:(SearchResult)->()) {
		view.rx_disposeBag
			++ view.searchResults <~ model.searchResults
			++ model.searchTerm <~ view.searchTerm
			++ selectionHandler <~ view.selectionEvents
    }
}
