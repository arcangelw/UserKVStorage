//
//  DigitalStorageWrapper.swift
//  Pods
//
//  Created by 吴哲 on 2023/8/24.
//

import Foundation

// MARK: - Digital Storage

/// 数字类型存储策略
public protocol DigitalStorageStrategy: UserStorageStrategy {
    var defaultValue: Value { get set }
}

public extension UserStorage where Strategy: DigitalStorageStrategy {
    init(
        wrappedValue: Strategy.Value,
        storage: UserKVStorage = .defaultStorage,
        key: String,
        expireRule: UserKVStorage.ExpireRule = .never
    ) {
        self = .init(storage: storage, key: key, expireRule: expireRule)
        strategy.defaultValue = wrappedValue
    }
}

// MARK: - Bool Value

/// 布尔类型存储策略
public extension DigitalStorageStrategy where Value == Bool {
    func set(on storage: UserKVStorage, value: Value, forKey key: String, expireRule: UserKVStorage.ExpireRule) {
        storage.set(value, forKey: key, expireRule: expireRule)
    }

    func get(on storage: UserKVStorage, forKey key: String) -> Value? {
        storage.bool(forKey: key, defaultValue: defaultValue)
    }
}

/// Bool类型存储
public struct BoolStorageStrategy: DigitalStorageStrategy {
    public typealias Value = Bool
    public var defaultValue: Value = false
    public init() {}
}

/// Bool类型存储 默认false
public typealias BoolStorage = UserStorage<BoolStorageStrategy>

// MARK: - Int Value

/// Int数据存储策略
public extension DigitalStorageStrategy where Value == Int {
    func set(on storage: UserKVStorage, value: Value, forKey key: String, expireRule: UserKVStorage.ExpireRule) {
        storage.set(value, forKey: key, expireRule: expireRule)
    }

    func get(on storage: UserKVStorage, forKey key: String) -> Value? {
        storage.int(forKey: key, defaultValue: defaultValue)
    }
}

/// Int类型存储
public struct IntStorageStrategy: DigitalStorageStrategy {
    public typealias Value = Int
    public var defaultValue: Value = 0
    public init() {}
}

/// Int类型存储 默认0
public typealias IntStorage = UserStorage<IntStorageStrategy>

// MARK: - Double / CGFloat Value

public extension DigitalStorageStrategy where Value == CGFloat {
    func set(on storage: UserKVStorage, value: Value, forKey key: String, expireRule: UserKVStorage.ExpireRule) {
        storage.set(value, forKey: key, expireRule: expireRule)
    }

    func get(on storage: UserKVStorage, forKey key: String) -> Value? {
        storage.cgfloat(forKey: key, defaultValue: defaultValue)
    }
}

public extension DigitalStorageStrategy where Value == Double {
    func set(on storage: UserKVStorage, value: Value, forKey key: String, expireRule: UserKVStorage.ExpireRule) {
        storage.set(value, forKey: key, expireRule: expireRule)
    }

    func get(on storage: UserKVStorage, forKey key: String) -> Value? {
        storage.double(forKey: key, defaultValue: defaultValue)
    }
}

/// Double类型存储
public struct DoubleStorageStrategy: DigitalStorageStrategy {
    public typealias Value = Double
    public var defaultValue: Value = 0.0
    public init() {}
}

/// Double类型存储 默认0.0
public typealias DoubleStorage = UserStorage<DoubleStorageStrategy>

/// CGFloat 类型存储
public struct CGFloatStorageStrategy: DigitalStorageStrategy {
    public typealias Value = CGFloat
    public var defaultValue: Value = 0.0
    public init() {}
}

/// CGFloat类型存储 默认0.0
public typealias CGFloatStorage = UserStorage<CGFloatStorageStrategy>
