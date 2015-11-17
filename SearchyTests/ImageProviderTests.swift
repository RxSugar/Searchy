import XCTest
@testable import Searchy
import ReactiveCocoa
import Result

func testImageNamed(named: String) -> UIImage! {
    return UIImage(named: named, inBundle: NSBundle(forClass: FakeNetworkLayer.self), compatibleWithTraitCollection: nil)!
}

extension UIImage {
    func pngData() -> NSData! {
        return UIImagePNGRepresentation(self)
    }
}

class FakeNetworkLayer : NetworkLayer {
    static let cloneOne = testImageNamed("clone-1.png")
    static let cloneTwo = testImageNamed("clone-2.png")
    static let cloneThree = testImageNamed("clone-3.png")
    static let cloneFour = testImageNamed("clone-4.png")
    
    func getServiceResponseWithUrl(url:String, completion:(Result<AnyObject, NSError>) -> ()) {  }
    
    func fetchDataFromUrl(url:String, completion:(Result<NSData, NSError>) -> ()) {
        switch url {
        case "http://example.com/one.png":
            completion(.Success(FakeNetworkLayer.cloneOne.pngData()))
        case "http://example.com/two.png":
            completion(.Success(FakeNetworkLayer.cloneTwo.pngData()))
        case "http://example.com/three.png":
            completion(.Success(FakeNetworkLayer.cloneThree.pngData()))
        case "http://example.com/four.png":
            completion(.Success(FakeNetworkLayer.cloneFour.pngData()))
        default:
            completion(.Failure(NSError(domain: "test", code: 42, userInfo: nil)))
        }
    }
}

class ImageProviderTests: XCTestCase {
    let result = MutableProperty(UIImage())
    
    func testWhenImageIsRequestedThenImageIsLoaded() {
        let testObject = ImageProvider(networkLayer: FakeNetworkLayer())
        
        result <~ testObject.imageFromURL(NSURL(string: "http://example.com/one.png")!)
        
        XCTAssertEqual(result.value.pngData(), FakeNetworkLayer.cloneOne.pngData())
    }
    
    func testWhenImageIsRequestedAgainThenCachedImageIsUsed() {
        let testObject = ImageProvider(networkLayer: FakeNetworkLayer())
        
        var count = 0
        result.producer.startWithNext { _ in
            count++
        }
        
        result <~ testObject.imageFromURL(NSURL(string: "http://example.com/two.png")!)
        let firstLoad = result.value
        
        result <~ testObject.imageFromURL(NSURL(string: "http://example.com/two.png")!)
        let secondLoad = result.value
        
        XCTAssertEqual(count, 3) // initial value, then two loads
        XCTAssertTrue(firstLoad === secondLoad)
    }
    
    func testMultipleImagesAreCached() {
        let testObject = ImageProvider(networkLayer: FakeNetworkLayer())
        
        result <~ testObject.imageFromURL(NSURL(string: "http://example.com/two.png")!)
        let firstLoad = result.value
        
        result <~ testObject.imageFromURL(NSURL(string: "http://example.com/three.png")!)
        let secondLoad = result.value
        
        result <~ testObject.imageFromURL(NSURL(string: "http://example.com/two.png")!)
        let thirdLoad = result.value
        
        result <~ testObject.imageFromURL(NSURL(string: "http://example.com/three.png")!)
        let fourthLoad = result.value
        
        XCTAssertEqual(firstLoad.pngData(), FakeNetworkLayer.cloneTwo.pngData())
        XCTAssertEqual(secondLoad.pngData(), FakeNetworkLayer.cloneThree.pngData())
        XCTAssertTrue(firstLoad === thirdLoad)
        XCTAssertTrue(secondLoad === fourthLoad)
    }
    
    
}
