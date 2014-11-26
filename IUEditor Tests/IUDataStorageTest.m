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
#import "IUStyleStorage.h"

@interface IUDataStorageTest : XCTestCase

@end

@implementation IUDataStorageTest {
    IUStyleStorage *storage;
    NSMutableArray *arr;
    
    IUDataStorageManager *storageManager;
}

- (void)setUp {
    [super setUp];
    storageManager = [[IUDataStorageManager alloc] initWithStorageClassName:[IUStyleStorage class].className];

    arr = [NSMutableArray array];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1_IUDataStorage {
    [storage setValue:@"value" forKey:@"key"];
    XCTAssert([[storage valueForKey:@"key"] isEqualToString:@"value"], @"Pass");
    XCTAssert([storage valueForKey:@"key2"] == nil, @"Pass");
}

- (void)test2_IUCSSDataStorage {
    storage.topBorderColor = [NSColor blackColor];

    storage.leftBorderColor = [NSColor blackColor];
    XCTAssert([storage borderColor] == NSMultipleValuesMarker, @"Pass");

    storage.rightBorderColor = [NSColor blackColor];
    storage.bottomBorderColor = [NSColor blackColor];
    XCTAssert([storage borderColor] == [NSColor blackColor], @"Pass");
}


- (void)test4_settingColor{
    storage.borderColor = [NSColor yellowColor];
    [storage setBorderColor:[NSColor redColor]];
    XCTAssert(storage.bottomBorderColor== [NSColor redColor] , @"Pass");
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

/*
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
*/
- (void)test7_ViewPort{
    IUDataStorage *storage_default = storageManager.currentStorage;
    [storageManager setCurrentViewPort:500];
    IUDataStorage *storage_500 = storageManager.currentStorage;
    
    XCTAssertEqual([storageManager storageOfBiggerViewPortOfStorage:storage_500], storage_default);
    XCTAssertEqual([storageManager storageOfSmallerViewPortOfStorage:storage_default], storage_500);
    XCTAssertNil([storageManager storageOfSmallerViewPortOfStorage:storage_500]);
    XCTAssertNil([storageManager storageOfBiggerViewPortOfStorage:storage_default]);
}

- (void)test71_style {
    JDCoder *coder = [[JDCoder alloc] init];
    IUStyleStorage *a = [[NSClassFromString(@"IUStyleStorage") alloc] initWithJDCoder:coder];
    a = nil;
}

- (void)test72_styleEncoding {
    IUStyleStorage *a = [[IUStyleStorage alloc] init];
    a.height = @(10);
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:a];
    
    IUStyleStorage *b = [coder decodeRootObject];
    NSNumber *bH = b.height;
    XCTAssertEqualObjects(bH, @(10.0));
}

- (void)test8_encoding{
    [storageManager.currentStorage setValue:@"testValue" forKey:@"Key"];
    [storageManager.currentStorage setValue:@"testValue2" forKey:@"Key2"];

    [storageManager setCurrentViewPort:500];
    [storageManager.currentStorage setValue:@"testValue3" forKey:@"Key3"];

    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:storageManager];
    
    IUDataStorageManager *decodedStorageManager = [coder decodeRootObject];
    XCTAssertEqual(decodedStorageManager.currentViewPort,9999);
    
    IUStyleStorage *decodedStorageDefault = (IUStyleStorage *)decodedStorageManager.currentStorage;
    XCTAssertNotNil(decodedStorageDefault);
    
    XCTAssertEqualObjects([decodedStorageDefault valueForKey:@"Key"], @"testValue");
    XCTAssertEqualObjects([decodedStorageDefault valueForKey:@"Key2"], @"testValue2");

    [decodedStorageManager setCurrentViewPort:500];
    XCTAssertEqualObjects([decodedStorageManager.currentStorage valueForKey:@"Key3"], @"testValue3");
}


- (void)test9_transaction{
    [storageManager.currentStorage beginTransaction:JD_CURRENT_FUNCTION];
    [storageManager.currentStorage setValue:@"abc" forKey:@"fontName"];
    XCTAssert([storageManager.currentStorage currentPropertyStackForTest].count == 1 , @"Pass");
    [storageManager.currentStorage setValue:@(2) forKey:@"fontSize"];
    XCTAssert([storageManager.currentStorage currentPropertyStackForTest].count == 2 , @"Pass");
    [storageManager.currentStorage commitTransaction:JD_CURRENT_FUNCTION];
    XCTAssert([storageManager.currentStorage currentPropertyStackForTest].count == 0 , @"Pass");
}

- (void)test10_undo{
    
    NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    [undoManager setLevelsOfUndo:4];
    storageManager.undoManager = undoManager;
    
    [storageManager.currentStorage beginTransaction:JD_CURRENT_FUNCTION];
    ((IUStyleStorage *)storageManager.currentStorage).fontName = @"abc";
    ((IUStyleStorage *)storageManager.currentStorage).fontColor = [NSColor blackColor];

    [storageManager.currentStorage commitTransaction:JD_CURRENT_FUNCTION];
    
    XCTAssert([((IUStyleStorage *)storageManager.currentStorage).fontName isEqualToString:@"abc"], @"Pass");
    XCTAssert([((IUStyleStorage *)storageManager.liveStorage).fontName isEqualToString:@"abc"], @"Pass");


    [storageManager.currentStorage beginTransaction:JD_CURRENT_FUNCTION];
    ((IUStyleStorage *)storageManager.currentStorage).fontName = @"def";
    ((IUStyleStorage *)storageManager.currentStorage).fontColor = [NSColor redColor];
    [storageManager.currentStorage commitTransaction:JD_CURRENT_FUNCTION];
    
    XCTAssert([((IUStyleStorage *)storageManager.currentStorage).fontName isEqualToString:@"def"], @"Pass");
    XCTAssert([((IUStyleStorage *)storageManager.liveStorage).fontName isEqualToString:@"def"], @"Pass");
    XCTAssert([((IUStyleStorage *)storageManager.currentStorage).fontColor isEqualTo:[NSColor redColor]], @"Pass");
    XCTAssert([((IUStyleStorage *)storageManager.liveStorage).fontColor isEqualTo:[NSColor redColor]], @"Pass");


    if([storageManager.undoManager canUndo]){
        [storageManager.undoManager undoNestedGroup];
    }
   
    
    XCTAssert([((IUStyleStorage *)storageManager.currentStorage).fontName isEqualToString:@"abc"], @"Pass");
    XCTAssert([((IUStyleStorage *)storageManager.liveStorage).fontName isEqualToString:@"abc"], @"Pass");
    
    XCTAssert([((IUStyleStorage *)storageManager.currentStorage).fontColor isEqualTo:[NSColor blackColor]], @"Pass");
    XCTAssert([((IUStyleStorage *)storageManager.liveStorage).fontColor isEqualTo:[NSColor blackColor]], @"Pass");


    if([storageManager.undoManager canUndo]){
        [storageManager.undoManager undoNestedGroup];
    }
    

    XCTAssert(((IUStyleStorage *)storageManager.currentStorage).fontName == nil, @"Pass");
    XCTAssert(((IUStyleStorage *)storageManager.liveStorage).fontName == nil, @"Pass");

}

- (void)testPerformanceExample {
    /* This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
     */
}

@end
