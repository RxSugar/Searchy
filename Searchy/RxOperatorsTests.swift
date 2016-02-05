import XCTest
import RxSwift
import RxSugar
@testable import Searchy

class RxOperatorsTests: XCTestCase {

    func testIgnoreNilSkipsNilEvents() {
        let input = Variable<Int?>(1)
        let output = Variable<Int>(0)
        _ = output <~ input.asObservable().ignoreNil()
        
        XCTAssertEqual(output.value, 1)
        
        input.value = nil
        XCTAssertEqual(output.value, 1)
        
        input.value = 42
        XCTAssertEqual(output.value, 42)
    }
    
    func testCombinePreviousSendsTheLatestTwoValues() {
        let input = Variable<Int>(1)
        let output = Variable<(Int, Int)>(0, 0)
        _ = output <~ input.asObservable().combinePrevious { $0 }
        
        input.value = 2
        XCTAssertEqual(output.value.0, 1)
        XCTAssertEqual(output.value.1, 2)
        
        input.value = 3
        XCTAssertEqual(output.value.0, 2)
        XCTAssertEqual(output.value.1, 3)
    }
}
