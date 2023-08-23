//
//  DefaultStorage.swift
//  Pods
//
//  Created by 吴哲 on 2023/8/24.
//

import Foundation

/// DefaultStorage Substitute for UserDefaults
@objcMembers
open class DefaultStorage: NSObject {
    override private init() {
        super.init()
    }

    /// 默认存储
    /// 可以通过继承重写支持其他存储对ObjC的支持调用
    open class var storage: UserKVStorage {
        return .defaultStorage
    }

    /// 初始化存储
    public static func initializeKVStorage(_ rootDir: String? = nil, groupId: String? = nil) {
        UserKVStorage.initializeKVStorage(rootDir, groupId: groupId)
    }

    /*
     基于对UserDefaults的迁移兼容、UserKVStorage 将对以下状态支持

     UserDefaults 支持的存储类型如下
     1、数字类型 Float Double NSInteger BOOL
     在存储是都被转换为NSNumber对象存储，使用object(forKey:)获取的是NSNumber对象
     2、NSString NSArray NSDictionary NSDate NSData NSNumber
     setObject:forKey: 直接支持以上可序列化对象存储
     使用object(forKey:) 直接返回对应的数据类型
     3、NSURL 需要使用  -setURL:forKey 存储
     使用object(forKey:)返回的是序列化NSData对象
     需要使用URLForKey: 获取NSURL对象
     4、其他类型需要遵循NSCoding手动序列化为NSData对象存储

     MMKV 存储

     1、数字类型 被直接存储
     2、String 类型将被转换为 Data对象存储
     3、Data 对象直接被存储
     4、Date 对象存储时间戳 作为Double类型
     5、NSObject<NSCoding> 会自动序列还为 Data 存储

     使用 MMKV 实现 object(forKey:) 功能
     需要对 String 和 Data 数据做区分
     数字类型在转存后因为使用了 pb 直接存储数字
     需要对NSNumber类型做额外的转存

     DefaultStorage 通过存储两份 String 和 NSNumber，对object(forKey:)做兼容
     如果使用UserKVStorage只支持Swift使用，不兼容ObjC

     DefaultStorage 对object(forKey:) / object(forKey:)方法
     直接支持NSObject<NSCoding>对象直接序列化与反序列化
     */

    /// 默认迁移
    /// - Returns: `完成迁移的数据数量`
    public static func migrateFromStandard() -> Int {
        autoreleasepool {
            let dictionary = UserDefaults.standard.dictionaryRepresentation()
            guard !dictionary.isEmpty else {
                debugPrint(#file, #function, #line, "migrate data fail, userDaults is nil or empty")
                return 0
            }
            let skipKeys: [String] = UserDefaults(suiteName: "temp")?
                .dictionaryRepresentation().keys.map { $0 } ?? []
            var count: Int = skipKeys.count
            for (key, value) in dictionary where !skipKeys.contains(key) {
                if UserKVStorage.defaultStorage.set(value, forKey: key) {
                    count += 1
                } else {
                    debugPrint(#file, #function, #line, "unknown type of key: \(key)")
                }
            }
            return count
        }
    }

    /// `removeAll`
    public static func removeAll() {
        storage.removeAll()
    }

    /// `remove forKey`
    public static func removeObject(forKey key: String) {
        storage.removeValues(forKeys: StorageKey.allKeys(key))
    }

    /// `contains keys`
    public static func contains(key: String) -> Bool {
        storage.contains(key: key)
    }

    /// 存储数量
    public static func count() -> Int {
        storage.count()
    }

    /// `storage Object`
    @discardableResult
    @objc(setObject:forKey:)
    public static func set(_ object: Any?, forKey key: String) -> Bool {
        storage.set(object, forKey: key)
    }

    /// `read Any Object`
    public static func object(forKey key: String) -> Any? {
        if let string = string(forKey: StorageKey.string.key(key)) {
            return string
        }
        if let number = storage.object(forKey: StorageKey.number.key(key)) {
            return number
        }
        if let object = storage.object(forKey: key) {
            return object
        }
        if let date = storage.date(forKey: key) {
            return date
        }
        if let data = storage.data(forKey: key) {
            return data
        }
        return nil
    }

    /// `storage NSInteger value`
    @discardableResult
    @objc(setInteger:forKey:)
    public static func set(_ value: Int, forKey key: String) -> Bool {
        let number = NSNumber(value: value)
        return storage.set(number, numberType: .init(number: number), forKey: key)
    }

    /// `storage float value`
    @discardableResult
    @objc(setFloat:forKey:)
    public static func set(_ value: Float, forKey key: String) -> Bool {
        storage.set(NSNumber(value: value), numberType: .float, forKey: key)
    }

    /// `storage double value`
    @discardableResult
    @objc(setDouble:forKey:)
    public static func set(_ value: Double, forKey key: String) -> Bool {
        storage.set(NSNumber(value: value), numberType: .double, forKey: key)
    }

    /// `storage bool value`
    @discardableResult
    @objc(setBool:forKey:)
    public static func set(_ value: Bool, forKey key: String) -> Bool {
        storage.set(NSNumber(value: value), numberType: .bool, forKey: key)
    }

    /// `storage NSURL value`
    @discardableResult
    @objc(setURL:forKey:)
    public static func set(_ value: URL?, forKey key: String) -> Bool {
        /// UserDefaults NSURL被序列化存储 迁移后设置URL使用Codable
        storage.set(value, forKey: key)
    }

    /// `read  NSString value`
    public static func string(forKey key: String) -> String? {
        storage.string(forKey: key)
    }

    /// `read  NSArray value`
    public static func array(forKey key: String) -> [Any]? {
        storage.object(forKey: key) as? [Any]
    }

    /// `read  NSDictionary value`
    public static func dictionary(forKey key: String) -> [String: Any]? {
        storage.object(forKey: key) as? [String: Any]
    }

    /// `read  NSDate value`
    public static func date(forKey key: String) -> Date? {
        storage.date(forKey: key)
    }

    /// read  NSData value
    public static func data(forKey key: String) -> Data? {
        storage.data(forKey: key)
    }

    /// `read  NSArray<NSString *> value`
    public static func stringArray(forKey key: String) -> [String]? {
        array(forKey: key) as? [String]
    }

    /// `read NSInteger value`
    public static func integer(forKey key: String) -> Int {
        storage.int(forKey: key)
    }

    /// `read float value`
    public static func float(forKey key: String) -> Float {
        storage.float(forKey: key)
    }

    /// `read double value`
    public static func double(forKey key: String) -> Double {
        storage.double(forKey: key, defaultValue: 0)
    }

    /// `read BOOL value`
    public static func bool(forKey key: String) -> Bool {
        storage.bool(forKey: key)
    }

    /// `read NSURL value`
    @objc(URLForKey:)
    public static func url(forKey key: String) -> URL? {
        var url: URL?
        // 兼容 UserDefaults NSURL被序列化存储
        if let data = storage.data(forKey: key) {
            do {
                let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
                unarchiver.requiresSecureCoding = false
                url = unarchiver.decodeObject(of: NSURL.self, forKey: NSKeyedArchiveRootObjectKey) as? URL
            } catch {}
        }
        return url ?? storage.decode(forKey: key)
    }
}

/// 兼容 UserDefaults 存储一份 String NSNumber 副本
private enum StorageKey: CaseIterable {
    case string
    case number
    func key(_ key: String) -> String {
        switch self {
        case .string: return key + ".StorageString"
        case .number: return key + ".StorageNSNumber"
        }
    }

    static func allKeys(_ key: String) -> [String] {
        return [key] + allCases.map { $0.key(key) }
    }
}

// MARK: - Any Setter

private extension UserKVStorage {
    /// 存储
    /// - Parameters:
    ///   - value: `Any Value`
    ///   - key: `key`
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: Any?, forKey key: String) -> Bool {
        guard let value = value else {
            removeValues(forKeys: StorageKey.allKeys(key))
            return true
        }
        switch value {
        case let number as NSNumber:
            return set(number, numberType: .init(number: number), forKey: key)

        case is NSNull:
            removeValues(forKeys: StorageKey.allKeys(key))
            return true
        case is Void:
            removeValues(forKeys: StorageKey.allKeys(key))
            return true

        case let boolValue as Bool:
            return set(NSNumber(value: boolValue), numberType: .bool, forKey: key)

        case let intValue as Int:
            let intNumber = NSNumber(value: intValue)
            return set(intNumber, numberType: .init(number: intNumber), forKey: key)
        case let int8Value as Int8:
            return set(NSNumber(value: int8Value), numberType: .char, forKey: key)
        case let int16Value as Int16:
            return set(NSNumber(value: int16Value), numberType: .short, forKey: key)
        case let int32Value as Int32:
            return set(NSNumber(value: int32Value), numberType: .int, forKey: key)
        case let int64Value as Int64:
            return set(NSNumber(value: int64Value), numberType: .longlong, forKey: key)

        case let uintValue as UInt:
            let uintNumber = NSNumber(value: uintValue)
            return set(uintNumber, numberType: .init(number: uintNumber), forKey: key)
        case let uint8Value as UInt8:
            return set(NSNumber(value: uint8Value), numberType: .uchar, forKey: key)
        case let uint16Value as UInt16:
            return set(NSNumber(value: uint16Value), numberType: .ushort, forKey: key)
        case let uint32Value as UInt32:
            return set(NSNumber(value: uint32Value), numberType: .uint, forKey: key)
        case let uint64Value as UInt64:
            return set(NSNumber(value: uint64Value), numberType: .ulonglong, forKey: key)

        case let floatValue as Float:
            return set(NSNumber(value: floatValue), numberType: .float, forKey: key)
        case let doubleValue as Double:
            return set(NSNumber(value: doubleValue), numberType: .double, forKey: key)

        case let stringValue as String:
            return set(stringValue, forKey: key) && set(stringValue, forKey: StorageKey.string.key(key))
        case let date as Date:
            return set(date, forKey: key)
        case let data as Data:
            return set(data, forKey: key)
        case let url as URL:
            return encode(url, forKey: key)
        case let object as NSCoding & NSObjectProtocol:
            return set(object, forKey: key)
        default:
            assertionFailure("不支持的类型: \(type(of: value))")
            return false
        }
    }

    /// 存储
    /// - Parameters:
    ///   - value: `NSNumber Value`
    ///   - key: `key`
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ number: NSNumber, numberType: NumberType?, forKey key: String) -> Bool {
        guard let numberType = numberType else {
            assertionFailure("Unknown NSNumber Type")
            return false
        }
        let isSuccess = mmkv.set(number, forKey: StorageKey.number.key(key))
        switch numberType {
        case .char, .short, .int, .long:
            return isSuccess && set(number.int32Value, forKey: key)
        case .longlong:
            return isSuccess && set(number.int64Value, forKey: key)
        case .uchar, .ushort, .uint, .ulong:
            return isSuccess && set(number.uint32Value, forKey: key)
        case .ulonglong:
            return isSuccess && set(number.uint64Value, forKey: key)
        case .float:
            return isSuccess && set(number.floatValue, forKey: key)
        case .double:
            return isSuccess && set(number.doubleValue, forKey: key)
        case .bool:
            return isSuccess && set(number.boolValue, forKey: key)
        }
    }
}

// MARK: - NSObject<NSCoding>

/// `NSObject<NSCoding> 对象`
final class ObjectWrapper: NSObject, NSCoding {
    func encode(with _: NSCoder) {}

    init?(coder _: NSCoder) {}
}

private extension UserKVStorage {
    /// 存储
    /// - Parameters:
    ///   - value: `NSObject<NSCoding> Value`
    ///   - key: `key`
    /// - Returns: 是否存储成
    @discardableResult
    func set(_ value: NSCoding & NSObjectProtocol, forKey key: String) -> Bool {
        mmkv.set(value, forKey: key)
    }

    /// 反序列化取 NSObject<NSCoding>
    /// - Parameter key: key
    /// - Returns: NSObject<NSCoding> 对象
    func object(forKey key: String) -> Any? {
        mmkv.object(of: ObjectWrapper.self, forKey: key)
    }
}
