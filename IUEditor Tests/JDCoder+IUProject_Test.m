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
#import "IUBoxes.h"

@interface JDCoder_IUProject_Test : XCTestCase

@end

@implementation JDCoder_IUProject_Test{
    IUProject *project;
    NSString *filePath;
}

- (void)setUp {
    [super setUp];
    filePath = [NSString stringWithFormat:@"%@/sampleProject.iuml", NSTemporaryDirectory()];
    project = [[IUProject alloc] initAtTemporaryDirectory];
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

- (void)test2_saveLoadProject{
    
    project.name= @"sampleProject";
    
    JDCoder *encoder = [[JDCoder alloc] init];
    [encoder encodeRootObject:project];
    NSLog(@"file save path: %@", filePath, nil);
    [encoder writeToFilePath:filePath error:nil];

    JDCoder *decoder = [[JDCoder alloc] init];
    IUProject *decodeProject = [decoder decodeContentOfFilePath:filePath error:nil];
    XCTAssertEqualObjects(decodeProject.name, @"sampleProject");
}

- (void)test3_saveLoadChild{
    project.name= @"sampleProject";
    IUPage *page = project.pageGroup.childrenFileItems[0];
    page.name = @"hahaha";
    
    JDCoder *encoder = [[JDCoder alloc] init];
    [encoder encodeRootObject:project];
    NSLog(@"file save path: %@", filePath, nil);
    [encoder writeToFilePath:filePath error:nil];
    
    JDCoder *decoder = [[JDCoder alloc] init];
    IUProject *decodeProject = [decoder decodeContentOfFilePath:filePath error:nil];
    IUPage *decodedPage = decodeProject.pageGroup.childrenFileItems[0];

    XCTAssertEqualObjects(decodeProject.name, @"sampleProject");
    XCTAssertEqualObjects(decodedPage.name, @"hahaha");

}


@end
