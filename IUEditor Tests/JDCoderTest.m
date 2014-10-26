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

@interface JDCoderTest : XCTestCase

@end

@implementation JDCoderTest {
    IUBox *parentBox;
    IUBox *childBox1;
    IUBox *childBox2;
}

- (void)setUp {
    [super setUp];
    NSLog(@"test");
    parentBox = [[IUBox alloc] initWithProject:nil options:nil];
    parentBox.htmlID = @"parentBox";
    [parentBox.css setValue:@"VALUETEST" forTag:@"IUCSSTagForTest"];
    [parentBox.css setValue:@(10) forTag:@"IUCSSTagForTestNum"];
    
    childBox1 = [[IUBox alloc] initWithProject:nil options:nil];
    childBox1.htmlID = @"ChildBox1";

    childBox2 = [[IUBox alloc] initWithProject:nil options:nil];
    childBox2.htmlID = @"ChildBox2";
    
    [parentBox addIU:childBox1 error:nil];
    [parentBox addIU:childBox2 error:nil];

    childBox1.link = childBox2;
    childBox2.link = childBox1;
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test0_JDCoder{
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

- (void)test01_JDCoderDict{
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

- (void)test1_IUBoxEncoding1{
    // This is an example of a functional test case.
    IUBox *oneBox = [[IUBox alloc] initWithProject:nil options:nil];
    oneBox.htmlID = @"OneBox";
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:oneBox];
    IUBox *resultBox = [coder decodedAndInitializeObject];

    XCTAssert([resultBox.htmlID isEqualToString:@"OneBox"], @"Pass");
}
/*
- (void)test2_IUBoxCSS{
    // This is an example of a functional test case.
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:parentBox];
    IUBox *resultBox = [coder decodedAndInitializeObject];
    
    XCTAssert([[resultBox.css effectiveValueForTag:@"IUCSSTagForTest" forViewport:IUCSSDefaultViewPort] isEqualToString:@"VALUETEST"], @"Pass");
    NSInteger result = [[resultBox.css effectiveValueForTag:@"IUCSSTagForTestNum" forViewport:IUCSSDefaultViewPort] integerValue];
    XCTAssert(result == 10, @"Pass");
}
 */

- (void)test3_CoderSaveLoad{
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:parentBox];
    NSString *tempDir = NSTemporaryDirectory();
    NSURL *fileURL = [NSURL fileURLWithPath:[tempDir stringByAppendingPathComponent:@"parentBox.iuml"]];
    NSError *err;
    BOOL saveResult = [coder saveToURL:fileURL error:&err];
    XCTAssert(saveResult, @"Pass");
    JDCoder *loadCoder = [[JDCoder alloc] init];
    [loadCoder loadFromURL:fileURL error:&err];
    IUBox *resultBox = [loadCoder decodedAndInitializeObject];
    
    XCTAssert([[resultBox.css effectiveValueForTag:@"IUCSSTagForTest" forViewport:IUCSSDefaultViewPort] isEqualToString:@"VALUETEST"], @"Pass");
    NSInteger result = [[resultBox.css effectiveValueForTag:@"IUCSSTagForTestNum" forViewport:IUCSSDefaultViewPort] integerValue];
    XCTAssert(result == 10, @"Pass");
}

- (void)test4_children{
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:parentBox];
    
    IUBox *resultBox = [coder decodedAndInitializeObject];
    IUBox *resultChildBox1 = [[resultBox children] objectAtIndex:0];
    
    XCTAssert([resultChildBox1.htmlID isEqualToString:@"ChildBox1"], @"Pass");
    XCTAssert([resultChildBox1.parent.htmlID isEqualToString:@"parentBox"], @"Pass");
}

- (void)test5_selector{
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:parentBox];
    
    IUBox *resultBox = [coder decodedAndInitializeObject];
    IUBox *resultChildBox1 = [[resultBox children] objectAtIndex:0];
    IUBox *resultChildBox2 = [[resultBox children] objectAtIndex:1];

    XCTAssert(resultChildBox1, @"Pass");
    XCTAssert(resultChildBox1.link == resultChildBox2, @"Pass");
    XCTAssert(resultChildBox2.link == resultChildBox1, @"Pass");
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
