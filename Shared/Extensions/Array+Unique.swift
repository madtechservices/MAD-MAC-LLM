import Foundation

extension Sequence {
    
    /// Returns an array containing, in order, the first instances of
    /// elements of the sequence that compare equally for the keyPath.
    public func unique<T: Hashable>(for keyPath: KeyPath<Element, T>) -> [Element] {
        var unique = Set<T>()
        return filter { unique.insert($0[keyPath: keyPath]).inserted }
    }
    
}
