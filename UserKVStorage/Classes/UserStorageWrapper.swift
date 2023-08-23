//
//  UserStorageWrapper.swift
//  Pods
//
//  Created by 吴哲 on 2023/8/25.
//

import Foundation

public protocol StorageValueOptionalProtocol {
    associatedtype Wrapped
    var storageValue: Wrapped? { get }
    init(storageValue: Wrapped?)
}

extension Optional: StorageValueOptionalProtocol {
    public var storageValue: Wrapped? {
        self
    }

    public init(storageValue: Wrapped?) {
        self = storageValue
    }
}

/// 存储策略
public protocol UserStorageStrategy {
    associatedtype Value
    init()
    func set(on storage: UserKVStorage, value: Value, forKey key: String, expireRule: UserKVStorage.ExpireRule)
    func get(on storage: UserKVStorage, forKey key: String) -> Value?
}

/// 通用存储
@propertyWrapper
public struct UserStorage<Strategy: UserStorageStrategy> {
    var strategy: Strategy = .init()
    private let storage: UserKVStorage
    private let key: String
    private let expireRule: UserKVStorage.ExpireRule

    public var wrappedValue: Strategy.Value {
        get {
            strategy.get(on: storage, forKey: key)!
        }
        set {
            strategy.set(on: storage, value: newValue, forKey: key, expireRule: expireRule)
        }
    }

    public var projectedValue: Self {
        return self
    }

    public init(
        storage: UserKVStorage = .defaultStorage,
        key: String,
        expireRule: UserKVStorage.ExpireRule = .never
    ) {
        self.storage = storage
        self.key = key
        self.expireRule = expireRule
    }

    public func remove() {
        storage.removeValue(forKey: key)
    }
}

// MARK: - String

public extension UserStorageStrategy where Value == String? {
    func set(on storage: UserKVStorage, value: Value, forKey key: String, expireRule: UserKVStorage.ExpireRule) {
        if let storageValue = value.storageValue {
            storage.set(storageValue, forKey: key, expireRule: expireRule)
        } else {
            storage.removeValue(forKey: key)
        }
    }

    func get(on storage: UserKVStorage, forKey key: String) -> Value? {
        .init(storageValue: storage.string(forKey: key))
    }
}

public struct StringStorageStrategy: UserStorageStrategy {
    public typealias Value = String?
    public init() {}
}

public typealias StringStorage = UserStorage<StringStorageStrategy>

// MARK: - Date

public extension UserStorageStrategy where Value == Date? {
    func set(on storage: UserKVStorage, value: Value, forKey key: String, expireRule: UserKVStorage.ExpireRule) {
        if let storageValue = value.storageValue {
            storage.set(storageValue, forKey: key, expireRule: expireRule)
        } else {
            storage.removeValue(forKey: key)
        }
    }

    func get(on storage: UserKVStorage, forKey key: String) -> Value? {
        .init(storageValue: storage.date(forKey: key))
    }
}

public struct DateStorageStrategy: UserStorageStrategy {
    public typealias Value = Date?
    public init() {}
}

public typealias DateStorage = UserStorage<DateStorageStrategy>

// MARK: - Data

public extension UserStorageStrategy where Value == Data? {
    func set(on storage: UserKVStorage, value: Value, forKey key: String, expireRule: UserKVStorage.ExpireRule) {
        if let storageValue = value.storageValue {
            storage.set(storageValue, forKey: key, expireRule: expireRule)
        } else {
            storage.removeValue(forKey: key)
        }
    }

    func get(on storage: UserKVStorage, forKey key: String) -> Value? {
        .init(storageValue: storage.data(forKey: key))
    }
}

public struct DataStorageStrategy: UserStorageStrategy {
    public typealias Value = Data?
    public init() {}
}

public typealias DataStorage = UserStorage<DataStorageStrategy>

// MARK: - Codable

public extension UserStorageStrategy where Value: StorageValueOptionalProtocol, Value.Wrapped: Codable {
    func set(on storage: UserKVStorage, value: Value, forKey key: String, expireRule: UserKVStorage.ExpireRule) {
        if let storageValue = value.storageValue {
            storage.encode(storageValue, forKey: key, expireRule: expireRule)
        } else {
            storage.removeValue(forKey: key)
        }
    }

    func get(on storage: UserKVStorage, forKey key: String) -> Value? {
        .init(storageValue: storage.decode(forKey: key))
    }
}

public struct CodableStorageStrategy<T: Codable>: UserStorageStrategy {
    public typealias Value = T?
    public init() {}
}

public typealias CodableStorage<T> = UserStorage<CodableStorageStrategy<T>> where T: Codable
