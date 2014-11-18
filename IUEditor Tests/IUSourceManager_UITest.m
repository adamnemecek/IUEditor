//
//  IUSourceManager_UITest.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUSourceManager.h"
#import "IUCompiler.h"
#import "IUTestWC.h"
#import "IUProject.h"
#import "IUPage.h"

@interface IUSourceManager_UITest : XCTestCase <IUTestWCDelegate, IUProjectProtocol>

@end

static     IUTestWC *testWC;

@implementation IUSourceManager_UITest {
    WebView *webView;
    BOOL result;
    XCTestExpectation *webViewLoadingExpectation;
    IUSourceManager *manager;
}

- (void)setUp {
    [super setUp];
    if (testWC == nil) {
        testWC = [[IUTestWC alloc] initWithWindowNibName:@"IUTestWC"];
        testWC.delegate = self;
        [testWC showWindow:nil];
    }
    manager = [[IUSourceManager alloc] init];
    manager.viewPort = IUCSSDefaultViewPort;
    manager.frameWidth = 960;
    
    [manager setCanvasVC:testWC];
    [manager setCompiler:[[IUCompiler alloc] init]];

    webView = testWC.webView;
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    [webView setFrameLoadDelegate:self];
    [webView setResourceLoadDelegate:self];
}

- (void)testWCReturned:(BOOL)_result {
    result = _result;
    [webViewLoadingExpectation fulfill];
}


- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    result = NO;
}

- (void)test1_load {
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPresetClass:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    page.sourceManager = manager;
    
    page.liveCSSStorage.width = @(30);
    page.liveCSSStorage.height = @(50);
    page.liveCSSStorage.bgColor = [NSColor yellowColor];
    
    [manager loadSheet:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
    }];
}


@end
