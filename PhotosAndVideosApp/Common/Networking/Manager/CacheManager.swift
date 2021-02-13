

import Foundation

final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: Date
    private let entryTime: TimeInterval

    init(dateProvider: Date = Date(), entryTime: TimeInterval = CacheConstants.timeToLive.rawValue ) {
        self.dateProvider = dateProvider
        self.entryTime = entryTime
        wrapped.countLimit = Int(CacheConstants.cacheCountLimit.rawValue)
        wrapped.totalCostLimit = Int(CacheConstants.cacheTotalCostLimit.rawValue)
    }

    func insert(_ value: Value, forKey key: Key, costLimit: Int) {
        let date = dateProvider.addingTimeInterval(entryTime)
        let entry = Entry(value: value, expiryDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key), cost: costLimit)
    }

    func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else { return nil }
        guard dateProvider < entry.expiryDate else {
            // Discard old value.
            removeValue(forKey: key)
            return nil
        }
        return entry.value
    }

    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }

    func removeAll() {
        wrapped.removeAllObjects()
    }

}

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

private extension Cache {
    final class Entry {
        let value: Value
        let expiryDate: Date

        init(value: Value, expiryDate: Date) {
            self.value = value
            self.expiryDate = expiryDate
        }
    }
}
