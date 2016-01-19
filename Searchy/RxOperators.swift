import Foundation
import RxSwift

public extension ObservableType {
    public func combinePrevious<R>(resultSelector: (Self.E, Self.E) throws -> R) -> Observable<R> {
        return Observable.zip(self.asObservable(), self.skip(1), resultSelector: resultSelector)
    }
}


public extension ObservableType where E: OptionalType {
    public func ignoreNil() -> Observable<E.Wrapped> {
        return filter { $0.hasValue() }
            .map { $0.optional! }
    }
}