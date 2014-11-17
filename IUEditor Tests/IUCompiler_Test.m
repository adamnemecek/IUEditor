//
//  IUCompiler_Test.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 13..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUBox.h"
#import "IUProject.h"
#import "IUCompiler.h"

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
    IUCompiler *compiler = [[IUCompiler alloc] init];
    IUProject *project = [[IUProject alloc] initForUnitTestAtTemporaryDirectory];
    IUBox *box = [[IUBox alloc] initWithProject:project options:nil];
    XCTAssertNotNil(box.cssLiveStorage);
    [box.cssLiveStorage setX:@(50)];
    [box.cssLiveStorage setXUnit:@(IUFrameUnitPixel)];

    NSString *htmlCode = [compiler editorHTMLString:box viewPort:IUDefaultViewPort];
    XCTAssertNotNil(htmlCode);
    XCTAssertTrue([htmlCode containsString:@"left: 50px;"]);
}

@end
