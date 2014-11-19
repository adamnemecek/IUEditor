//
//  IUCSSCompiler_Test.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUCSSCompiler.h"

@interface IUCSSCompiler_Test : XCTestCase

@end

@implementation IUCSSCompiler_Test {
    IUCSSCompiler *compiler;
    IUBox *box;
}

- (void)setUp {
    [super setUp];
    compiler = [[IUCSSCompiler alloc] init];
    box = [[IUBox alloc] init];
    box.htmlID = @"BOX";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)test1_XUnit {
    box.cssDefaultManager.liveStorage.x = @(30);

    XCTAssertEqualObjects(box.cssDefaultManager.currentStorage.x, @(30));
    XCTAssertEqualObjects(box.cssDefaultManager.currentStorage.xUnit, @(IUFrameUnitPixel));

    [box.cssDefaultManager.liveStorage setX:@(40) unit:@(IUFrameUnitPercent)];
    XCTAssertEqualObjects(box.cssDefaultManager.currentStorage.x, @(40));
    XCTAssertEqualObjects(box.cssDefaultManager.currentStorage.xUnit, @(IUFrameUnitPercent));
}

- (void)test2_frameCode {

//    box.cssLiveStorage.x = @(30);
//    [box.cssLiveStorage setXUnitAndChangeX:@(IUFrameUnitPixel)];

    box.cssDefaultManager.liveStorage.x = @(30);
//    box.cssLiveStorage.x = @(30);
//    [box.cssLiveStorage setXUnitAndChangeX:@(IUFrameUnitPixel)];

    IUCSSCode *code = [compiler cssCodeForIU_storage:box];
    NSDictionary *dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    XCTAssertEqualObjects(dict.allKeys, @[@".BOX"]);
    XCTAssertEqualObjects(dict[@".BOX"], @"left:30px;" );
}

- (void)test3_border{
    box.cssDefaultManager.liveStorage.borderWidth = @(3);
    box.cssDefaultManager.liveStorage.borderColor = [NSColor yellowColor];
    
    XCTAssertEqualObjects(box.cssDefaultManager.currentStorage.borderColor, [NSColor yellowColor]);
    XCTAssertEqualObjects(box.cssDefaultManager.currentStorage.leftBorderColor, [NSColor yellowColor]);

    box.cssDefaultManager.liveStorage.topBorderColor = nil;
    XCTAssertEqualObjects(box.cssDefaultManager.currentStorage.borderColor, NSMultipleValuesMarker);
    XCTAssertEqualObjects(box.cssDefaultManager.currentStorage.leftBorderColor, [NSColor yellowColor]);
    XCTAssertEqualObjects(box.cssDefaultManager.currentStorage.topBorderColor, nil);
    
    IUCSSCode *code = [compiler cssCodeForIU_storage:box];
    NSDictionary *dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    XCTAssertEqualObjects(dict.allKeys, @[@".BOX"]);
    XCTAssert([dict[@".BOX"] containsString:@"border-left-color"]);
}

- (void)test4_hover{
    box.cssDefaultManager.liveStorage.bgColor = [NSColor blueColor];
    box.cssHoverManager.liveStorage.bgColor = [NSColor redColor];
    
    
    XCTAssertEqualObjects(box.cssDefaultManager.currentStorage.bgColor, [NSColor blueColor]);
    XCTAssertEqualObjects(box.cssHoverManager.currentStorage.bgColor, [NSColor redColor]);
    
    IUCSSCode *code = [compiler cssCodeForIU_storage:box];
    NSDictionary *dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    

    XCTAssert([dict.allKeys containsObject:@".BOX"]);
    XCTAssert([dict[@".BOX"] containsString:@"background-color"]);

    
    XCTAssert([dict.allKeys containsObject:@".BOX:hover"]);
    XCTAssert([dict[@".BOX:hover"] containsString:@"background-color"]);

}


@end
