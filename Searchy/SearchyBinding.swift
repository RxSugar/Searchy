import Foundation
import ReactiveCocoa

final class SearchyBinding {
    static func bind(model model:SearchyModel, view:SearchyView, selectionHandler:(SearchResult)->()) {
        view.searchResults <~ model.searchResults
        model.searchTerm <~ view.searchTerm
        view.selectionStream.observeNext(selectionHandler)
    }
}
