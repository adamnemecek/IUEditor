//
//  IUCSSTest.m
//  IUEditor
//
//  Created by jd on 10/3/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUDataStorage.h"

@interface IUDataStorageTest : XCTestCase

@end

@implementation IUDataStorageTest {
    IUCSSStorage *storage;
    NSMutableArray *arr;
    
    IUCSSStorageManager *storageManager;
}

- (void)setUp {
    [super setUp];
    storage = [[IUCSSStorage alloc] init];
    [storage setValue:@"value" forKey:@"key"];
    
    storageManager = [[IUCSSStorageManager alloc] init];
    
    arr = [NSMutableArray array];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1_IUDataStorage {
    XCTAssert([[storage valueForKey:@"key"] isEqualToString:@"value"], @"Pass");
    XCTAssert([storage valueForKey:@"key2"] == nil, @"Pass");
}

- (void)test2_IUCSSDataStorage {
    [storage setValue:[NSColor blackColor] forKey:IUCSSTagBorderTopColor];
    XCTAssert([storage borderColor] == NSMultipleValuesMarker, @"Pass");

    [storage setValue:[NSColor blackColor] forKey:IUCSSTagBorderLeftColor];
    XCTAssert([storage borderColor] == NSMultipleValuesMarker, @"Pass");

    [storage setValue:[NSColor blackColor] forKey:IUCSSTagBorderRightColor];
    XCTAssert([storage borderColor] == NSMultipleValuesMarker, @"Pass");

    [storage setValue:[NSColor blackColor] forKey:IUCSSTagBorderBottomColor];
    XCTAssert([storage borderColor] == [NSColor blackColor], @"Pass");
}

- (void)test3_IUCSSObserving{
    [storage addObserver:self forKeyPath:@"borderColor" options:0 context:nil];
    [storage setValue:[NSColor blackColor] forKey:IUCSSTagBorderTopColor];
    XCTAssert([[arr firstObject] isEqualToString:@"borderColor"], @"Pass");
    
    [storage setValue:[NSColor blackColor] forKey:IUCSSTagBorderLeftColor];
    XCTAssert([arr count] == 1 , @"Pass");
}

- (void)test4_settingColor{
    storage.borderColor = [NSColor yellowColor];
    XCTAssert([storage valueForKey:IUCSSTagBorderBottomColor] == [NSColor yellowColor] , @"Pass");
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [arr addObject:keyPath];
}

- (void)test5_IUStorageManager{
    XCTAssert(storageManager.currentViewPort == IUDefaultViewPort , @"Pass");
    XCTAssertNotNil(storageManager.currentStorage);
    XCTAssertNotNil(storageManager.defaultStorage);

    [storageManager.currentStorage setValue:@"testValue" forKey:@"Key"];
    XCTAssertEqual([storageManager.liveStorage valueForKey:@"Key"], @"testValue");
    XCTAssertEqual([storageManager.defaultStorage valueForKey:@"Key"], @"testValue");
    
    [storageManager.liveStorage setValue:@"testValue2" forKey:@"Key2"];
    XCTAssertEqual([storageManager.currentStorage valueForKey:@"Key"], @"testValue");
    
    storageManager.currentViewPort = 1000;
    XCTAssertEqual([storageManager.liveStorage valueForKey:@"Key"], @"testValue");
    XCTAssertNil([storageManager.currentStorage valueForKey:@"Key"]);
    XCTAssertEqual([storageManager.defaultStorage valueForKey:@"Key"], @"testValue");
}

- (void)test6_IUStorageHover{
    storageManager.selector = IUCSSSelectorHover;
    XCTAssertNotNil(storageManager.currentStorage);
    XCTAssertNotNil(storageManager.defaultStorage);
    [storageManager.currentStorage setValue:@"testValue" forKey:@"Key"];

    storageManager.selector = IUCSSSelectorDefault;
    XCTAssertNil([storageManager.liveStorage valueForKey:@"Key"]);
    
    storageManager.selector = IUCSSSelectorHover;
    XCTAssertEqual([storageManager.currentStorage valueForKey:@"Key"], @"testValue");
    
}

- (void)test7_ViewPort{
    IUDataStorage *storage_default = storageManager.currentStorage;
    [storageManager setCurrentViewPort:500];
    IUDataStorage *storage_500 = storageManager.currentStorage;
    
    XCTAssertEqual([storageManager storageOfBiggerViewPortOfStorage:storage_500], storage_default);
    XCTAssertEqual([storageManager storageOfSmallerViewPortOfStorage:storage_default], storage_500);
    XCTAssertNil([storageManager storageOfSmallerViewPortOfStorage:storage_500]);
    XCTAssertNil([storageManager storageOfBiggerViewPortOfStorage:storage_default]);
}

- (void)test8_encoding{
    [storageManager.currentStorage setValue:@"testValue" forKey:@"Key"];
    [storageManager.currentStorage setValue:@"testValue2" forKey:@"Key2"];

    [storageManager setCurrentViewPort:500];
    [storageManager.currentStorage setValue:@"testValue3" forKey:@"Key3"];

    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:storageManager];
    
    IUCSSStorageManager *decodedStorageManager = [coder decodeRootObject];
    XCTAssertEqual(decodedStorageManager.currentViewPort,9999);
    
    IUCSSStorage *decodedStorageDefault = decodedStorageManager.currentStorage;
    XCTAssertNotNil(decodedStorageDefault);
    
    XCTAssertEqualObjects([decodedStorageDefault valueForKey:@"Key"], @"testValue");
    XCTAssertEqualObjects([decodedStorageDefault valueForKey:@"Key2"], @"testValue2");

    [decodedStorageManager setCurrentViewPort:500];
    XCTAssertEqualObjects([decodedStorageManager.currentStorage valueForKey:@"Key3"], @"testValue3");
}
- (void)testPerformanceExample {
    /* This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
     */
}

@end
