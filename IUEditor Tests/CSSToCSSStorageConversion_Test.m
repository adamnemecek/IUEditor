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
#import "IUPositionStorage.h"
#import "IUStyleStorage.h"


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

#if 0
//IUCSS is deprecated

- (void)testBGColor {
    // This is an example of a functional test case.
    IUCSS *css = [[IUCSS alloc] init];
    [css setValue:[NSColor grayColor] forTag:IUCSSTagBGColor];
    
    IUDataStorageManager *storageManager = [css convertToStyleStorageDefaultManager];
    XCTAssertEqual(storageManager.currentViewPort, IUDefaultViewPort);
    XCTAssertEqualObjects(((IUStyleStorage *)storageManager.currentStorage).bgColor, [NSColor grayColor]);
}

- (void)testFrame {
    IUCSS *css = [[IUCSS alloc] init];
    [css setValue:@(YES) forTag:IUCSSTagXUnitIsPercent];
    [css setValue:@(10) forTag:IUCSSTagPixelX];
    [css setValue:@(20) forTag:IUCSSTagPercentX];
    
    IUDataStorageManager *storageManager = [css convertToPositionStorageDefaultManager];
    XCTAssertEqual(storageManager.currentViewPort, IUDefaultViewPort);
    XCTAssertEqualObjects(((IUPositionStorage *)storageManager.currentStorage).x, @(20));
    XCTAssertEqualObjects(((IUPositionStorage *)storageManager.currentStorage).xUnit, @(IUFrameUnitPercent));
}


- (void)testBorderColor{
    IUCSS *css = [[IUCSS alloc] init];
    [css setValue:[NSColor grayColor] forTag:IUCSSTagBorderColor];
    IUDataStorageManager *storageManager = [css convertToStyleStorageDefaultManager];
    XCTAssertEqual(storageManager.currentViewPort, IUDefaultViewPort);
    XCTAssertEqualObjects(((IUStyleStorage *)storageManager.currentStorage).borderColor, [NSColor grayColor]);
    
    [css setValue:[NSColor redColor] forTag:IUCSSTagBorderLeftColor];
    storageManager = [css convertToStyleStorageDefaultManager];
    XCTAssertEqual(storageManager.currentViewPort, IUDefaultViewPort);
    XCTAssertEqualObjects(((IUStyleStorage *)storageManager.currentStorage).borderColor, NSMultipleValuesMarker);
    XCTAssertEqualObjects(((IUStyleStorage *)storageManager.currentStorage).leftBorderColor, [NSColor redColor]);

}

- (void)test_bg{
    IUCSS *css = [[IUCSS alloc] init];
    [css setValue:@(IUBGSizeTypeFull) forTag:IUCSSTagBGSize];
    
    
    IUDataStorageManager *storageManager = [css convertToStyleStorageDefaultManager];
    XCTAssertEqual(storageManager.currentViewPort, IUDefaultViewPort);
    XCTAssertEqualObjects(((IUStyleStorage *)storageManager.currentStorage).imageSizeType, @(IUBGSizeTypeCover));
    XCTAssertEqualObjects(((IUStyleStorage *)storageManager.currentStorage).imageAttachment, @(YES));

}
#endif
@end
