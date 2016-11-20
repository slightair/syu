import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    func subscribeProxyDataSource<P: DelegateProxyType>(ofObject object: AnyObject, dataSource: AnyObject, retainDataSource: Bool, binding: @escaping (P, Event<E>) -> Void)
        -> Disposable {
            let proxy = P.proxyForObject(object)
            let disposable = P.installForwardDelegate(dataSource, retainDelegate: retainDataSource, onProxyForObject: object)

            let subscription = self.asObservable()
                .catchError { error in
                    bindingErrorToInterface(error)
                    return Observable.empty()
                }
                // source can never end, otherwise it would release the subscriber, and deallocate the data source
                .concat(Observable.never())
                .takeUntil((object as! NSObject).rx.deallocated)
                .subscribe { [weak object] (event: Event<E>) in
                    MainScheduler.ensureExecutingOnScheduler()

                    if let object = object {
                        assert(proxy === P.currentDelegateFor(object), "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(P.currentDelegateFor(object))")
                    }

                    binding(proxy, event)

                    switch event {
                    case .error(let error):
                        bindingErrorToInterface(error)
                        disposable.dispose()
                    case .completed:
                        disposable.dispose()
                    default:
                        break
                    }
            }
            return Disposables.create(subscription, disposable)
    }
}
