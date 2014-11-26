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
#import "IUBoxes.h"
#import "IUText.h"


@interface IUSourceManager_UITest : XCTestCase <IUTestWCDelegate, IUProjectProtocol>

@end

static     IUTestWC *testWC;

@implementation IUSourceManager_UITest {
    WebView *webView;
    BOOL result;
    XCTestExpectation *webViewLoadingExpectation;
    XCTestExpectation *passBtnExpectation;
    IUSourceManager *manager;
}

- (IUSourceManager *)sourceManager{
    return manager;
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
    [webView setFrameLoadDelegate:self];
    [webView setResourceLoadDelegate:self];
}


- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
    [webViewLoadingExpectation fulfill];
}


- (void)testWCReturned:(BOOL)_result {
    result = _result;
    [passBtnExpectation fulfill];
}


- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    result = NO;
}

- (void)test1_load {
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 1;
    testWC.testModule = @"Showing 'Header Area'";
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];

    
    [manager loadSheet:page];
    
    
    //wait for web view's load
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        page.liveStyleStorage.bgColor = [NSColor yellowColor];
        [page updateCSS];

    }];
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");

    }];
}

- (void)test2_child{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];

    testWC.testNumber = 2;
    testWC.testModule = @"add child";
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadSheet:page];
    
    
    //wait for web view's load
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        IUSection *section = [[IUSection alloc] initWithPreset];
        section.text = @"test2";
        [page.pageContent addIU:section error:nil];
        [manager setNeedsUpdateHTML:page.pageContent];
        
        IUBox *parent = [[IUBox alloc] initWithPreset];
        [section addIU:parent error:nil];
        [manager setNeedsUpdateHTML:section];
        
    }];
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}

- (void)test3_frame{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 3;
    testWC.testModule = @"frame";
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    
    [manager loadSheet:page];
    
    
    //wait for web view's load
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        IUSection *section = [[IUSection alloc] initWithPreset];
        [page.pageContent addIU:section error:nil];
        [manager setNeedsUpdateHTML:page.pageContent];
        
        IUBox *parent = [[IUBox alloc] initWithPreset];
        [section addIU:parent error:nil];
        [manager setNeedsUpdateHTML:section];
        
        [parent.livePositionStorage setX:@(0)];
        [parent.livePositionStorage setY:@(0)];
        [parent.liveStyleStorage setWidth:@(100)];
        [parent.liveStyleStorage setHeight:@(100)];
        [manager setNeedsUpdateCSS:parent];
        
        IUBox *child = [[IUBox alloc] initWithPreset];
        [parent addIU:child error:nil];
        [manager setNeedsUpdateHTML:parent];
        
        child.text = @"hihi";
        [manager setNeedsUpdateHTML:child];
        
        
        //end of child success
        ////////////////////////
        //test frame css
        
        
        [child.livePositionStorage setX:@(0)];
        [child.livePositionStorage setY:@(0)];
        [child.liveStyleStorage setWidth:@(50)];
        [child.liveStyleStorage setHeight:@(50)];
        
        
        [manager setNeedsUpdateCSS:child];
        
        
    }];
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}

- (void)test4_iutext{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 4;
    testWC.testModule = @"text test";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadSheet:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        IUText *textIU = [[IUText alloc] initWithPreset];
        [section addIU:textIU error:nil];
        [manager setNeedsUpdateHTML:section];
        
        textIU.currentPropertyStorage.innerHTML = @"text<b>text</b>";
        [manager setNeedsUpdateHTML:textIU];
        
    }];
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
    

}

@end
