//
//  IUSheetController_Test.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUBoxes.h"
#import "IUProject.h"
#import "IUSheetController.h"

@interface IUSheetController_Test : XCTestCase

@property IUProject *project;
@property IUSheetController *pagesController;
@property IUSheetController *classesController;



@end

@implementation IUSheetController_Test{
    XCTestExpectation *expectation;
}

- (void)setUp {
    [super setUp];
    
    _project = [[IUProject alloc] initAtTemporaryDirectory];
    _pagesController = [[IUSheetController alloc] initWithSheetGroup:_project.pageGroup];
    _classesController = [[IUSheetController alloc] initWithSheetGroup:_project.classGroup];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1_alloc{

    XCTAssertEqualObjects(_pagesController.project, _project);
}

- (void)test2_addandSelection{
    IUSheetGroup *sheetGroup = [[IUSheetGroup alloc] init];
    sheetGroup.name = @"test2Add";
    
    [_project.pageGroup addFileItem:sheetGroup];
    
    NSIndexPath *indexPath = [_pagesController firstIndexPathOfObject:sheetGroup];
    
    XCTAssert(indexPath);
    
    [_pagesController setSelectedObject:sheetGroup];
    XCTAssertEqual([[[_pagesController selectedObjects] firstObject] name], @"test2Add");

}

- (void)test3_notification{
    expectation = [self expectationWithDescription:@"sheetController"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listen:) name:IUNotificationSheetSelectionDidChange object:nil];
    
    
    [_pagesController setSelectedObject:[_project.pageGroup.childrenFileItems firstObject]];
    
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssert(YES, @"Pass");
    }];

}


- (void)listen:(NSNotification *)noti{
    [expectation fulfill];
}



@end
