//
//  JDCoder+IUProject_Test.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 10. 27..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUProject.h"

@interface JDCoder_IUProject_Test : XCTestCase

@end

@implementation JDCoder_IUProject_Test{
    IUProject *project;
    NSString *filePath;
}

- (void)setUp {
    [super setUp];
    filePath = [NSString stringWithFormat:@"%@/sampleProject.iuml", NSTemporaryDirectory()];
    project = [[IUProject alloc] initWithCreation:@{IUProjectKeyAppName:@"sampleProject", IUProjectKeyIUFilePath:filePath}  error:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1_encodeDecode {
    // This is an example of a functional test case.
    JDCoder *encoder = [[JDCoder alloc] init];
    [encoder encodeRootObject:project];
    XCTAssert(YES, @"Pass");
}

- (void)test2_saveLoad{
    JDCoder *encoder = [[JDCoder alloc] init];
    [encoder encodeRootObject:project];
    NSLog(@"file save path: %@", filePath, nil);
    [encoder writeToFile:filePath error:nil];

    JDCoder *decoder = [[JDCoder alloc] init];
    IUProject *proj = [decoder decodeContentOfFile:filePath error:nil];
    XCTAssertEqualObjects(proj.name, @"sampleProject");
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
