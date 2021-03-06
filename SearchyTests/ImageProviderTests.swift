import XCTest
import RxSwift
import RxSugar
@testable import Searchy

func testImageNamed(_ named: String) -> UIImage! {
    return UIImage(named: named, in: Bundle(for: FakeNetworkLayer.self), compatibleWith: nil)!
}

extension UIImage {
	var pngData: Data! {
        return UIImagePNGRepresentation(self)
    }
}

class FakeNetworkLayer : NetworkLayer {
    static let cloneOne = testImageNamed("clone-1.png")
    static let cloneTwo = testImageNamed("clone-2.png")
    static let cloneThree = testImageNamed("clone-3.png")
    static let cloneFour = testImageNamed("clone-4.png")
	
	func dataFromUrl(_ urlString: String) -> Observable<Data> {
		switch urlString {
		case "http://example.com/one.png":
			return Observable.just(FakeNetworkLayer.cloneOne!.pngData)
		case "http://example.com/two.png":
			return Observable.just(FakeNetworkLayer.cloneTwo!.pngData)
		case "http://example.com/three.png":
			return Observable.just(FakeNetworkLayer.cloneThree!.pngData)
		case "http://example.com/four.png":
			return Observable.just(FakeNetworkLayer.cloneFour!.pngData)
		default:
			return Observable.error(NSError(domain: "test", code: 42, userInfo: nil))
		}
	}
	
	func jsonFromUrl(_ urlString: String) -> Observable<Any> { return Observable.never() }
}

class ImageProviderTests: XCTestCase {
    let result = Variable(UIImage())
    
    func testWhenImageIsRequestedThenImageIsLoaded() {
        let testObject = ImageProvider(networkLayer: FakeNetworkLayer())
        
        _ = result <~ testObject.imageFromURL(URL(string: "http://example.com/one.png")!)
        
        XCTAssertEqual(result.value.pngData, FakeNetworkLayer.cloneOne?.pngData)
    }
    
    func testWhenImageIsRequestedAgainThenCachedImageIsUsed() {
        let testObject = ImageProvider(networkLayer: FakeNetworkLayer())
        
        var count = 0
        _ = result.asObservable().subscribe(onNext: { _ in
            count += 1
        })
        
        _ = result <~ testObject.imageFromURL(URL(string: "http://example.com/two.png")!)
        let firstLoad = result.value
        
        _ = result <~ testObject.imageFromURL(URL(string: "http://example.com/two.png")!)
        let secondLoad = result.value
        
        XCTAssertEqual(count, 3) // initial value, then two loads
        XCTAssertTrue(firstLoad === secondLoad)
    }
    
    func testMultipleImagesAreCached() {
        let testObject = ImageProvider(networkLayer: FakeNetworkLayer())
        
        _ = result <~ testObject.imageFromURL(URL(string: "http://example.com/two.png")!)
        let firstLoad = result.value
        
        _ = result <~ testObject.imageFromURL(URL(string: "http://example.com/three.png")!)
        let secondLoad = result.value
        
        _ = result <~ testObject.imageFromURL(URL(string: "http://example.com/two.png")!)
        let thirdLoad = result.value
        
        _ = result <~ testObject.imageFromURL(URL(string: "http://example.com/three.png")!)
        let fourthLoad = result.value
        
        XCTAssertEqual(firstLoad.pngData, FakeNetworkLayer.cloneTwo?.pngData)
        XCTAssertEqual(secondLoad.pngData, FakeNetworkLayer.cloneThree?.pngData)
        XCTAssertTrue(firstLoad === thirdLoad)
        XCTAssertTrue(secondLoad === fourthLoad)
    }
    
    
}
