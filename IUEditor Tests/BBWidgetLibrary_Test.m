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

@interface BBWidgetLibrary_Test : XCTestCase <IUTestWCDelegate>

@end

@implementation BBWidgetLibrary_Test {
    BOOL _result;
    IUTestWC *testWC;
    BBWidgetLibraryVC *vc;
    XCTestExpectation *expectation;
}

- (void)setUp {
    [super setUp];
    expectation = [self expectationWithDescription:@"bbwidgettt"];

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWCReturned:(BOOL)result {
    _result = result;
    [expectation fulfill];
}


- (void)test1 {
    testWC = [[IUTestWC alloc] initWithWindowNibName:@"IUTestWC"];
    testWC.delegate = self;

    [testWC showWindow:nil];

    vc = [[BBWidgetLibraryVC alloc] initWithNibName:@"BBWidgetLibraryVC" bundle:nil];
    [vc loadView];
    [[[testWC window] contentView] addSubview:vc.view];
    
    [vc setWidgets:[IUProject widgets]];
    
    XCTAssertEqualObjects([[vc.groupSelectPopupBtn selectedItem] title], @"Base");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        vc.selectedGroupIndex = 1;
    });
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssert(_result, @"Pass");
    }];

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
