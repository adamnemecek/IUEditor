//
//  IUCSSStorage_Test.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "IUDataStorage.h"

@interface IUCSSStorage_Test : XCTestCase  <IUDataStorageManagerDelegate>

@end

@implementation IUCSSStorage_Test {
    IUCSSStorageManager *storageManager;
    BOOL updateCalled;
}

- (void)setUp {
    [super setUp];
    storageManager = [[IUCSSStorageManager alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)setNeedsToUpdateStorage:(IUDataStorage*)storage{
    updateCalled = YES;
}


- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1_XUnit {
    storageManager.liveStorage.x = @(100);
    XCTAssertEqualObjects(storageManager.liveStorage.x, @(100));
}

- (void)test2_delegate {
    storageManager.liveStorage.x = @(100);
    XCTAssertEqualObjects(storageManager.currentStorage.x, @(100));
}



- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
