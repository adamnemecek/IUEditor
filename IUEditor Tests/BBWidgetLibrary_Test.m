//
//  BBWidgetLibrary_Test.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 12. 2..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "IUProject.h"
#import "BBWidgetLibraryVC.h"

#import "IUTestWC.h"

@interface BBWidgetLibrary_Test : XCTestCase

@end

@implementation BBWidgetLibrary_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1 {
    IUTestWC *testWC = [[IUTestWC alloc] initWithWindowNibName:@"IUTestWC"];
    [self expectationWithDescription:@"load"];

    [testWC showWindow:nil];

    BBWidgetLibraryVC *vc = [[BBWidgetLibraryVC alloc] initWithNibName:@"BBWidgetLibraryVC" bundle:nil];
    [vc loadView];
    [[[testWC window] contentView] addSubview:vc.view];
    
    NSPopUpButton *popupButton = vc.groupSelectPopupBtn;
    [vc setWidgets:[IUProject widgets]];
    
    XCTAssertEqualObjects([[vc.groupSelectPopupBtn selectedItem] title], @"Base");

    [popupButton selectItemAtIndex:0];
    NSLog([[vc widgetInfosInCurrentSelectedGroup] description], nil);
        
    [self waitForExpectationsWithTimeout:200 handler:^(NSError *error) {
        XCTAssert(YES, @"Pass");
    }];

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
