//
//  IUCompiler_Test.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 13..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUProject.h"
#import "IUCompiler.h"
#import "IUBoxes.h"
#import "IUResource.h"

@interface IUCompiler_Test : XCTestCase

@end

@implementation IUCompiler_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1_BOX {
    IUBox *box = [[IUBox alloc] initWithPreset];
    XCTAssertTrue([box.liveStyleStorage.bgColor isKindOfClass:[NSColor class]]);
    
    
    XCTAssertNotNil(box.liveStyleStorage);
    [box.livePositionStorage setX:@(50) unit:@(IUFrameUnitPixel)];
    XCTAssertTrue([box.livePositionStorage.x isEqualToNumber:@(50)]);

    XCTAssertTrue([box.currentPositionStorage.x isEqualToNumber:@(50)]);
    XCTAssertTrue([box.currentPositionStorage.x isEqualToNumber:box.livePositionStorage.x]);
    
    
    IUCompiler *compiler = [[IUCompiler alloc] init];
    NSString *htmlCode;
    [compiler editorIUSource:box htmlIDPrefix:nil viewPort:IUDefaultViewPort htmlSource:&htmlCode nonInlineCSSSource:nil];
    XCTAssertTrue([htmlCode containsString:@"left:50px;"]);
}

- (void)test2_BOX_COMPLEX{
    IUBox *box = [[IUBox alloc] init];
    box.htmlID = @"Box1";

    IUBox *box2 = [[IUBox alloc] init];
    box2.htmlID = @"Box2";
    
    [box addIU:box2 error:nil];

    
    IUCompiler *compiler = [[IUCompiler alloc] init];
    NSString *htmlCode;
    [compiler editorIUSource:box htmlIDPrefix:nil viewPort:IUDefaultViewPort htmlSource:&htmlCode nonInlineCSSSource:nil];
    XCTAssertTrue([htmlCode containsString:@"Box2"]);
}

- (void)test3_Image {
    IUImage *image = [[IUImage alloc] init];
    image.imagePath = @"image.jpg";
    IUCompiler *compiler = [[IUCompiler alloc] init];

    NSString *htmlCode;
    [compiler editorIUSource:image htmlIDPrefix:nil viewPort:IUDefaultViewPort htmlSource:&htmlCode nonInlineCSSSource:nil];
    XCTAssertTrue([htmlCode containsString:@"img"]);
}

- (void)test2_Import {
    /* How to use class-import */
    IUClass *classObj = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    classObj.htmlID = @"class";
    
    IUImport *import = [[IUImport alloc] initWithPreset:classObj];
    import.htmlID = @"import";
    import.prototypeClass = classObj;
    XCTAssertEqual(import.livePropertyStorage, classObj.livePropertyStorage);
    
    IUCompiler *compiler = [[IUCompiler alloc] init];
    NSString *htmlCode;
    [compiler editorIUSource:import htmlIDPrefix:nil viewPort:IUDefaultViewPort htmlSource:&htmlCode nonInlineCSSSource:nil];

    /*code not generated */
    XCTAssertFalse(YES);
}


@end
