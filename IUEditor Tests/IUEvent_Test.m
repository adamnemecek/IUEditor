//
//  IUEvent_Test.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 23..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUEventCompiler.h"

@interface IUEvent_Test : XCTestCase

@end

@implementation IUEvent_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1_IUBoxWithEvent {
    IUBox *box = [[IUBox alloc] init];
    box.htmlID = @"trigger";
    IUBox *box2 = [[IUBox alloc] init];
    box2.htmlID = @"receiver";

    IUEvent2 *event = [[IUEvent2 alloc] init];
    event.minViewPortCondition = 100;
    event.maxViewPortCondition = IUDefaultViewPort;
    event.type = IUEventTypeClick;
    event.receiver = box2;
    event.styleAction = [[IUEventStyleAction alloc] init];
    event.styleAction.visible = @"0";
    
    [box addEvent:event];
    [box2 addEventCalledByOtherIU:event];
    
//    IUEventCompiler *compiler = [[IUEventCompiler alloc] init];
//    NSDictionary *rule = [compiler unitEventRuleCode:box];
    
    XCTAssertFalse(@"error");
}

@end
