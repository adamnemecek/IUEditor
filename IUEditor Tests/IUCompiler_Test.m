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
    IUIdentifierManager *identifierManager = [[IUIdentifierManager alloc] init];
    IUBox *box = [[IUBox alloc] initWithPreset];
    box.htmlID = [identifierManager createIdentifierWithKey:box.className];
    [identifierManager addObject:box withIdentifier:box.htmlID];
    [identifierManager commit];
    
    XCTAssertEqual([identifierManager objectForIdentifier:box.htmlID], box);
    XCTAssertTrue([box.liveStyleStorage.bgColor isKindOfClass:[NSColor class]]);
    
    
    XCTAssertNotNil(box.liveStyleStorage);
    [box.livePositionStorage setX:@(50) unit:@(IUFrameUnitPixel)];
    XCTAssertTrue([box.livePositionStorage.x isEqualToNumber:@(50)]);

    XCTAssertTrue([box.currentPositionStorage.x isEqualToNumber:@(50)]);
    XCTAssertTrue([box.currentPositionStorage.x isEqualToNumber:box.livePositionStorage.x]);
    
    
    IUCompiler *compiler = [[IUCompiler alloc] init];
    NSString *htmlCode = [compiler editorHTMLString:box viewPort:IUDefaultViewPort];
    XCTAssertNotNil(htmlCode);
    XCTAssertTrue([htmlCode containsString:@"left: 50px;"]);
}

- (void)test2_Import {
    /* How to use class-import */
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    class.htmlID = @"class";
    
    IUImport *import = [[IUImport alloc] initWithPreset:class];
    import.htmlID = @"import";
    
    IUCompiler *compiler = [[IUCompiler alloc] init];
    NSString *src = [compiler editorHTMLString:import viewPort:IUDefaultViewPort];

    NSLog(src, nil);
    /*code not generated */
    XCTAssertFalse(YES);
}



@end
