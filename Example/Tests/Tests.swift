// https://github.com/Quick/Quick

import Nimble
import Quick
@testable import UserKVStorage

struct StorageCodableValue: Codable, Hashable {
    var stringValue: String = "StorageCodableValue"
    var boolValue: Bool = false
    var dateValue: Date = .init(timeIntervalSince1970: 1_234_567.5)
    var data: Data = .init("StorageCodableValue".utf8)
    var intValue: Int = 123_456_789
    var cgfloatValue: CGFloat = 0.123456789
}

struct StorageContainer {
    @BoolStorage(key: "boolValue")
    var boolValue: Bool

    @BoolStorage(key: "defaultTrueValue")
    var defaultTrueValue: Bool = true

    @BoolStorage(key: "defaultFalseValue")
    var defaultFalseValue: Bool = false

    @IntStorage(key: "intValue")
    var intValue: Int

    @IntStorage(key: "defaultIntValue")
    var defaultIntValue: Int = 123_456_789

    @DoubleStorage(key: "doubleValue")
    var doubleValue: Double

    @DoubleStorage(key: "defaultDoubleValue")
    var defaultDoubleValue: Double = 0.123456789

    @CGFloatStorage(key: "cgfloatValue")
    var cgfloatValue: CGFloat

    @CGFloatStorage(key: "defaultCgfloatValue")
    var defaultCgfloatValue: CGFloat = 0.123456789
}

class UserKVStorageSpec: QuickSpec {
    override func spec() {
        beforeSuite {
            UserKVStorage.initializeKVStorage()
            UserKVStorage.defaultStorage.removeAll()
        }

        it("数字类型存储/Wrapper包装") {
            var container = StorageContainer()

            expect(container.boolValue).to(beFalse())
            container.boolValue = true
            expect(container.boolValue).to(beTrue())
            container.$boolValue.remove()
            expect(container.boolValue).to(beFalse())

            expect(container.defaultTrueValue).to(beTrue())
            container.defaultTrueValue = false
            expect(container.defaultTrueValue).to(beFalse())
            container.$defaultTrueValue.remove()
            expect(container.defaultTrueValue).to(beTrue())

            expect(container.defaultFalseValue).to(beFalse())
            container.defaultFalseValue = true
            expect(container.defaultFalseValue).to(beTrue())
            container.$defaultFalseValue.remove()
            expect(container.defaultFalseValue).to(beFalse())

            expect(container.intValue).to(equal(0))
            container.intValue = 123_456_789
            expect(container.intValue).to(equal(123_456_789))
            container.$intValue.remove()
            expect(container.intValue).to(equal(0))

            expect(container.defaultIntValue).to(equal(123_456_789))
            container.defaultIntValue = 987_654_321
            expect(container.defaultIntValue).to(equal(987_654_321))
            container.$defaultIntValue.remove()
            expect(container.defaultIntValue).to(equal(123_456_789))

            expect(container.doubleValue).to(equal(0.0))
            container.doubleValue = 0.123456789
            expect(container.doubleValue).to(equal(0.123456789))
            container.$doubleValue.remove()
            expect(container.doubleValue).to(equal(0.0))

            expect(container.defaultDoubleValue).to(equal(0.123456789))
            container.defaultDoubleValue = 0.0
            expect(container.defaultDoubleValue).to(equal(0.0))
            container.$defaultDoubleValue.remove()
            expect(container.defaultDoubleValue).to(equal(0.123456789))

            expect(container.cgfloatValue).to(equal(0.0))
            container.cgfloatValue = 0.123456789
            expect(container.cgfloatValue).to(equal(0.123456789))
            container.$cgfloatValue.remove()
            expect(container.cgfloatValue).to(equal(0.0))

            expect(container.defaultCgfloatValue).to(equal(0.123456789))
            container.defaultCgfloatValue = 0.0
            expect(container.defaultCgfloatValue).to(equal(0.0))
            container.$defaultCgfloatValue.remove()
            expect(container.defaultCgfloatValue).to(equal(0.123456789))
        }

        it("String存储") {
            @StringStorage(key: "stringValue")
            var stringValue: String?
            expect(stringValue).to(beNil())
            stringValue = "test string"
            expect(stringValue).to(equal("test string"))
        }

        it("Date存储") {
            @DateStorage(key: "dateValue")
            var dateValue: Date?
            expect(dateValue).to(beNil())
            let date = Date(timeIntervalSince1970: 1_234_567.5)
            dateValue = date
            expect(dateValue).to(equal(date))
            expect(dateValue?.timeIntervalSince1970).to(equal(1_234_567.5))
        }

        it("Data存储") {
            @DataStorage(key: "dataValue")
            var dataValue: Data?

            expect(dataValue).to(beNil())

            let data = Data("test dataValue".utf8)
            dataValue = data
            expect(dataValue).to(equal(data))
            let string = String(decoding: dataValue!, as: UTF8.self)
            expect(string).to(equal("test dataValue"))
        }

        it("Codable存储") {
            @CodableStorage(key: "codableValue")
            var codableValue: StorageCodableValue?

            expect(codableValue).to(beNil())

            let container = StorageCodableValue()
            codableValue = container
            let equalContainer = StorageCodableValue()
            expect(codableValue).toNot(beNil())
            expect(codableValue).to(equal(equalContainer))
        }
    }
}
