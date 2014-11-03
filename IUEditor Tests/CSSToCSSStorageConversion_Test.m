//
//  CSSToCSSStorageConversion_Test.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUCSS.h"
#import "IUDataStorage.h"


@interface CSSToCSSStorageConversion_Test : XCTestCase

@end

@implementation CSSToCSSStorageConversion_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBGColor {
    // This is an example of a functional test case.
    IUCSS *css = [[IUCSS alloc] init];
    [css setValue:[NSColor grayColor] forTag:IUCSSTagBGColor];
    
    IUCSSStorageManager *storageManager = [css convertToStorageManager];
    XCTAssertEqual(storageManager.currentViewPort, IUDefaultViewPort);
    XCTAssertEqualObjects(storageManager.currentStorage.bgColor, [NSColor grayColor]);
}

- (void)testFrame {
    IUCSS *css = [[IUCSS alloc] init];
    [css setValue:@(YES) forTag:IUCSSTagXUnitIsPercent];
    [css setValue:@(10) forTag:IUCSSTagPixelX];
    [css setValue:@(20) forTag:IUCSSTagPercentX];
    
    IUCSSStorageManager *storageManager = [css convertToStorageManager];
    XCTAssertEqual(storageManager.currentViewPort, IUDefaultViewPort);
    XCTAssertEqualObjects(storageManager.currentStorage.x, @(20));
    XCTAssertEqualObjects(storageManager.currentStorage.xUnit, @(IUFrameUnitPercent));
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
