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

- (void)listen:(NSNotification *)noti{
    if (noti.userInfo[IUWidgetLibraryKey]) {
        testWC.log = noti.userInfo[IUWidgetLibraryKey];
    }
    else {
        testWC.log = @"Not selected";
    }
}


@end
