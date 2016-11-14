//
//  UIImagePickerController+Rx.swift
//  Rx
//
//  Created by Segii Shulga on 1/4/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if os(iOS)
    import Foundation

#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif
    import UIKit

    extension Reactive where Base: UIImagePickerController {

        /**
         Reactive wrapper for `delegate`.

         For more information take a look at `DelegateProxyType` protocol documentation.
         */
        public var delegate: DelegateProxy {
            return RxImagePickerDelegateProxy.proxyForObject(base)
        }

        /**
         Reactive wrapper for `delegate` message.
         */
        public var didFinishPickingMediaWithInfo: Observable<[String : AnyObject]> {
            return delegate
                .observe(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
                .map({ (a) in
                    return try castOrThrow(Dictionary<String, AnyObject>.self, a[1])
                })
        }

        /**
         Reactive wrapper for `delegate` message.
         */
        public var didCancel: Observable<()> {
            return delegate
                .observe(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
                .map {_ in () }
        }
        
    }
    
#endif

fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: AnyObject) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}
