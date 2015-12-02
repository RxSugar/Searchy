import XCTest
import ReactiveCocoa
@testable import Searchy

struct FakeSearchService: SearchService {
    let searchOperation:(String, (ServiceResponse<SearchResults>) -> ()) -> ()
    
    func search(searchTerm: String, completion: (ServiceResponse<SearchResults>) -> ()) {
        searchOperation(searchTerm, completion)
    }
}

class SearchyModelTests: XCTestCase {
    let resultOne = SearchResult(artist: "One", songTitle: "hello", resultUrl: NSURL(string: "http://www.google.com")!, iconUrl: NSURL(string: "http://www.google.com")!)
    let resultTwo = SearchResult(artist: "Two", songTitle: "hello", resultUrl: NSURL(string: "http://www.google.com")!, iconUrl: NSURL(string: "http://www.google.com")!)
    let resultThree = SearchResult(artist: "Three", songTitle: "hello", resultUrl: NSURL(string: "http://www.google.com")!, iconUrl: NSURL(string: "http://www.google.com")!)
    
    let results = MutableProperty(SearchResults())
    
    func synchronousSearchService() -> FakeSearchService {
        return FakeSearchService { term, completion in
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
            case "BadSearch":
                completion(ServiceResponse(error: NSError(domain: "Ack!", code: 723, userInfo: nil)))
            default:
                completion(ServiceResponse(value: [self.resultTwo, self.resultThree]))
            }
        }
    }
    
    func testWhenEmptyStringIsSearchedThenResultsAreEmpty() {
        let model = SearchyModel(searchService: synchronousSearchService())
        results <~ model.searchResults
        model.searchTerm.value = "Stuff"
        
        model.searchTerm.value = ""
        
        XCTAssertEqual(results.value, [])
    }
    
    func testWhenWhitespaceIsSearchedThenResultsAreEmpty() {
        let model = SearchyModel(searchService: synchronousSearchService())
        results <~ model.searchResults
        model.searchTerm.value = "Stuff"
        
        model.searchTerm.value = " \n  "
        
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
        
        let searchService = FakeSearchService { term, completion in
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
