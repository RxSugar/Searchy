import RxSwift
import Foundation

var disposeBagKey: UInt8 = 0

extension NSObject {
    
    public var rx_disposeBag: DisposeBag {
        objc_sync_enter(self)
        let bag = objc_getAssociatedObject(self, &disposeBagKey) as? DisposeBag ?? rx_createAssociatedDisposeBag()
        objc_sync_exit(self)
        return bag
    }
    
    private func rx_createAssociatedDisposeBag() -> DisposeBag {
        let bag = DisposeBag()
        objc_setAssociatedObject(self, &disposeBagKey, bag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return bag
    }
}