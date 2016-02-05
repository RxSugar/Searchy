import XCTest
import RxSwift
import RxSugar
@testable import Searchy

struct FakeSearchService: SearchService {
    let searchOperation:(String -> Observable<[SearchResult]>)
	
	func search(searchTerm: String) -> Observable<[SearchResult]> {
		return searchOperation(searchTerm)
	}
}

class SearchyModelTests: XCTestCase {
	static let url =  NSURL(string: "http://www.asynchrony.com")!
    let resultOne = SearchResult(artist: "One", songTitle: "hello", resultUrl: SearchyModelTests.url, iconUrl: SearchyModelTests.url)
    let resultTwo = SearchResult(artist: "Two", songTitle: "hello", resultUrl: SearchyModelTests.url, iconUrl: SearchyModelTests.url)
    let resultThree = SearchResult(artist: "Three", songTitle: "hello", resultUrl: SearchyModelTests.url, iconUrl: SearchyModelTests.url)
    
    let results = Variable(SearchResults())
    
    func synchronousSearchService() -> FakeSearchService {
        return FakeSearchService { term in
            switch term {
            case "1": fallthrough
            case "Stuff":
                return Observable.just([self.resultOne])
			case "2":
				return Observable.just([self.resultTwo])
			case "3":
				return Observable.just([self.resultThree])
			case "things":
				return Observable.just([self.resultOne, self.resultTwo, self.resultThree])
			case "BadSearch":
				return Observable.error(NSError(domain: "Ack!", code: 723, userInfo: nil))
			default:
				return Observable.just([self.resultTwo, self.resultThree])
            }
        }
    }
    
    func testWhenEmptyStringIsSearchedThenResultsAreEmpty() {
        let model = SearchyModel(searchService: synchronousSearchService())
        _ = results <~ model.searchResults
        model.searchTerm.value = "Stuff"
        
        model.searchTerm.value = ""
        
        XCTAssertEqual(results.value, [])
    }
    
    func testWhenWhitespaceIsSearchedThenResultsAreEmpty() {
        let model = SearchyModel(searchService: synchronousSearchService())
        _ = results <~ model.searchResults
        model.searchTerm.value = "Stuff"
        
        model.searchTerm.value = " \n  "
        
        XCTAssertEqual(results.value, [])
    }
    
    func testWhenResultIsReturnedThenResultsAreCorrect() {
        let model = SearchyModel(searchService: synchronousSearchService())
        _ = results <~ model.searchResults
        
        model.searchTerm.value = "Stuff"
        
        XCTAssertEqual(results.value, [resultOne])
    }
    
    func testWhenResultIsReturnedAsAnErrorThenResultsAreEmptyArray() {
        let model = SearchyModel(searchService: synchronousSearchService())
        _ = results <~ model.searchResults
        model.searchTerm.value = "Stuff"
        
        model.searchTerm.value = "BadSearch"
        
        XCTAssertEqual(results.value, [])
    }
    
	func testWhenResultsComeOutOfOrderThenResultsForTheCurrentSearchArePopulated() {
		let stream1 = PublishSubject<SearchResults>()
		let stream2 = PublishSubject<SearchResults>()
		let stream3 = PublishSubject<SearchResults>()
		
        let searchService = FakeSearchService { term in
            switch term {
            case "1": return stream1
            case "2": return stream2
            case "3": return stream3
            default: return Observable<SearchResults>.never()
            }
        }

        let model = SearchyModel(searchService: searchService)
        _ = results <~ model.searchResults
        
        model.searchTerm.value = "1"
        model.searchTerm.value = "2"
        model.searchTerm.value = "3"
		
		stream2.onNext([resultTwo])
		stream3.onNext([resultThree])
		stream1.onNext([resultOne])
        
        XCTAssertEqual(results.value, [self.resultThree])
    }
}
