//
//  MainThreadPrimitiveHotObservable.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import XCTest
import Dispatch

class MainThreadPrimitiveHotObservable<ElementType: Equatable> : PrimitiveHotObservable<ElementType> {
    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == E {
        XCTAssertTrue(DispatchQueue.isMain)
        return super.subscribe(observer)
    }
}
