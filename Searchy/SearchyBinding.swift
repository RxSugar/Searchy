import Foundation
import ReactiveCocoa

final class SearchyBinding {
    static func bind(model model:SearchyModel, view:SearchyView, selectionHandler:(SearchResult)->()) {
        view.viewState <~ model.searchResults
        model.searchTerm <~ view.searchTerm
        view.selectionStream.observeNext(selectionHandler)
    }
}
