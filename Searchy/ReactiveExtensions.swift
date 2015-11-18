import UIKit
import ReactiveCocoa

extension UITextField {
    func textChanges() -> SignalProducer<String, NoError> {
        return self.rac_textSignal().toSignalProducer()
            .map { $0 as! String }
            .flatMapError { _ in SignalProducer<String, NoError>.empty }
    }
}

public func <~ <T>(property: T -> (), producer: SignalProducer<T, NoError>) -> Disposable {
    return producer.startWithNext(property)
}

public func <~ <T>(property: T -> (), signal: Signal<T, NoError>) -> Disposable? {
    return signal.observeNext(property)
}
