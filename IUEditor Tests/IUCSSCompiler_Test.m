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


@end
