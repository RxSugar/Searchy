import XCTest
import ReactiveCocoa
@testable import Searchy

struct TestSearchService: SearchService {
    let searchOperation:(String, (ServiceResponse<SearchResults>) -> ()) -> ()
    
    func search(searchTerm: String, completion: (ServiceResponse<SearchResults>) -> ()) {
        searchOperation(searchTerm, completion)
    }
}

class SearchyModelTests: XCTestCase {
    let resultOne = SearchResult(text: "One", resultUrl: NSURL(string: "http://www.google.com")!, iconUrl: nil)
    let resultTwo = SearchResult(text: "Two", resultUrl: NSURL(string: "http://www.google.com")!, iconUrl: nil)
    let resultThree = SearchResult(text: "Three", resultUrl: NSURL(string: "http://www.google.com")!, iconUrl: nil)
    
    let results = MutableProperty(SearchResults())
    
    func synchronousSearchService() -> TestSearchService {
        return TestSearchService { term, completion in
            switch term {
            case "1": fallthrough
            case "Stuff":
                completion(ServiceResponse(value: [self.resultOne]))
            case "2":
                completion(ServiceResponse(value: [self.resultTwo]))
            case "3":
                completion(ServiceResponse(value: [self.resultThree]))
            case "things":
                completion(ServiceResponse(value: [self.resultOne, self.resultTwo, self.resultThree]))
            default:
                completion(ServiceResponse(error: NSError(domain: "Ack!", code: 723, userInfo: nil)))
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWhenEmptyStringIsSearchedThenResultsAreEmpty() {
        let model = SearchyModel(searchService: synchronousSearchService())
        results <~ model.searchResults
        model.searchTerm.value = "Stuff"
        
        model.searchTerm.value = ""
        
        XCTAssertEqual(results.value, [])
    }
    
    func testWhenResultIsReturnedThenResultsAreCorrect() {
        let model = SearchyModel(searchService: synchronousSearchService())
        results <~ model.searchResults
        
        model.searchTerm.value = "Stuff"
        
        XCTAssertEqual(results.value, [resultOne])
    }
    
    func testWhenResultIsReturnedAsAnErrorThenResultsAreEmptyArray() {
        let model = SearchyModel(searchService: synchronousSearchService())
        results <~ model.searchResults
        model.searchTerm.value = "Stuff"
        
        model.searchTerm.value = "BadSearch"
        
        XCTAssertEqual(results.value, [])
    }
    
    func testWhenResultsComeOutOfOrderThenResultsForTheCurrentSearchArePopulated() {
        var completionOne:(ServiceResponse<SearchResults>) -> () = { _ in }
        var completionTwo:(ServiceResponse<SearchResults>) -> () = { _ in }
        var completionThree:(ServiceResponse<SearchResults>) -> () = { _ in }
        
        let searchService = TestSearchService { term, completion in
            switch term {
            case "1":
                completionOne = completion
            case "2":
                completionTwo = completion
            case "3":
                completionThree = completion
            default:
                break
            }
        }
        
        let model = SearchyModel(searchService: searchService)
        results <~ model.searchResults
        
        model.searchTerm.value = "1"
        model.searchTerm.value = "2"
        model.searchTerm.value = "3"
        
        completionTwo(ServiceResponse(value: [self.resultTwo]))
        completionThree(ServiceResponse(value: [self.resultThree]))
        completionOne(ServiceResponse(value: [self.resultOne]))
        
        XCTAssertEqual(results.value, [self.resultThree])
    }
}
