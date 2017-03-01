	
## Model – View – Binding
At Asynchrony Labs some of us have been building iOS apps both large and small for the last few years with a pattern we are now calling Model-View-Binding (MVB).

### Already Popular
There are a number of popular architectural patterns in use on iOS: MVVM, VIPER, and of course Apple’s recommended MVC. Each of these can provide developers with a good starting point for organizing their code.

### Why Another Pattern?
MVC often results in “Massive View Controller” rather than a useful separation of concerns. “MVVM” is Not Very Good” details some problems with the MVVM pattern on iOS. VIPER has many parts and a fairly rigid structure. We have found MVB to be a simpler way to enforce separation of concerns while being flexible enough to work well in a small or a large project.

### Searchy – MVB By Example
Searchy is a small app that uses the MVB pattern with RxSwift to search the iTunes API and display songs and cover art. The example code in this post is taken directly from this project.

### Defining Terms
Many of the common terms used in these patterns do not have a consistent definition, so here is a definition of each term within the context of this article:

*View*: Typically a UIView subclass that provides an interface of data inputs and user event outputs. Think of it as an object that translates information into user actions.

*Model*: This is the portion of your app that manages logic, data, and rules within the app.

*Data Object*: Immutable data used to populate the view, typically a struct or enum.

*Binding*: The binding connects the model and view layers as well as other collaborators when required.

### Observer Pattern
Model-View-Binding relies heavily on the Observer Pattern. When using Objective-C, we use a small eventing library that our own James Rantanen wrote called [ESCObservable]. NSNotificationCenter is also an option, but it suffers from issues such as stringly typed event names and strongly typed parameters. Reactive programming (RxSwift, ReactiveCocoa, etc.) is the observer pattern on steroids and satisfies all prerequisites and compile time safety, which makes it great for implementing MVB in Swift.

### Binding

```swift
static func bindView(view:SearchyView, model:SearchyModel, selectionHandler:(SearchResult)->()) {
    view.rxs.disposeBag
        ++ view.searchResults <~ model.searchResults
        ++ model.searchTerm <~ view.searchTerm
        ++ selectionHandler <~ view.selectionEvents
}
```

The code above is a simple binding using RxSugar and RxSwift, making it easy to see the flow of data through the binding with the `<~` operator. It is possible to build this without the custom operators, as well:

```swift
model.searchResults.bindTo(view.searchResults).addDisposableTo(view.rx_disposeBag)
view.searchTerm.bindTo(model.searchTerm).addDisposableTo(view.rx_disposeBag)
view.selectionEvents.subscribeNext(selectionHandler).addDisposableTo(view.rx_disposeBag)
```

As stated previously, the `<~` operator exists for readability as a custom operator with several overloads that does the binding for us.

### View Controller

```swift
override func loadView() {
    let searchyView = SearchyView(imageProvider: context.imageProvider)
    SearchyBinding.bindView(searchyView, model: model, selectionHandler: self.selectionHandler)
    view = searchyView
}
```

UIKit basically forces UIViewControllers to be involved in navigation and view lifecycle logic. That is more than enough for one unit to handle, if following the _Single Responsibility Principle_. Think of View Controllers as a way to plug into iOS’s navigation systems rather than as a home for an application’s logic or traditional “Controller” code. When using Storyboards or XIBs, the binding would be called in the `viewDidLoad()` method.

### View

```swift
private let disposeBag = DisposeBag()
private let tableHandler:TableHandler
private let textField = UITextField()

private let _searchResults = PublishSubject<SearchResults>([])

let searchResults:AnyObserver<SearchResults>
let selectionEvents:Observable<SearchResult>

init(imageProvider: ImageProvider) {
    tableHandler = TableHandler(imageProvider: imageProvider)
    selectionEvents = tableHandler.selectionEvents
    searchTerm = textField.rxs.text.debounce(0.33, scheduler: MainScheduler.instance)
    searchResults = _searchResults.asObserver()

    super.init(frame: CGRectZero)

    disposeBag ++ tableHandler.data <~ _searchResults
```

The searchResults is exposed as a public Observer for reading the output and a private Subject for passing the data to the tableHandler. Since the search result selection, which is simply an event that corresponds to tapping a collection view cell, is something internal to the view, it is exposed as an Observable. In Searchy, the Binding feeds the selection events to the selection handler closure.

### Model

```swift
class SearchyModel {
   let searchTerm = Variable<String>("")
   let searchResults:Observable<SearchResults>

   init(searchService:SearchService) {
       searchResults = searchTerm.asObservable()
           .map(SearchyModel.stripWhitespace)
           .flatMapLatest(SearchyModel.searchTerm(searchService))
           .catchErrorJustReturn([])
           .share()
   }
```

The searchTerm is exposed as a Variable since it is used as both input and output. This could also be achieved by exposing both an Observable and an Observer. SearchResults is exposed as an Observable since readonly data will flow out from this stream.

### Guidelines
* Views take in immutable data
* Views publish user events in terms of user intent. For instance, prefer `closeRequested` to `closeButtonTapped`.
* Models manage the state of the data
* Models and Views do not have a reference to the Binding
* Bindings in Swift can be a single function that sets up communication between a Model and a View (and other components)
* View Controller code is limited to navigation and view construction/binding

### Rx Guidelines
* Views should expose realtime events
* Models should generally fire the current value upon subscription followed by realtime events for observable state
