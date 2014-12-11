//
//  IUController_Test.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 11..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUController.h"
#import "IUBoxes.h"

@interface IUController_Test : XCTestCase

@property IUController *iuController;
@property IUPage *page;

@end

@implementation IUController_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _iuController = [[IUController alloc] init];
    _page = [[IUPage alloc] initWithPreset];
    [_iuController setContent:_page];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test01_content{
    IUBox *box = [_iuController firstDeepestBox];
    XCTAssertEqual(box.parent.parent, _page.pageContent);
}

- (void)test02_selectbyiu{
    [_iuController setSelectedObject:_page.pageContent];
    XCTAssertEqual(1, _iuController.selectedObjects.count);
    XCTAssertEqual(_page.pageContent, [_iuController.selectedObjects objectAtIndex:0]);
}

- (void)test03_newIU{
    IUBox *newIU  = [[IUBox alloc] initWithPreset];
    [_page.pageContent addIU:newIU error:nil];
    [_iuController setSelectedObject:newIU];

    XCTAssertEqual(1, _iuController.selectedObjects.count);
    XCTAssertEqual(newIU, [_iuController.selectedObjects objectAtIndex:0]);

}

- (void)test04_newIU{
    IUBox *newIU  = [[IUBox alloc] initWithPreset];
    IUSection *section = [_page.pageContent.children objectAtIndex:0];
    [section addIU:newIU error:nil];
    [_iuController setSelectedObject:newIU];
    
    XCTAssertEqual(1, _iuController.selectedObjects.count);
    XCTAssertEqual(newIU, [_iuController.selectedObjects objectAtIndex:0]);
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
