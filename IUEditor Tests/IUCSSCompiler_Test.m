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


- (void)test2_frameCode {

//    box.cssLiveStorage.x = @(30);
//    [box.cssLiveStorage setXUnitAndChangeX:@(IUFrameUnitPixel)];

    box.cascadingPositionStorage.position = @(IUPositionTypeAbsolute);
    box.cascadingPositionStorage.x = @(30);
//    box.cssLiveStorage.x = @(30);
//    [box.cssLiveStorage setXUnitAndChangeX:@(IUFrameUnitPixel)];

    IUCSSCode *code = [compiler cssCodeForIU:box];
    NSDictionary *dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    XCTAssertEqualObjects(dict.allKeys, @[@".BOX"]);
    XCTAssertEqualObjects(dict[@".BOX"], @"left:30px;" );
}

- (void)test3_border{
    box.cascadingStyleStorage.borderWidth = @(3);
    box.cascadingStyleStorage.borderColor = [NSColor yellowColor];
    
    XCTAssertEqualObjects(box.currentStyleStorage.borderColor, [NSColor yellowColor]);
    XCTAssertEqualObjects(box.cascadingStyleStorage.leftBorderColor, [NSColor yellowColor]);

    box.cascadingStyleStorage.topBorderColor = nil;
    XCTAssertEqualObjects(box.currentStyleStorage.borderColor, NSMultipleValuesMarker);
    XCTAssertEqualObjects(box.currentStyleStorage.leftBorderColor, [NSColor yellowColor]);
    XCTAssertEqualObjects(box.currentStyleStorage.topBorderColor, nil);
    
    box.cascadingStyleStorage.shadowColorBlur = @(2);
    box.cascadingStyleStorage.shadowColor = [NSColor greenColor];
    
    IUCSSCode *code = [compiler cssCodeForIU:box];
    NSDictionary *dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    XCTAssertEqualObjects(dict.allKeys, @[@".BOX"]);
    XCTAssert([dict[@".BOX"] containsString:@"border-left-color"]);
    XCTAssert([dict[@".BOX"] containsString:@"box-shadow"]);
    
}

- (void)test4_hover{
    box.cascadingStyleStorage.bgColor = [NSColor blueColor];
    ((IUStyleStorage *)box.hoverStyleManager.cascadingStorage).bgColor = [NSColor redColor];
    
    
    XCTAssertEqualObjects(box.cascadingStyleStorage.bgColor, [NSColor blueColor]);
    XCTAssertEqualObjects(((IUStyleStorage *)box.hoverStyleManager.cascadingStorage).bgColor, [NSColor redColor]);
    
    IUCSSCode *code = [compiler cssCodeForIU:box];
    NSDictionary *dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    

    XCTAssert([dict.allKeys containsObject:@".BOX"]);
    XCTAssert([dict[@".BOX"] containsString:@"background-color"]);

    
    XCTAssert([dict.allKeys containsObject:@".BOX:hover"]);
    XCTAssert([dict[@".BOX:hover"] containsString:@"background-color"]);

}

- (void)test5_font{
    box.cascadingPropertyStorage.innerHTML = @"test";
    box.cascadingStyleStorage.fontName = @"Roboto";
    box.cascadingStyleStorage.fontSize = @(13);
    box.cascadingStyleStorage.fontColor = [NSColor blueColor];
    
    box.cascadingStyleStorage.fontAlign = @(IUAlignLeft);
    
    XCTAssertEqualObjects(box.currentStyleStorage.fontName, @"Roboto");
    XCTAssertEqualObjects(box.currentStyleStorage.fontSize, @(13));
    XCTAssertEqualObjects(box.currentStyleStorage.fontColor, [NSColor blueColor]);
    
    
    IUCSSCode *code = [compiler cssCodeForIU:box];
    NSDictionary *dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    
    
    XCTAssert([dict.allKeys containsObject:@".BOX"]);
    XCTAssert([dict[@".BOX"] containsString:@"color"]);
    XCTAssert([dict[@".BOX"] containsString:@"Roboto"]);
    XCTAssert([dict[@".BOX"] containsString:@"text-align"]);
    
}

/*

- (void)test6_bg{
    box.liveStyleStorage.imageName = @"hihihi.jpg";
    box.liveStyleStorage.imageSizeType = @(IUBGSizeTypeStretch);
    box.liveStyleStorage.imageX = @(100);
    box.liveStyleStorage.imageY = @(200);
    
    IUCSSCode *code = [compiler cssCodeForIU:box];
    NSDictionary *dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    
    XCTAssert([dict.allKeys containsObject:@".BOX"]);
    XCTAssert([dict[@".BOX"] containsString:@"background-position-x"]);

    
    box.liveStyleStorage.imageRepeat = @(YES);
    box.liveStyleStorage.imageX = nil;
    box.liveStyleStorage.imageY = nil;
    box.liveStyleStorage.imageVPosition = @(IUCSSBGVPostionTop);
    box.liveStyleStorage.imageHPosition = @(IUCSSBGHPostionLeft);
    
    code = [compiler cssCodeForIU:box];
    dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    
    XCTAssert([dict[@".BOX"] containsString:@"background-repeat"]);
    XCTAssert([dict[@".BOX"] containsString:@"background-position-x"]);
    XCTAssert([dict[@".BOX"] containsString:@"top"]);

}

- (void)test7_position{
    box.livePositionStorage.position = @(IUPositionTypeAbsolute);
    box.livePositionStorage.x = @(20);
    box.livePositionStorage.y = @(50);

    
    IUCSSCode *code = [compiler cssCodeForIU:box];
    NSDictionary *dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    
    XCTAssert([dict.allKeys containsObject:@".BOX"]);
    XCTAssert([dict[@".BOX"] containsString:@"position"]==NO);
    
    box.livePositionStorage.position = @(IUPositionTypeRelative);
    code = [compiler cssCodeForIU:box];
    dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    
    XCTAssert([dict[@".BOX"] containsString:@"position"]);
    XCTAssert([dict[@".BOX"] containsString:@"relative"]);
    XCTAssert([dict[@".BOX"] containsString:@"margin-top"]);

    box.livePositionStorage.position = @(IUPositionTypeFloatLeft);
    code = [compiler cssCodeForIU:box];
    dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    
    XCTAssert([dict[@".BOX"] containsString:@"position"]);
    XCTAssert([dict[@".BOX"] containsString:@"relative"]);
    XCTAssert([dict[@".BOX"] containsString:@"margin-left"]);
    
    
    box.livePositionStorage.position = @(IUPositionTypeFloatRight);
    code = [compiler cssCodeForIU:box];
    dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    
    XCTAssert([dict[@".BOX"] containsString:@"position"]);
    XCTAssert([dict[@".BOX"] containsString:@"relative"]);
    XCTAssert([dict[@".BOX"] containsString:@"margin-right"]);


    box.livePositionStorage.position = @(IUPositionTypeFixed);
    code = [compiler cssCodeForIU:box];
    dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    
    XCTAssert([dict[@".BOX"] containsString:@"position"]);
    XCTAssert([dict[@".BOX"] containsString:@"fixed"]);
    XCTAssert([dict[@".BOX"] containsString:@"z-index"]);
    
    box.livePositionStorage.position = @(IUPositionTypeFixedBottom);
    code = [compiler cssCodeForIU:box];
    dict = [code stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:IUDefaultViewPort];
    
    XCTAssert([dict[@".BOX"] containsString:@"position"]);
    XCTAssert([dict[@".BOX"] containsString:@"fixed"]);
    XCTAssert([dict[@".BOX"] containsString:@"z-index"]);
    XCTAssert([dict[@".BOX"] containsString:@"bottom"]);


}
*/

@end
