//
//  IUCSSStorage_Test.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "IUDataStorage.h"
#import "IUStyleStorage.h"
#import "IUPositionStorage.h"

@interface IUDataStorage_Test : XCTestCase  <IUDataStorageManagerDelegate>

@end

@implementation IUDataStorage_Test {
    IUDataStorageManager *styleManager;
    IUDataStorageManager *positionManager;
    BOOL updateCalled;
}

- (void)setUp {
    [super setUp];
    styleManager = [[IUDataStorageManager alloc] initWithStorageClassName:[IUStyleStorage class].className];
    positionManager = [[IUDataStorageManager alloc] initWithStorageClassName:[IUPositionStorage class].className];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)setNeedsToUpdateStorage:(IUDataStorage*)storage{
    updateCalled = YES;
}


- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (IUStyleStorage *)styleLiveStorage{
    return (IUStyleStorage *)styleManager.liveStorage;
}
- (IUPositionStorage *)positionLiveStorage{
    return (IUPositionStorage *)positionManager.liveStorage;
}


- (void)test1_XUnit {
    self.positionLiveStorage.x = @(100);
    XCTAssertEqualObjects([self positionLiveStorage].x, @(100));
}

- (void)test2_delegate {
    self.positionLiveStorage.x = @(100);
    XCTAssertEqualObjects(((IUPositionStorage *)positionManager.currentStorage).x, @(100));
}


- (void)test3_copy{
    [[self positionLiveStorage] setX:@(40) unit:@(IUFrameUnitPixel)];
    XCTAssertEqualObjects(((IUPositionStorage *)positionManager.currentStorage).x, ((IUPositionStorage *)positionManager.currentStorage).x);

    [[self positionLiveStorage] setX:@(50)];
    XCTAssertEqualObjects(((IUPositionStorage *)positionManager.currentStorage).x, ((IUPositionStorage *)positionManager.currentStorage).x);
    

}

- (void)test4_frame{
    [[self positionLiveStorage] setX:@(40) unit:@(IUFrameUnitPixel)];
    
    XCTAssertEqualObjects(((IUPositionStorage *)positionManager.currentStorage).x, ((IUPositionStorage *)positionManager.currentStorage).x);
    XCTAssertEqualObjects(((IUPositionStorage *)positionManager.currentStorage).x, @(40));
    XCTAssertEqualObjects(((IUPositionStorage *)positionManager.currentStorage).xUnit, @(IUFrameUnitPixel));

    [[self positionLiveStorage] setX:@(20) unit:@(IUFrameUnitPercent)];
    
    XCTAssertEqualObjects(((IUPositionStorage *)positionManager.currentStorage).x, ((IUPositionStorage *)positionManager.currentStorage).x);
    XCTAssertEqualObjects(((IUPositionStorage *)positionManager.currentStorage).x, @(20));
    XCTAssertEqualObjects(((IUPositionStorage *)positionManager.currentStorage).xUnit, @(IUFrameUnitPercent));

}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
