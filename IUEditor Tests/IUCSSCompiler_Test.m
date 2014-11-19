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
    box.livePositionStorage.x = @(30);
    XCTAssertEqualObjects(box.currentPositionStorage.x, @(30));
    XCTAssertEqualObjects(box.currentPositionStorage.xUnit, @(IUFrameUnitPixel));
}

- (void)test2_frameCode {

//    box.cssLiveStorage.x = @(30);
//    [box.cssLiveStorage setXUnitAndChangeX:@(IUFrameUnitPixel)];

    box.livePositionStorage.x = @(30);
//    box.cssLiveStorage.x = @(30);
//    [box.cssLiveStorage setXUnitAndChangeX:@(IUFrameUnitPixel)];

    IUCSSCode *code = [compiler cssCodeForIU_storage:box];
    NSDictionary *dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    XCTAssertEqualObjects(dict.allKeys, @[@".BOX"]);
    XCTAssertEqualObjects(dict[@".BOX"], @"left:30px;" );
}

- (void)test3_border{
    box.liveStyleStorage.borderWidth = @(3);
    box.liveStyleStorage.borderColor = [NSColor yellowColor];
    
    XCTAssertEqualObjects(box.currentStyleStorage.borderColor, [NSColor yellowColor]);
    XCTAssertEqualObjects(box.liveStyleStorage.leftBorderColor, [NSColor yellowColor]);

    box.liveStyleStorage.topBorderColor = nil;
    XCTAssertEqualObjects(box.currentStyleStorage.borderColor, NSMultipleValuesMarker);
    XCTAssertEqualObjects(box.currentStyleStorage.leftBorderColor, [NSColor yellowColor]);
    XCTAssertEqualObjects(box.currentStyleStorage.topBorderColor, nil);
    
    IUCSSCode *code = [compiler cssCodeForIU_storage:box];
    NSDictionary *dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    XCTAssertEqualObjects(dict.allKeys, @[@".BOX"]);
    XCTAssert([dict[@".BOX"] containsString:@"border-left-color"]);
}

- (void)test4_hover{
    box.liveStyleStorage.bgColor = [NSColor blueColor];
    ((IUStyleStorage *)box.hoverStyleManager.liveStorage).bgColor = [NSColor redColor];
    
    
    XCTAssertEqualObjects(box.liveStyleStorage.bgColor, [NSColor blueColor]);
    XCTAssertEqualObjects(((IUStyleStorage *)box.hoverStyleManager.liveStorage).bgColor, [NSColor redColor]);
    
    IUCSSCode *code = [compiler cssCodeForIU_storage:box];
    NSDictionary *dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    

    XCTAssert([dict.allKeys containsObject:@".BOX"]);
    XCTAssert([dict[@".BOX"] containsString:@"background-color"]);

    
    XCTAssert([dict.allKeys containsObject:@".BOX:hover"]);
    XCTAssert([dict[@".BOX:hover"] containsString:@"background-color"]);

}


@end
