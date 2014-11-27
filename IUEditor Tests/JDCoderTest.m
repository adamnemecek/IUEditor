//
//  JDCoderTest.m
//  IUEditor
//
//  Created by jd on 10/2/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUBox.h"
#import "JDMutableArrayDict.h"

@interface JDCoderTest : XCTestCase

@end

@interface JDCoderTestClass : NSObject <JDCoding>
@property JDCoderTestClass *link;
@end

@implementation JDCoderTestClass

-(id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super init];
    _link = [aDecoder decodeObjectForKey:@"link"];
    return self;
}

-(void)awakeAfterUsingJDCoder:(JDCoder *)aDecoder{
}

-(void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder encodeObject:_link forKey:@"link"];
}

@end


@implementation JDCoderTest {
}

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test00{
    JDCoderTestClass *a = [[JDCoderTestClass alloc] init];
    JDCoderTestClass *b = [[JDCoderTestClass alloc] init];
    
    a.link = b;
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:a];
    
    JDCoderTestClass *c = [coder decodeRootObject];
    XCTAssertNotNil(c.link);
}


- (void)test01_JDCoder{
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeObject:@"ABCDE" forKey:@"text1"];
    XCTAssertEqual([coder decodeObjectForKey:@"text1"], @"ABCDE");
    
    [coder encodeDouble:12345 forKey:@"12345"];
    XCTAssertEqual([coder decodeDoubleForKey:@"12345"], 12345);
    
    NSMutableString *testString = [[NSMutableString alloc] initWithString:@"mutable"];
    [coder encodeObject:testString forKey:@"mutable"];
    XCTAssertTrue([[coder decodeObjectForKey:@"mutable"] isEqualToString:@"mutable"]);
    
    NSNumber *number = [NSNumber numberWithFloat:1.5];
    [coder encodeObject:number forKey:@"number"];
    XCTAssertEqual([[coder decodeObjectForKey:@"number"] floatValue], 1.5);
    
    NSArray *testArray = [NSArray arrayWithObjects:@"123", @"456", nil];
    [coder encodeObject:testArray forKey:@"array"];
    NSArray *arr = [coder decodeObjectForKey:@"array"];
    XCTAssertEqual([[arr objectAtIndex:1] integerValue], 456);
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithObjects:@"asdf", nil];
    [coder encodeObject:mutableArray forKey:@"mutableArray"];
    NSMutableArray * mutableArrayDecoded = [coder decodeObjectForKey:@"mutableArray"];
    XCTAssertTrue([mutableArrayDecoded isKindOfClass:[NSMutableArray class]]);
    XCTAssertEqual([mutableArrayDecoded objectAtIndex:0], @"asdf");
}

- (void)test02_MutableArrayDict {
    JDMutableArrayDict *arrayDict = [[JDMutableArrayDict alloc] init];
    [arrayDict insertObject:@"object1" forKey:@"key1" atIndex:0];
    [arrayDict insertObject:@"object2" forKey:@"key2" atIndex:1];
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:arrayDict];
    
    JDMutableArrayDict *decodedArrayDict = [coder decodeRootObject];
    XCTAssertEqualObjects(@"object1" ,[decodedArrayDict objectAtIndex:0]);
    XCTAssertEqualObjects(@"object2" ,[decodedArrayDict objectAtIndex:1]);
    XCTAssertEqualObjects(@"object1" ,[decodedArrayDict objectForKey:@"key1"]);
    XCTAssertEqualObjects(@"object2" ,[decodedArrayDict objectForKey:@"key2"]);
}

- (void)test03_JDCoderDict{
    JDCoder *coder = [[JDCoder alloc] init];
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    mutableDict[@"test"] = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"object", @"key", nil];
    [coder encodeObject:mutableDict forKey:@"mutableDict"];

    NSDictionary *dict = [coder decodeObjectForKey:@"mutableDict"];
    NSDictionary *innerDict = [dict objectForKey:@"test"];
    NSString *decoded = [innerDict objectForKey:@"key"];
    XCTAssertEqual(decoded, @"object");
    XCTAssertTrue([dict isKindOfClass:[NSMutableDictionary class]]);
    XCTAssertTrue([innerDict isKindOfClass:[NSMutableDictionary class]]);
}

- (void)test4_IUBoxEncoding1{
    // This is an example of a functional test case.
    IUBox *oneBox = [[IUBox alloc] initWithPreset];
    oneBox.htmlID = @"OneBox";
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:oneBox];
    IUBox *resultBox = [coder decodeRootObject];

    XCTAssert([resultBox.htmlID isEqualToString:@"OneBox"], @"Pass");
}


- (void)test5_IUBoxEncoding2{
    // This is an example of a functional test case.
    IUBox *oneBox = [[IUBox alloc] initWithPreset];
    oneBox.htmlID = @"OneBox";
    oneBox.defaultStyleStorage.fontName = @"Roboto";
    oneBox.defaultPropertyStorage.innerHTML = @"aaa";
    oneBox.defaultPositionStorage.y = @(20);
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:oneBox];
    IUBox *resultBox = [coder decodeRootObject];
    
    XCTAssert([resultBox.htmlID isEqualToString:@"OneBox"], @"Pass");
    XCTAssert([resultBox.defaultStyleStorage.fontName isEqualToString:@"Roboto"], @"Pass");
    XCTAssert([resultBox.defaultPropertyStorage.innerHTML isEqualToString:@"aaa"], @"Pass");
    XCTAssert([resultBox.defaultPositionStorage.y isEqualToNumber:@(20)], @"Pass");

}



-(void)test5_memorySharing{
    NSMutableString *str = [@"abcd" mutableCopy];
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeObject:str forKey:@"key1"];
    [coder encodeObject:str forKey:@"key2"];
    
    NSMutableString *str2 = [coder decodeObjectForKey:@"key1"];
    NSMutableString *str3 = [coder decodeObjectForKey:@"key2"];
    
    XCTAssertEqual(str2, str3);
}

- (void)test6_complex_array{
    NSMutableArray *item = [NSMutableArray arrayWithObjects:@"item", nil];
    NSArray *firstArray = @[item, @"first"];
    NSArray *secondArray = @[item, @"second"];
    NSArray *root = @[firstArray, secondArray];

    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:root];
    
    NSArray *decoded = [coder decodeRootObject];
    NSMutableArray *firstItemDecoded = decoded[0][0];
    NSMutableArray *secondItemDecoded = decoded[1][0];
    
    XCTAssertEqual(firstItemDecoded, secondItemDecoded);
    XCTAssertTrue([firstItemDecoded isKindOfClass:[NSMutableArray class]]);
}

- (void)test6_dict{
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObject:@"ItemValue" forKey:@"ItemKey"];
    NSMutableDictionary *firstDict = [@{@"key":item} mutableCopy];
    NSMutableDictionary *secondDict = [@{@"key":item} mutableCopy];
    NSMutableDictionary *root = [@{@"first":firstDict, @"second": secondDict} mutableCopy];
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:root];
    
    NSMutableDictionary *decoded = [coder decodeRootObject];
    NSMutableDictionary *firstItem = decoded[@"first"][@"key"];
    NSMutableDictionary *secondItem = decoded[@"first"][@"key"];
    
    XCTAssertEqual(firstItem, secondItem) ;
}

@end
