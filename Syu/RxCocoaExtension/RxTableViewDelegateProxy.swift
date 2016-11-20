import Foundation
import Cocoa
import RxCocoa

public class RxTableViewDelegateProxy
    : DelegateProxy
    , NSTableViewDelegate
    , DelegateProxyType {

    /// Typed parent object.
    weak fileprivate(set) var tableView: NSTableView?

    /// Initializes `RxScrollViewDelegateProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    required public init(parentObject: AnyObject) {
        self.tableView = (parentObject as! NSTableView)
        super.init(parentObject: parentObject)
    }

    // MARK: delegate proxy

    /// For more information take a look at `DelegateProxyType`.
    override public class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let tableView = (object as! NSTableView)
        return castOrFatalError(tableView.createRxDelegateProxy())
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let tableView: NSTableView = castOrFatalError(object)
        tableView.delegate = castOptionalOrFatalError(delegate)
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let tableView: NSTableView = castOrFatalError(object)
        return tableView.delegate
    }
}
