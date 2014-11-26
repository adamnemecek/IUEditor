//
//  IUPropertyStorage_Test.m
//  IUEditor
//
//  Created by seungmi on 2014. 11. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUMQData.h"
#import "IUPropertyStorage.h"

@interface IUPropertyStorage_Test : XCTestCase

@end

@implementation IUPropertyStorage_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)test1_convert{
    // This is an example of a functional test case.
    IUMQData *mqData = [[IUMQData alloc] init];
    [mqData setValue:@"texttext" forTag:IUMQDataTagInnerHTML];
    [mqData setValue:@(4) forTag:IUMQDataTagCollectionCount];
    
    IUDataStorageManager *storageManager = [mqData convertToPropertyStorageManager];
    XCTAssertEqual(storageManager.currentViewPort, IUDefaultViewPort);
    XCTAssertEqualObjects(((IUPropertyStorage *)storageManager.currentStorage).innerHTML, @"texttext");
    XCTAssertEqualObjects(((IUPropertyStorage *)storageManager.currentStorage).collectionCount, @(4));
}

- (void)test2_dictionary{
    IUDataStorageManager *storageManager = [[IUDataStorageManager alloc] initWithStorageClassName:[IUPropertyStorage class].className];
    IUPropertyStorage *defaultStorage = (IUPropertyStorage *)[storageManager storageForViewPort:IUDefaultViewPort];
    defaultStorage.innerHTML = @"hahaha";
    
    [storageManager setCurrentViewPort:650];
    IUPropertyStorage *tabletStorage = (IUPropertyStorage *)[storageManager storageForViewPort:650];
    tabletStorage.innerHTML = @"hihihi";
    
    [storageManager setCurrentViewPort:320];
    IUPropertyStorage *mobileStorage = (IUPropertyStorage *)[storageManager storageForViewPort:320];
    mobileStorage.innerHTML = @"hehehe";
    
    
    NSDictionary *dictionary = [storageManager dictionaryWithWidthForKey:@"innerHTML"];
    
    XCTAssertEqual(dictionary.count, 3);
    XCTAssertEqual(dictionary[@(IUDefaultViewPort)], @"hahaha");
    XCTAssertEqual(dictionary[@(650)], @"hihihi");
    XCTAssertEqual(dictionary[@(320)], @"hehehe");
}

@end
