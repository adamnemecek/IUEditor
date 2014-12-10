//
//  IUCopy_Test.m
//  IUEditor
//
//  Created by seungmi on 2014. 11. 28..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUBoxes.h"
#import "IUIdentifierManager.h"

@interface IUCopy_Test : XCTestCase

@property IUIdentifierManager *identifierManager;

@end

@implementation IUCopy_Test

- (void)setUp {
    [super setUp];
    _identifierManager = [[IUIdentifierManager alloc] init];
    _identifierManager.identifierKey = @"htmlID";
    _identifierManager.childrenKey = @"children";
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

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)test1_styleStorageManager{
    IUDataStorageManager *manager = [[IUDataStorageManager alloc] initWithStorageClassName:[IUStyleStorage class].className];
    ((IUStyleStorage *)manager.defaultStorage).width = @(100);
    
    [manager setCurrentViewPort:640];
    ((IUStyleStorage *)manager.currentStorage).width = @(200);
    
    IUDataStorageManager *copy = [manager copy];
    [copy setCurrentViewPort:640];

    XCTAssertEqual(((IUStyleStorage *)manager.defaultStorage).width, ((IUStyleStorage *)copy.defaultStorage).width);
    XCTAssertEqual(((IUStyleStorage *)manager.currentStorage).width, @(200));

    
}

- (void)test2_positionStorageManager{
    IUDataStorageManager *manager = [[IUDataStorageManager alloc] initWithStorageClassName:[IUPositionStorage class].className];
    ((IUPositionStorage *)manager.defaultStorage).x = @(100);
    
    [manager setCurrentViewPort:640];
    ((IUPositionStorage *)manager.currentStorage).x = @(200);
    
    IUDataStorageManager *copy = [manager copy];
    [copy setCurrentViewPort:640];
    
    XCTAssertEqual(((IUPositionStorage *)manager.defaultStorage).x, ((IUPositionStorage *)copy.defaultStorage).x);
    XCTAssertEqual(((IUPositionStorage *)manager.currentStorage).x, @(200));
}

- (void)test3_IUBox{
    IUBox *iu = [[IUBox alloc] initWithPreset];
    iu.htmlID = @"test1";
    [_identifierManager addObject:iu];
    iu.identifierManager = _identifierManager;
    
    
    iu.defaultStyleStorage.width = @(200);
    XCTAssertEqual(iu.defaultStyleStorage.width, @(200));
    
    [iu.defaultStyleManager setCurrentViewPort:640];
    iu.currentStyleStorage.width = @(400);

    
    IUBox *copyIU = [iu copy];
    [copyIU.defaultStyleManager setCurrentViewPort:640];
    
    XCTAssertEqual(iu.defaultStyleStorage.width, copyIU.defaultStyleStorage.width);
    XCTAssertEqual(copyIU.defaultStyleStorage.width, @(200));
    XCTAssertEqual(copyIU.currentStyleStorage.width, @(400));

}

- (void)test4_children{
    IUBox *iu = [[IUBox alloc] initWithPreset];
    iu.htmlID = @"test1";
    iu.identifierManager = _identifierManager;
    
    IUBox *child = [[IUBox alloc] initWithPreset];
    [iu addIU:child error:nil];
    
    [_identifierManager addObject:iu];
    
    IUBox *copyIU = [iu copy];

    XCTAssertEqual(copyIU.children.count, 1);
}

- (void)test5_IUImport{
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUImport *import = [[IUImport alloc] initWithPreset:class];
    
    IUImport *copy = [import copy];
    XCTAssertEqual(copy.class, import.class);
}
@end
