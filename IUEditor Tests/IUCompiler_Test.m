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
    IUBox *box = [[IUBox alloc] init];
    
    XCTAssertNotNil(box.cascadingStyleStorage);
    [box.cascadingPositionStorage setFirstPosition:@(IUFirstPositionTypeAbsolute)];
    [box.cascadingPositionStorage setX:@(50) unit:@(IUFrameUnitPixel)];
    XCTAssertTrue([box.cascadingPositionStorage.x isEqualToNumber:@(50)]);

    XCTAssertTrue([box.currentPositionStorage.x isEqualToNumber:@(50)]);
    XCTAssertTrue([box.currentPositionStorage.x isEqualToNumber:box.cascadingPositionStorage.x]);
    
    
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

- (void)test4_Import {
    /* How to use class-import */
    IUBox *box = [[IUBox alloc] init];
    box.htmlID = @"box1";
    
    IUClass *classObj = [[IUClass alloc] init];
    classObj.htmlID = @"class";
    [classObj addIU:box error:nil];
    
    IUImport *import = [[IUImport alloc] initWithPreset:classObj];
    import.htmlID = @"import";
    import.prototypeClass = classObj;
    XCTAssertEqual(import.cascadingPropertyStorage, classObj.cascadingPropertyStorage);
    
    IUCompiler *compiler = [[IUCompiler alloc] init];
    NSString *htmlCode;
    [compiler editorIUSource:import htmlIDPrefix:nil viewPort:import.maxViewPort htmlSource:&htmlCode nonInlineCSSSource:nil];

    XCTAssertTrue([htmlCode containsString:@"box1"]);
}

- (void)test5_HTML {
    IUHTML *html = [[IUHTML alloc] initWithPreset];
    NSString *innerHTML = @"<div>Hello World</div>";
    html.innerHTML = innerHTML;
    
    IUCompiler *compiler = [[IUCompiler alloc] init];
    NSString *htmlCode;
    [compiler editorIUSource:html htmlIDPrefix:nil viewPort:IUDefaultViewPort htmlSource:&htmlCode nonInlineCSSSource:nil];

    XCTAssertTrue([htmlCode containsString:innerHTML]);
}

@end
