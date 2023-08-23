//
//  UserKVStorage.swift
//  Pods
//
//  Created by 吴哲 on 2023/8/23.
//

import Foundation
import MMKV

public extension UserKVStorage {
    /// 日志级别
    enum LogLevel {
        case debug
        case info
        case warning
        case error
        case none

        /// to MMKVLogLevel
        fileprivate var bridge: MMKVLogLevel {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .warning
            case .error: return .error
            case .none: return .none
            }
        }
    }

    /// 过期规则
    enum ExpireRule: UInt32 {
        /// 永不过期
        case never = 0
        /// 1分钟过期
        case inMinute = 60
        /// 1小时过期
        case inHour = 3600
        /// 1天过期
        case inDay = 86400
        /// 1月过期
        case inMonth = 2_592_000
        /// 1年过期
        case inYear = 946_080_000
    }

    /// NSNumber 类型
    internal enum NumberType: CChar {
        case char = 0x63 // 'c'
        case int = 0x69 // 'i'
        case short = 0x73 // 's'
        case long = 0x6C // 'l'
        case longlong = 0x71 // 'q'
        case uchar = 0x43 // 'C'
        case uint = 0x49 // 'I'
        case ushort = 0x53 // 'S'
        case ulong = 0x4C // 'L'
        case ulonglong = 0x51 // 'Q'
        case float = 0x66 // 'f'
        case double = 0x64 // 'd'
        case bool = 0x42 // 'B'

        init?(number: NSNumber) {
            guard let numberType = NumberType(rawValue: number.objCType.pointee) else {
                return nil
            }
            self = numberType
        }
    }

    internal enum Static {
        /// 默认存储
        static let defaultStorage = UserKVStorage(name: "default")

        /// Int的真实类型
        static let intNumberType: NumberType? = NumberType(number: .init(value: Int.max))

        /// UInt的真实类型
        static let uintNumberType: NumberType? = NumberType(number: .init(value: UInt.max))

        /// CGFloat的真实类型
        static let cgfloatNumberType: NumberType? = NumberType(number: .init(value: CGFloat(0)))
    }
}

/// `基于MMKV封装的 key-value 存储`
public final class UserKVStorage {
    /// 初始化存储
    public class func initializeKVStorage(_ rootDir: String? = nil, groupId: String? = nil, logLevel: LogLevel = .info) {
        if let groupId = groupId {
            let groupDir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId)!.path
            MMKV.initialize(rootDir: rootDir, groupDir: groupDir, logLevel: logLevel.bridge)
        } else {
            MMKV.initialize(rootDir: rootDir, logLevel: logLevel.bridge)
        }
    }

    /// 默认存储 提供给
    public class var defaultStorage: UserKVStorage {
        return Static.defaultStorage
    }

    /// 存储名称
    public let name: String

    /// 过期规则
    public let expireRule: ExpireRule

    /// mmkv
    var mmkv: MMKV! {
        return .init(mmapID: "storage.\(name)")
    }

    /// `init`
    /// - Parameters:
    ///   - name: 存储名称
    ///   - expireRule: 存储过期规则 默认不过期
    public init(name: String, expireRule: ExpireRule = .never) {
        self.name = name
        self.expireRule = expireRule
        mmkv.enableAutoKeyExpire(expiredInSeconds: expireRule.rawValue)
    }

    /// 清空
    public func removeAll() {
        mmkv.clearAll()
    }

    /// 移除
    /// - Parameter key: `key`
    public func removeValue(forKey key: String) {
        mmkv.removeValue(forKey: key)
    }

    /// 批量移除
    /// - Parameter keys: `[key]`
    public func removeValues(forKeys keys: [String]) {
        mmkv.removeValues(forKeys: keys)
    }

    /// 是否有缓存
    /// - Parameter key: `key`
    /// - Returns: 是否存在缓存
    public func contains(key: String) -> Bool {
        mmkv.contains(key: key)
    }

    /// 存储数量
    public func count() -> Int {
        mmkv.count()
    }
}

// MARK: - Setter

public extension UserKVStorage {
    /// 存储
    /// - Parameters:
    ///   - value: `Bool Value`
    ///   - key: `key`
    ///   - expireRule: 过期规则
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: Bool, forKey key: String, expireRule: ExpireRule? = nil) -> Bool {
        mmkv.set(value, forKey: key, expireDuration: (expireRule ?? self.expireRule).rawValue)
    }

    /// 存储
    /// - Parameters:
    ///   - value: `Int Value`
    ///   - key: `key`
    ///   - expireRule: 过期规则
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: Int, forKey key: String, expireRule: ExpireRule? = nil) -> Bool {
        if Static.intNumberType == .int {
            return set(Int32(value), forKey: key, expireRule: expireRule)
        } else {
            return set(Int64(value), forKey: key, expireRule: expireRule)
        }
    }

    /// 存储
    /// - Parameters:
    ///   - value: `UInt Value`
    ///   - key: `key`
    ///   - expireRule: 过期规则
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: UInt, forKey key: String, expireRule: ExpireRule? = nil) -> Bool {
        if Static.uintNumberType == .uint {
            return set(UInt32(value), forKey: key, expireRule: expireRule)
        } else {
            return set(UInt64(value), forKey: key, expireRule: expireRule)
        }
    }

    /// 存储
    /// - Parameters:
    ///   - value: `Int32 Value`
    ///   - key: `key`
    ///   - expireRule: 过期规则
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: Int32, forKey key: String, expireRule: ExpireRule? = nil) -> Bool {
        mmkv.set(value, forKey: key, expireDuration: (expireRule ?? self.expireRule).rawValue)
    }

    /// 存储
    /// - Parameters:
    ///   - value: `UInt32 Value`
    ///   - key: `key`
    ///   - expireRule: 过期规则
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: UInt32, forKey key: String, expireRule: ExpireRule? = nil) -> Bool {
        mmkv.set(value, forKey: key, expireDuration: (expireRule ?? self.expireRule).rawValue)
    }

    /// 存储
    /// - Parameters:
    ///   - value: `Int64 Value`
    ///   - key: `key`
    ///   - expireRule: 过期规则
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: Int64, forKey key: String, expireRule: ExpireRule? = nil) -> Bool {
        mmkv.set(value, forKey: key, expireDuration: (expireRule ?? self.expireRule).rawValue)
    }

    /// 存储
    /// - Parameters:
    ///   - value: `UInt64 Value`
    ///   - key: `key`
    ///   - expireRule: 过期规则
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: UInt64, forKey key: String, expireRule: ExpireRule? = nil) -> Bool {
        mmkv.set(value, forKey: key, expireDuration: (expireRule ?? self.expireRule).rawValue)
    }

    /// 存储
    /// - Parameters:
    ///   - value: `CGFloat Value`
    ///   - key: `key`
    ///   - expireRule: 过期规则
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: CGFloat, forKey key: String, expireRule: ExpireRule? = nil) -> Bool {
        if Static.cgfloatNumberType == .float {
            return set(Float(value), forKey: key, expireRule: expireRule)
        } else {
            return set(Double(value), forKey: key, expireRule: expireRule)
        }
    }

    /// 存储
    /// - Parameters:
    ///   - value: `Float Value`
    ///   - key: `key`
    ///   - expireRule: 过期规则
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: Float, forKey key: String, expireRule: ExpireRule? = nil) -> Bool {
        mmkv.set(value, forKey: key, expireDuration: (expireRule ?? self.expireRule).rawValue)
    }

    /// 存储
    /// - Parameters:
    ///   - value: `Double Value`
    ///   - key: `key`
    ///   - expireRule: 过期规则
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: Double, forKey key: String, expireRule: ExpireRule? = nil) -> Bool {
        mmkv.set(value, forKey: key, expireDuration: (expireRule ?? self.expireRule).rawValue)
    }

    /// 存储
    /// - Parameters:
    ///   - value: `String Value`
    ///   - key: `key`
    ///   - expireRule: 过期规则
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: String, forKey key: String, expireRule: ExpireRule? = nil) -> Bool {
        mmkv.set(value, forKey: key, expireDuration: (expireRule ?? self.expireRule).rawValue)
    }

    /// 存储
    /// - Parameters:
    ///   - value: `Date Value`
    ///   - key: `key`
    ///   - expireRule: 过期规则
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: Date, forKey key: String, expireRule: ExpireRule? = nil) -> Bool {
        encode(value, forKey: key, expireRule: expireRule)
    }

    /// 存储
    /// - Parameters:
    ///   - value: `Data Value`
    ///   - key: `key`
    ///   - expireRule: 过期规则
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: Data, forKey key: String, expireRule: ExpireRule? = nil) -> Bool {
        mmkv.set(value, forKey: key, expireDuration: (expireRule ?? self.expireRule).rawValue)
    }
}

// MARK: - Getter

public extension UserKVStorage {
    /// 读取
    /// - Parameters:
    ///   - key: `Bool Value Key`
    ///   - defaultValue: 默认值
    ///   - hasValue: 是否有值
    /// - Returns: 读取值
    func bool(forKey key: String, defaultValue: Bool = false, hasValue: UnsafeMutablePointer<Bool>? = nil) -> Bool {
        var objHasValue: ObjCBool = false
        let value = mmkv.bool(forKey: key, defaultValue: defaultValue, hasValue: &objHasValue)
        hasValue?.pointee = objHasValue.boolValue
        return value
    }

    /// 读取
    /// - Parameters:
    ///   - key: `Int32 Value Key`
    ///   - defaultValue: 默认值
    ///   - hasValue: 是否有值
    /// - Returns: 读取值
    func int(forKey key: String, defaultValue: Int = 0, hasValue: UnsafeMutablePointer<Bool>? = nil) -> Int {
        if Static.intNumberType == .int {
            return Int(int32(forKey: key, defaultValue: Int32(defaultValue), hasValue: hasValue))
        } else {
            return Int(int64(forKey: key, defaultValue: Int64(defaultValue), hasValue: hasValue))
        }
    }

    /// 读取
    /// - Parameters:
    ///   - key: `UInt32 Value Key`
    ///   - defaultValue: 默认值
    ///   - hasValue: 是否有值
    /// - Returns: 读取值
    func uint(forKey key: String, defaultValue: UInt = 0, hasValue: UnsafeMutablePointer<Bool>? = nil) -> UInt {
        if Static.uintNumberType == .uint {
            return UInt(uint32(forKey: key, defaultValue: UInt32(defaultValue), hasValue: hasValue))
        } else {
            return UInt(uint64(forKey: key, defaultValue: UInt64(defaultValue), hasValue: hasValue))
        }
    }

    /// 读取
    /// - Parameters:
    ///   - key: `Int32 Value Key`
    ///   - defaultValue: 默认值
    ///   - hasValue: 是否有值
    /// - Returns: 读取值
    func int32(forKey key: String, defaultValue: Int32 = 0, hasValue: UnsafeMutablePointer<Bool>? = nil) -> Int32 {
        var objHasValue: ObjCBool = false
        let value = mmkv.int32(forKey: key, defaultValue: defaultValue, hasValue: &objHasValue)
        hasValue?.pointee = objHasValue.boolValue
        return value
    }

    /// 读取
    /// - Parameters:
    ///   - key: `UInt32 Value Key`
    ///   - defaultValue: 默认值
    ///   - hasValue: 是否有值
    /// - Returns: 读取值
    func uint32(forKey key: String, defaultValue: UInt32 = 0, hasValue: UnsafeMutablePointer<Bool>? = nil) -> UInt32 {
        var objHasValue: ObjCBool = false
        let value = mmkv.uint32(forKey: key, defaultValue: defaultValue, hasValue: &objHasValue)
        hasValue?.pointee = objHasValue.boolValue
        return value
    }

    /// 读取
    /// - Parameters:
    ///   - key: `Int64 Value Key`
    ///   - defaultValue: 默认值
    ///   - hasValue: 是否有值
    /// - Returns: 读取值
    func int64(forKey key: String, defaultValue: Int64 = 0, hasValue: UnsafeMutablePointer<Bool>? = nil) -> Int64 {
        var objHasValue: ObjCBool = false
        let value = mmkv.int64(forKey: key, defaultValue: defaultValue, hasValue: &objHasValue)
        hasValue?.pointee = objHasValue.boolValue
        return value
    }

    /// 读取
    /// - Parameters:
    ///   - key: `UInt64 Value Key`
    ///   - defaultValue: 默认值
    ///   - hasValue: 是否有值
    /// - Returns: 读取值
    func uint64(forKey key: String, defaultValue: UInt64 = 0, hasValue: UnsafeMutablePointer<Bool>? = nil) -> UInt64 {
        var objHasValue: ObjCBool = false
        let value = mmkv.uint64(forKey: key, defaultValue: defaultValue, hasValue: &objHasValue)
        hasValue?.pointee = objHasValue.boolValue
        return value
    }

    /// 读取
    /// - Parameters:
    ///   - key: `CGFloat Value Key`
    ///   - defaultValue: 默认值
    ///   - hasValue: 是否有值
    /// - Returns: 读取值
    func cgfloat(forKey key: String, defaultValue: CGFloat = 0, hasValue: UnsafeMutablePointer<Bool>? = nil) -> CGFloat {
        if Static.cgfloatNumberType == .float {
            return CGFloat(float(forKey: key, defaultValue: Float(defaultValue), hasValue: hasValue))
        } else {
            return CGFloat(double(forKey: key, defaultValue: Double(defaultValue), hasValue: hasValue))
        }
    }

    /// 读取
    /// - Parameters:
    ///   - key: `Float Value Key`
    ///   - defaultValue: 默认值
    ///   - hasValue: 是否有值
    /// - Returns: 读取值
    func float(forKey key: String, defaultValue: Float = 0, hasValue: UnsafeMutablePointer<Bool>? = nil) -> Float {
        var objHasValue: ObjCBool = false
        let value = mmkv.float(forKey: key, defaultValue: defaultValue, hasValue: &objHasValue)
        hasValue?.pointee = objHasValue.boolValue
        return value
    }

    /// 读取
    /// - Parameters:
    ///   - key: `Double Value Key`
    ///   - defaultValue: 默认值
    ///   - hasValue: 是否有值
    /// - Returns: 读取值
    func double(forKey key: String, defaultValue: Double = 0, hasValue: UnsafeMutablePointer<Bool>? = nil) -> Double {
        var objHasValue: ObjCBool = false
        let value = mmkv.double(forKey: key, defaultValue: defaultValue, hasValue: &objHasValue)
        hasValue?.pointee = objHasValue.boolValue
        return value
    }

    /// 读取
    /// - Parameters:
    ///   - key: `String Value Key`
    ///   - defaultValue: 默认值
    /// - Returns: 读取值
    func string(forKey key: String, defaultValue: String? = nil) -> String? {
        mmkv.string(forKey: key, defaultValue: defaultValue)
    }

    /// 读取
    /// - Parameters:
    ///   - key: `Date Value Key`
    ///   - defaultValue: 默认值
    /// - Returns: 读取值
    func date(forKey key: String, defaultValue _: Date? = nil) -> Date? {
        return decode(forKey: key)
    }

    /// 读取
    /// - Parameters:
    ///   - key: `Data Value Key`
    ///   - defaultValue: 默认值
    /// - Returns: 读取值
    func data(forKey key: String, defaultValue: Data? = nil) -> Data? {
        mmkv.data(forKey: key, defaultValue: defaultValue)
    }
}

// MARK: Codable Value

public extension UserKVStorage {
    /// 存储
    /// - Parameters:
    ///   - value: `Date Value`
    ///   - key: `key`
    ///   - expireRule: 过期规则
    /// - Returns: 是否存储成
    @discardableResult
    func encode<T: Encodable>(_ value: T, forKey key: String, expireRule: ExpireRule? = nil) -> Bool {
        do {
            return try set(JSONEncoder().encode(value), forKey: key, expireRule: expireRule)
        } catch {
            return false
        }
    }

    /// 读取
    /// - Parameter key: key
    /// - Returns: `Decodable Value`
    func decode<T: Decodable>(forKey key: String) -> T? {
        guard let data = data(forKey: key) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}
