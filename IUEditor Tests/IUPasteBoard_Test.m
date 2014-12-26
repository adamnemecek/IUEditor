//
//  IUPasteBoard_Test.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 26..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUBoxes.h"

@interface IUPasteBoard_Test : XCTestCase

@property NSPasteboard *pboard;

@end

@implementation IUPasteBoard_Test

- (void)setUp {
    [super setUp];
    _pboard = [NSPasteboard generalPasteboard];
    [_pboard declareTypes:@[kUTTypeIUData, NSPasteboardTypeString] owner:self];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test01_box{
    IUBox *box = [[IUBox alloc] init];
    [_pboard clearContents];
    BOOL isWritten = [_pboard writeObjects:@[box]];
    XCTAssert(isWritten, @"Pass");

    
    BOOL ok = [_pboard canReadObjectForClasses:@[[IUBox class]] options:nil];
    XCTAssert(ok, @"Pass");

    NSArray *copied = [_pboard readObjectsForClasses:@[[IUBox class]] options:nil];
    XCTAssertEqual(copied.count, 1);
    IUBox *copiedBox = [copied objectAtIndex:0];
    
    XCTAssertEqualObjects(copiedBox.htmlID, box.htmlID);

}


- (void)test02_htmlID{
    IUBox *box = [[IUBox alloc] init];
    [_pboard clearContents];
    BOOL isWritten = [_pboard writeObjects:@[box]];
    XCTAssert(isWritten, @"Pass");
    
    
    BOOL ok = [_pboard canReadObjectForClasses:@[[NSString class]] options:nil];
    XCTAssert(ok, @"Pass");
    
    NSArray *copied = [_pboard readObjectsForClasses:@[[NSString class]] options:nil];
    XCTAssertEqual(copied.count, 1);
    NSString *identifier = [copied objectAtIndex:0];
    
    XCTAssertEqualObjects([box htmlID], identifier);
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
