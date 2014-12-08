//
//  IUBox_Test.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "IUBox.h"
#import "IUPage.h"
#import "IUClass.h"
#import "IUImport.h"

@interface IUBox_Test : XCTestCase

@end

@implementation IUBox_Test {
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/* this explain how to create box, and how  to use */
- (void)test1_boxCreation {
    IUIdentifierManager *identifierManager = [[IUIdentifierManager alloc] init];
    identifierManager.identifierKeyPath = @"htmlID";
    identifierManager.childrenKeyPath = @"children";
    
    IUBox *box = [[IUBox alloc] initWithPreset];
    box.htmlID = [identifierManager createIdentifierWithPrefix:box.className];
    [identifierManager addObject:box];
    [identifierManager commit];
        
    XCTAssertEqual([identifierManager objectForIdentifier:box.htmlID], box);
    XCTAssertTrue([box.liveStyleStorage.bgColor isKindOfClass:[NSColor class]]);
}

/* this explain how to use import */
- (void)test2_import {
    IUIdentifierManager *identifierManager = [[IUIdentifierManager alloc] init];
    
    IUBox *box = [[IUBox alloc] initWithPreset];
    box.htmlID = [identifierManager createIdentifierWithPrefix:box.className];
    [identifierManager addObject:box];
    
    IUClass *class = [[IUClass alloc] initWithPreset];
    class.htmlID = [identifierManager createIdentifierWithPrefix:class.className];
    [identifierManager addObject:class];
    [class.livePositionStorage setX:@(2000)];

    IUImport *import = [[IUImport alloc] initWithPreset:class];
    import.htmlID = [identifierManager createIdentifierWithPrefix:import.className];
    [identifierManager addObject:import];
    
    [box addIU:import error:nil];
    [identifierManager commit];

    XCTAssertEqual(import.prototypeClass, class);
    XCTAssertEqual(import.livePositionStorage.x, @(2000));
    XCTAssertEqual(import.liveStyleStorage, class.liveStyleStorage);
    XCTAssertEqual(box, import.parent);
}

/* make page and check every value is in */
/* in here, we will not use identifier manager */
- (void)test3_page {
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    class.htmlID = @"class";
    XCTAssertEqual(class.liveStyleStorage.width, @(100));

    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    header.htmlID = @"header";

    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    page.htmlID = @"page";

    XCTAssertEqual(header, page.header);
    XCTAssertNil(page.footer);
}


@end
