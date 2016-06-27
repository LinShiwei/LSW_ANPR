import Foundation

extension String {
    public func stringByAppendingPathComponent(str: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(str)
    }
}