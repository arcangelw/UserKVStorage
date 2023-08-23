//
//  ObjCTests.m
//  UserKVStorage_Tests
//
//  Created by 吴哲 on 2023/8/24.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

@import Quick;
@import Nimble;
@import UserKVStorage;
#import <UserKVStorage_Tests-Swift.h>

@interface TestObject : NSObject<NSCoding>
@property (nonatomic, assign) NSInteger integer;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSDate *date;
@end
@implementation TestObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        _integer = 123456789;
        _text = @"NSCoding Text";
        _data = [@"NSCoding Data" dataUsingEncoding:NSUTF8StringEncoding];
        _date = [NSDate date];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeInteger:_integer forKey:@"integer"];
    [coder encodeObject:_text forKey:@"text"];
    [coder encodeObject:_data forKey:@"data"];
    [coder encodeObject:_date forKey:@"date"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    
    self = [super init];
    if (self) {
        _integer = [coder decodeIntegerForKey:@"integer"];
        _text = [coder decodeObjectForKey:@"text"];
        _data = [coder decodeObjectForKey:@"data"];
        _date = [coder decodeObjectForKey:@"date"];
    }
    return self;
}
@end

QuickSpecBegin(DefaultStorageSpec)
qck_describe(@"测试NSUserDefaults数据迁移", ^{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    __block NSString *string;
    __block NSData *data;
    __block NSDate *date;
    __block NSDictionary *dictionary;
    __block NSArray *array;
    __block NSArray *stringArray;
    qck_beforeSuite(^{

        [DefaultStorage initializeKVStorage:nil groupId:nil];
        NSDictionary *old = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
        [old enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }];
        [NSUserDefaults resetStandardUserDefaults];
        [DefaultStorage removeAll];
        [OtherObjCStorage removeAll];
        expect([DefaultStorage count]).to(equal(0));
        expect([OtherObjCStorage count]).to(equal(0));
        [defaults setInteger:1000 forKey:@"integer"];
        [defaults setObject:[NSNumber numberWithInteger:1000] forKey:@"integerObject"];
        [defaults setFloat:0.123456 forKey:@"float"];
        [defaults setObject:[NSNumber numberWithFloat:0.123456] forKey:@"floatObject"];
        [defaults setDouble:3.14159260001 forKey:@"double"];
        [defaults setObject:[NSNumber numberWithDouble:3.14159260001] forKey:@"doubleObject"];
        [defaults setBool:NO forKey:@"bool"];
        [defaults setObject:@(YES) forKey:@"boolObject"];
        [defaults setURL:[NSURL URLWithString:@"https://www.google.com"] forKey:@"url"];
//        [defaults setObject:[NSURL URLWithString:@"https://www.google.com"] forKey:@"urlObject"];

        string = @"abcd www.google.com 123 &&*&*@$^%&^%&&*";
        [defaults setObject:string forKey:@"string"];
        
        data = [@"Data Test" dataUsingEncoding:NSUTF8StringEncoding];
        [defaults setObject:data forKey:@"data"];
        date = [NSDate dateWithTimeIntervalSince1970:1000];
        [defaults setObject:date forKey:@"date"];
        
        dictionary = @{@"1": @(1), @"2": @"2", @"3": @(3)};
        [defaults setObject:dictionary forKey:@"dictionary"];
        array = @[@"1", @(2), @"3"];
        [defaults setObject:array forKey:@"array"];
        stringArray = @[@"1", @"b", @"3", @"d"];
        [defaults setObject:stringArray forKey:@"stringArray"];
        
//        TestObject *object = [[TestObject alloc] init];
//        object.integer = 1000;
//        object.text = @"ObjC Test";
//        [defaults setObject:object forKey:@"object"];

        [defaults synchronize];
    });
    
    qck_it(@"迁移数据量一致性", ^{
        NSInteger defaultsCount = defaults.dictionaryRepresentation.count;
        NSInteger count = [DefaultStorage migrateFromStandard];
        expect(count).to(equal(defaultsCount));
   
        NSInteger integerValue = [DefaultStorage integerForKey:@"integer"];
        expect(integerValue).to(equal(1000));
        integerValue = [DefaultStorage integerForKey:@"integerObject"];
        expect(integerValue).to(equal(1000));
        NSNumber *integerNumber = [DefaultStorage objectForKey:@"integerObject"];
        expect(integerNumber).to(equal([NSNumber numberWithInteger:1000]));
        
        NSNumber *contrastFloatNumber = [NSNumber numberWithFloat:0.123456];
        float floatValue = [DefaultStorage floatForKey:@"float"];
        expect([NSNumber numberWithFloat:floatValue]).to(equal(contrastFloatNumber));
        floatValue = [DefaultStorage floatForKey:@"floatObject"];
        expect([NSNumber numberWithFloat:floatValue]).to(equal(contrastFloatNumber));
        NSNumber *floatNumber = [DefaultStorage objectForKey:@"floatObject"];
        expect(floatNumber).to(equal(contrastFloatNumber));
        
        
        double doubleValue = [DefaultStorage doubleForKey:@"double"];
        expect(doubleValue).to(equal(3.14159260001));
        doubleValue = [DefaultStorage doubleForKey:@"doubleObject"];
        expect(doubleValue).to(equal(3.14159260001));
        NSNumber *doubleNumber = [DefaultStorage objectForKey:@"doubleObject"];
        expect(doubleNumber).to(equal([NSNumber numberWithDouble:3.14159260001]));

        BOOL boolValue = [DefaultStorage boolForKey:@"bool"];
        expect(boolValue).to(equal(NO));
        boolValue = [DefaultStorage boolForKey:@"boolObject"];
        expect(boolValue).to(equal(YES));
        NSNumber *boolNumber = [DefaultStorage objectForKey:@"boolObject"];
        expect(boolNumber).to(equal([NSNumber numberWithBool:YES]));
        
        
        NSURL *url = [DefaultStorage URLForKey:@"url"];
        expect(url).to(equal([NSURL URLWithString:@"https://www.google.com"]));
        id urlObject = [DefaultStorage objectForKey:@"url"];
        expect(urlObject).to(beAKindOf(NSData.class));
        
        NSString *getString = [DefaultStorage stringForKey:@"string"];
        expect(getString).to((equal(string)));
        NSString *stringObject = [DefaultStorage objectForKey:@"string"];
        expect(stringObject).to((equal(string)));
        
        
        NSData *getData = [DefaultStorage dataForKey:@"data"];
        expect(getData).to((equal(data)));
        NSData *dataObject = [DefaultStorage objectForKey:@"data"];
        expect(dataObject).to((equal(data)));
        
        NSDate *getDate = [DefaultStorage dateForKey:@"date"];
        expect(getDate).to((equal(date)));
        NSDate *dateObject = [DefaultStorage objectForKey:@"date"];
        expect(dateObject).to((equal(date)));
        
        NSDictionary *getDictionary = [DefaultStorage dictionaryForKey:@"dictionary"];
        expect(getDictionary).to((equal(dictionary)));
        NSDictionary *dictionaryObject = [DefaultStorage objectForKey:@"dictionary"];
        expect(dictionaryObject).to((equal(dictionary)));
        
        NSArray *getArray= [DefaultStorage arrayForKey:@"array"];
        expect(getArray).to((equal(array)));
        NSArray *arrayObject = [DefaultStorage objectForKey:@"array"];
        expect(arrayObject).to((equal(array)));
        
        NSArray *getStringArray= [DefaultStorage stringArrayForKey:@"stringArray"];
        expect(getStringArray).to(equal(stringArray));
        NSArray *stringArrayObject = [DefaultStorage objectForKey:@"stringArray"];
        expect(stringArrayObject).to(equal(stringArray));
    });
    
    qck_it(@"NSObject<NSCoding>支持", ^{
        TestObject *object = [[TestObject alloc] init];
        [DefaultStorage setObject:object forKey:@"object<NSCoding>"];
        TestObject *getObject = [DefaultStorage objectForKey:@"object<NSCoding>"];
        expect(getObject.integer).to(equal(object.integer));
        expect(getObject.text).to(equal(object.text));
        expect(getObject.data).to(equal(object.data));
        expect(getObject.date).to(equal(object.date));
    });
    
    qck_it(@"NSURL支持", ^{
        NSURL *url = [NSURL URLWithString:@"https://www.google.com"];
        [DefaultStorage setObject:url forKey:@"setUrlObject"];
        [DefaultStorage setURL:url forKey:@"setUrl"];
        id url1 = [DefaultStorage objectForKey:@"setUrlObject"];
        NSURL *url2 = [DefaultStorage URLForKey:@"setUrlObject"];
        expect(url1).to(beAKindOf(NSData.class));
        expect(url).to(equal(url2));
        id url3 = [DefaultStorage objectForKey:@"setUrl"];
        NSURL *url4 = [DefaultStorage URLForKey:@"setUrl"];
        expect(url3).to(beAKindOf(NSData.class));
        expect(url).to(equal(url4));
    });
    
    qck_it(@"OtherObjCStorage", ^{
        expect([OtherObjCStorage count]).to(equal(0));
        
        
        TestObject *object = [[TestObject alloc] init];
        [OtherObjCStorage setObject:object forKey:@"object<NSCoding>"];
        TestObject *getObject = [OtherObjCStorage objectForKey:@"object<NSCoding>"];
        expect(getObject.integer).to(equal(object.integer));
        expect(getObject.text).to(equal(object.text));
        expect(getObject.data).to(equal(object.data));
        expect(getObject.date).to(equal(object.date));
        
        NSURL *url = [NSURL URLWithString:@"https://www.google.com"];
        [OtherObjCStorage setObject:url forKey:@"setUrlObject"];
        [OtherObjCStorage setURL:url forKey:@"setUrl"];
        id url1 = [OtherObjCStorage objectForKey:@"setUrlObject"];
        NSURL *url2 = [OtherObjCStorage URLForKey:@"setUrlObject"];
        expect(url1).to(beAKindOf(NSData.class));
        expect(url).to(equal(url2));
        id url3 = [OtherObjCStorage objectForKey:@"setUrl"];
        NSURL *url4 = [OtherObjCStorage URLForKey:@"setUrl"];
        expect(url3).to(beAKindOf(NSData.class));
        expect(url).to(equal(url4));
    });
});
QuickSpecEnd
