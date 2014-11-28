//
//  IUCopy_Test.m
//  IUEditor
//
//  Created by seungmi on 2014. 11. 28..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUBoxes.h"

@interface IUCopy_Test : XCTestCase

@end

@implementation IUCopy_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)test1_StorageManager{
    IUDataStorageManager *manager = [[IUDataStorageManager alloc] initWithStorageClassName:[IUStyleStorage class].className];
    ((IUStyleStorage *)manager.defaultStorage).width = @(100);
    
}

- (void)test2_IUBox{
    IUBox *iu = [[IUBox alloc] initWithPreset];
    
    IUBox *copyIU = [iu copy];
    XCTAssertEqual(iu.defaultStyleStorage.width, copyIU.defaultStyleStorage.width);
}

@end
