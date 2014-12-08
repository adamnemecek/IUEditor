//
//  BBDefaultBindingVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "BBPropertyToolBarVC.h"

#import "IUSourceManager.h"
#import "IUCompiler.h"
#import "IUProject.h"
#import "IUBoxes.h"


#import "IUTestWC.h"


@interface BBDefaultBindingVC : XCTestCase <IUTestWCDelegate, IUProjectProtocol>

@end

static     IUTestWC *testWC;


@implementation BBDefaultBindingVC{
    WebView *webView;
    BOOL result;
    XCTestExpectation *webViewLoadingExpectation;
    XCTestExpectation *passBtnExpectation;
    IUSourceManager *manager;
    IUIdentifierManager *identifierManager;
    IUController *iuController;
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
    manager.viewPort = IUDefaultViewPort;
    manager.canvasViewWidth = 960;
    
    identifierManager = [[IUIdentifierManager alloc] init];
    
    iuController = [[IUController alloc] init];
    
    [manager setCanvasVC:testWC];
    [manager setCompiler:[[IUCompiler alloc] init]];
    
    webView = testWC.webView;
    [webView setFrameLoadDelegate:self];
    [webView setResourceLoadDelegate:self];

}

- (void)tearDown {
    [super tearDown];
    result = NO;
}

- (void)testWCReturned:(BOOL)aResult {
    result = aResult;
    [passBtnExpectation fulfill];
}

- (void)test1_load {
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 1;
    testWC.testModule = @"Binding BG Color";
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    page.htmlID = [identifierManager createIdentifierWithPrefix:[IUPage className]];
    page.name = page.htmlID;
    
    for( IUBox *box in page.allChildren){
        box.htmlID = [identifierManager createIdentifierWithPrefix:[box className]];
        box.name = box.htmlID;

    }
    
    [iuController setContent:page];
    [iuController setSelectedObject:page];
    
    [manager loadSheet:page];
    
    BBPropertyToolBarVC *defaultPropertyVC = [[BBPropertyToolBarVC alloc] initWithNibName:[BBPropertyToolBarVC className] bundle:nil];
    defaultPropertyVC.controller = iuController;
    
    [testWC.testView addSubview:defaultPropertyVC.view];
    
    
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

@end
