import XCTest
import Searchy
import RxSwift

class RxVariableBindingTests: XCTestCase {
    
    func testVariableBindingOperator() {
        let testObject = Variable(1)
        let source1 = Variable(2)
        let source2 = Variable(3)
        
        let disposable = testObject <~ source1
        XCTAssertEqual(testObject.value, 2)
        
        _ = testObject <~ source2
        XCTAssertEqual(testObject.value, 3)
        
        disposable.dispose()
        source1.value = 4
        XCTAssertEqual(testObject.value, 3)
        
        source2.value = 5
        XCTAssertEqual(testObject.value, 5)
    }
    
    func testObserverBindingOperator() {
        let testObject = PublishSubject<Int>()
        let latestRecordedValue = Variable<Int>(1)
        _ = latestRecordedValue <~ testObject
        let source1 = Variable(2)
        let source2 = Variable(3)
        
        let disposable = testObject <~ source1.asObservable()
        XCTAssertEqual(latestRecordedValue.value, 2)
        
        _ = testObject <~ source2.asObservable()
        XCTAssertEqual(latestRecordedValue.value, 3)
        
        disposable.dispose()
        source1.value = 4
        XCTAssertEqual(latestRecordedValue.value, 3)
        
        source2.value = 5
        XCTAssertEqual(latestRecordedValue.value, 5)
    }
    
    func testCompositeAddDisposableOperator() {
        let destination1 = Variable(1)
        let destination2 = Variable(1)
        let source1 = Variable(2)
        let source2 = Variable(3)
        
        let disposable = CompositeDisposable()
            ++ destination1 <~ source1
            ++ destination2 <~ source2
        
        source1.value = 4
        source2.value = 5
        XCTAssertEqual(destination1.value, 4)
        XCTAssertEqual(destination2.value, 5)
        
        disposable.dispose()
        
        source1.value = 6
        source2.value = 7
        XCTAssertEqual(destination1.value, 4)
        XCTAssertEqual(destination2.value, 5)
    }
    
    func testBagAddDisposableOperator() {
        let destination1 = Variable(1)
        let destination2 = Variable(1)
        let source1 = Variable(2)
        let source2 = Variable(3)
        
        var bag:DisposeBag? = DisposeBag()
            ++ destination1 <~ source1
            ++ destination2 <~ source2
        
        source1.value = 4
        source2.value = 5
        XCTAssertEqual(destination1.value, 4)
        XCTAssertEqual(destination2.value, 5)
        
        bag = nil
        
        source1.value = 6
        source2.value = 7
        XCTAssertEqual(destination1.value, 4)
        XCTAssertEqual(destination2.value, 5)
        
        _ = bag // suppress variable not read warning
    }
}
