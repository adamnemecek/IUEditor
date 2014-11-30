//
//  IUResource_Test.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 30..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "IUResource.h"

@interface IUResource_Test : XCTestCase

@end

@implementation IUResource_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1_resource {
    NSString *dir = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"rand%d", arc4random()/1000]];
    NSString *fileDir = [dir stringByAppendingPathComponent:@"images/jpeg"];
    NSError *err;
    [[NSFileManager defaultManager] createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:0 error:&err];
    NSString *bundleJPEGPath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"jpg"];
    [[NSFileManager defaultManager] copyItemAtPath:bundleJPEGPath toPath:[fileDir stringByAppendingPathComponent:@"sample.jpg"] error:&err];
    
    IUResourceRootItem *root = [[IUResourceRootItem alloc] init];
    [root loadFromPath:dir];
    
    XCTAssertEqual(root.children.count, 1);
    IUResourceGroupItem *imageGroup = root.children[0];
    XCTAssertEqual(imageGroup.children.count, 1);
    XCTAssertEqualObjects(imageGroup.name, @"images");

    IUResourceGroupItem *jpegGroup = imageGroup.children[0];
    XCTAssertEqual(jpegGroup.children.count, 1);
    XCTAssertEqualObjects(jpegGroup.name, @"jpeg");
    
    IUResourceFileItem *sampleJPEGItem = jpegGroup.children[0];
    XCTAssertEqualObjects(sampleJPEGItem.name, @"sample.jpg");
    XCTAssertTrue([sampleJPEGItem isKindOfClass:[IUResourceFileItem class]]);
    
    NSArray *arr = [root imageResourceItems];
    XCTAssertEqual(sampleJPEGItem, arr[0]);
}

@end
