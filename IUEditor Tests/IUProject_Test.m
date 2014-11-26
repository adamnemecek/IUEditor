//
//  IUProject_Test.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 13..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "IUProject.h"
#import "IUSourceManager.h"


@interface IUProject_Test : XCTestCase

@end

@implementation IUProject_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_build {
    IUProject *project = [[IUProject alloc] initAtTemporaryDirectory];
    IUSourceManager *sManager = [[IUSourceManager alloc] init];
    [sManager setProject:project];
    [sManager setCompiler:[[IUCompiler alloc] init]];
    BOOL result = [sManager build:nil];
    XCTAssertTrue(result);
    
    /* have every file? */
    NSString *builtPath = [project absoluteBuildPath];
    BOOL isDirectory;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:builtPath isDirectory:&isDirectory]);
    XCTAssertTrue(isDirectory);
}

- (void)test_fileItem {
    IUProject *project = [[IUProject alloc] initAtTemporaryDirectory];
    
    XCTAssertNotNil(project.pageGroup);
    IUSheetGroup *anotherGroup = [[IUSheetGroup alloc] init];
    [project.pageGroup addFileItem:anotherGroup];
    
    XCTAssertEqual(anotherGroup.project, project);
    XCTAssertEqual(anotherGroup.parentFileItem, project.pageGroup);

}

@end
