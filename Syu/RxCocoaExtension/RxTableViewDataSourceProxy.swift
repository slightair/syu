import Foundation
import Cocoa
import RxSwift
import RxCocoa

let tableViewDataSourceNotSet = TableViewDataSourceNotSet()

class TableViewDataSourceNotSet
    : NSObject
    , NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return 0
    }
}

/// For more information take a look at `DelegateProxyType`.
public class RxTableViewDataSourceProxy
    : DelegateProxy
    , NSTableViewDataSource
    , DelegateProxyType {

    /// Typed parent object.
    public weak fileprivate(set) var tableView: NSTableView?

    // issue https://github.com/ReactiveX/RxSwift/issues/907
    private var _numberOfObservers = 0
    private var _commitForRowAtSequenceSentMessage: CachedCommitForRowAt? = nil
    private var _commitForRowAtSequenceMethodInvoked: CachedCommitForRowAt? = nil

    fileprivate class Counter {
        var hasObservers: Bool = false
    }

    fileprivate class CachedCommitForRowAt {
        let sequence: Observable<[Any]>
        let counter: Counter

        var hasObservers: Bool {
            return counter.hasObservers
        }

        init(sequence: Observable<[Any]>, counter: Counter) {
            self.sequence = sequence
            self.counter = counter
        }

        static func createFor(commitForRowAt: Observable<[Any]>, proxy: RxTableViewDataSourceProxy) -> CachedCommitForRowAt {
            let counter = Counter()

            let commitForRowAtSequence = commitForRowAt.do(onSubscribe: { [weak proxy] in
                counter.hasObservers = true
                proxy?.refreshTableViewDataSource()
            }, onDispose: { [weak proxy] in
                counter.hasObservers = false
                proxy?.refreshTableViewDataSource()
            })
                .subscribeOn(MainScheduler())
                .share()

            return CachedCommitForRowAt(sequence: commitForRowAtSequence, counter: counter)
        }
    }

    fileprivate weak var _requiredMethodsDataSource: NSTableViewDataSource? = tableViewDataSourceNotSet

    /// Initializes `RxTableViewDataSourceProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: AnyObject) {
        self.tableView = (parentObject as! NSTableView)
        super.init(parentObject: parentObject)
    }

    // MARK: delegate

    public func numberOfRows(in tableView: NSTableView) -> Int {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).numberOfRows!(in: tableView)
    }

    // MARK: proxy

    /// For more information take a look at `DelegateProxyType`.
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let tableView = (object as! NSTableView)
        return castOrFatalError(tableView.createRxDataSourceProxy())
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let tableView: NSTableView = castOrFatalError(object)
        tableView.dataSource = castOptionalOrFatalError(delegate)
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let tableView: NSTableView = castOrFatalError(object)
        return tableView.dataSource
    }

    /// For more information take a look at `DelegateProxyType`.
    public override func setForwardToDelegate(_ forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let requiredMethodsDataSource: NSTableViewDataSource? = castOptionalOrFatalError(forwardToDelegate)
        _requiredMethodsDataSource = requiredMethodsDataSource ?? tableViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }

    // https://github.com/ReactiveX/RxSwift/issues/907
    private func refreshTableViewDataSource() {
        if self.tableView?.dataSource === self {
            self.tableView?.dataSource = nil
            self.tableView?.dataSource = self
        }
    }
}
