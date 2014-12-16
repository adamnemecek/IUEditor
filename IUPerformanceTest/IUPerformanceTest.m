//
//  IUPerformanceTest.m
//  IUPerformanceTest
//
//  Created by Joodong Yang on 2014. 12. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "BBWC.h"
#import "IUBox.h"
#import "JDLogUtil.h"

@interface IUPerformanceTest : XCTestCase

@end

@implementation IUPerformanceTest {
    IUProject *project;
    BBWC *wc;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformance_1 {
    [self measureBlock:^{
        for (int i=0; i<200; i++){
            IUBox *box = [[IUBox alloc] init];
            box = nil;
        }
    }];
}

- (void)test_binding {
    project = [[IUProject alloc] initForUntitledDocument];
    wc = [[BBWC alloc] initWithWindowNibName:@"BBWC"];
    [wc setProject:project];
    [wc showWindow:nil];
}

@end