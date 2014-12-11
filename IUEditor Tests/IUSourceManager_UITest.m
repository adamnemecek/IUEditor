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
    manager.viewPort = IUDefaultViewPort;
    manager.canvasViewWidth = 960;
    
    [manager setCanvasVC:testWC];
    [manager setCompiler:[[IUCompiler alloc] init]];

    webView = testWC.webCanvasView;
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

    
    [manager loadIU:page];
    
    
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
    
    [manager loadIU:page];
    
    
    //wait for web view's load
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        IUSection *section = [[IUSection alloc] initWithPreset];
//        section.text = @"test2";
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
    
    
    [manager loadIU:page];
    
    
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
        
//        child.text = @"hihi";
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
    
    [manager loadIU:page];
    
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

- (void)test5_iuimage{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 5;
    testWC.testModule = @"image";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        IUImage *iu = [[IUImage alloc] initWithPreset];
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        iu.imagePath = @"http://www.joomlaworks.net/images/demos/galleries/abstract/7.jpg";
        [manager setNeedsUpdateHTML:iu];
        
    }];
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
    
}

- (void)test6_iuhtml{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 6;
    testWC.testModule = @"html - youtube embed code";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        IUHTML *iu = [[IUHTML alloc] initWithPreset];
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        iu.innerHTML = @"<iframe width=\"560\" height=\"315\" src=\"http://www.youtube.com/embed/e-ORhEE9VVg\" frameborder=\"0\" allowfullscreen></iframe>";
        [manager setNeedsUpdateHTML:iu];
        
    }];
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
    
}

- (void)test7_iumovie{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 7;
    testWC.testModule = @"iumove";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        IUMovie *iu = [[IUMovie alloc] initWithPreset];
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        iu.currentStyleStorage.width = @(300);
        iu.currentStyleStorage.height = @(265);
        
        iu.videoPath = @"http://www.w3schools.com/html/mov_bbb.mp4";
        iu.posterPath = @"http://peach.blender.org/wp-content/uploads/article5-300x265.jpg";
        [manager setNeedsUpdateHTML:iu];
        
    }];
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}

- (void)test8_iuCarousel{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 8;
    testWC.testModule = @"IUCarousel";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        IUCarousel *iu = [[IUCarousel alloc] initWithPreset];
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        iu.selectColor = [NSColor redColor];
        iu.deselectColor = [NSColor blueColor];
        iu.controlType = IUCarouselControlBottom;
        
        
        [manager setNeedsUpdateHTML:iu];
        [manager setNeedsUpdateCSS:iu];
        
    }];
    
    
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}

- (void)test9_iuCollection{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 8;
    testWC.testModule = @"IUCollection";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        IUClass *test = [[IUClass alloc] initWithPreset:IUClassPresetTypeNone];
        test.defaultStyleStorage.bgColor = [NSColor yellowColor];
        test.defaultStyleStorage.width = @(200);
        test.defaultStyleStorage.height = @(300);
        
        IUBox *child = [[IUBox alloc] initWithPreset];
        child.defaultStyleStorage.bgColor = [NSColor greenColor];
        child.defaultStyleStorage.width = @(100);
        child.defaultStyleStorage.height = @(100);
        
        [test addIU:child error:nil];
        
        IUCollection *iu = [[IUCollection alloc] initWithPreset];
        [section addIU:iu error:nil];
        iu.defaultStyleStorage.bgColor = [NSColor redColor];
        iu.defaultStyleStorage.width = @(500);
        iu.defaultStyleStorage.height = @(600);
        iu.defaultItemCount = 2;
        [manager setNeedsUpdateHTML:section];
        
        iu.prototypeClass = test;
        
        [manager setNeedsUpdateHTML:iu];
        
    }];
    
    
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}

- (void)test10_facebook{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 10;
    testWC.testModule = @"IUFBLike";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        IUFBLike *iu = [[IUFBLike alloc] initWithPreset];
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        iu.likePage = @"http://www.naver.com";
        iu.showFriendsFace = YES;
        iu.colorscheme = IUFBLikeColorDark;
        
        [manager setNeedsUpdateHTML:iu];
        [manager setNeedsUpdateCSS:iu];
        
    }];
    
    
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}

- (void)test11_googlemap{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 11;
    testWC.testModule = @"googlemap";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        IUGoogleMap *iu = [[IUGoogleMap alloc] initWithPreset];
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        [manager setNeedsUpdateHTML:iu];
        [manager setNeedsUpdateCSS:iu];
        
    }];
    
    
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}

- (void)test12_menubar{
    /* FIXME : mobile */
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 10;
    testWC.testModule = @"menubar";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        IUMenuBar *iu = [[IUMenuBar alloc] initWithPreset];
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        manager.viewPort = 320;
        iu.mobileTitle = @"test12";
        
        [manager setNeedsUpdateHTML:iu];
        [manager setNeedsUpdateCSS:iu];
        
    }];
    
    
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}

- (void)test13_transition{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 13;
    testWC.testModule = @"IUTransition";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        IUTransition *iu = [[IUTransition alloc] initWithPreset];
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        iu.currentStyleStorage.width = @(200);
        iu.currentStyleStorage.height = @(300);
        iu.duration = 3;
        
        XCTAssertEqual(iu.children.count, 2);
        
        [manager setNeedsUpdateHTML:iu];
        [manager setNeedsUpdateCSS:iu];
        
    }];
    
    
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}


- (void)test14_IUTweetButton{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 14;
    testWC.testModule = @"IUTweetButton";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        IUTweetButton *iu = [[IUTweetButton alloc] initWithPreset];
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        iu.tweetText = @"hello";
        iu.countType = IUTweetButtonCountTypeHorizontal;
        iu.countType = IUTweetButtonSizeTypeLarge;
        
        
        [manager setNeedsUpdateHTML:iu];
        [manager setNeedsUpdateCSS:iu];
        
    }];
    
    
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}

- (void)test15_IUWebMovie{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 15;
    testWC.testModule = @"IUWebMovie";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        IUWebMovie *iu = [[IUWebMovie alloc] initWithPreset];
        iu.defaultPositionStorage.position = @(IUPositionTypeRelative);
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        iu.movieLink = @"http://youtu.be/APMPi9ssKUg";
        
        [manager setNeedsUpdateHTML:iu];
        [manager setNeedsUpdateCSS:iu];
        
        IUWebMovie *iu2 = [[IUWebMovie alloc] initWithPreset];
        iu2.defaultPositionStorage.position = @(IUPositionTypeRelative);
        [section addIU:iu2 error:nil];
        [manager setNeedsUpdateHTML:section];
        [iu2 setIsConnectedWithEditor];
        iu2.sourceManager = manager;
        
        iu2.movieLink = @"http://vimeo.com/channels/staffpicks/112483572";
        
        [manager setNeedsUpdateHTML:iu2];
        [manager setNeedsUpdateCSS:iu2];
        
    }];
    
    
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}
- (void)test16_PGTextView{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 16;
    testWC.testModule = @"PGTextView";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        PGTextView *iu = [[PGTextView alloc] initWithPreset];
        iu.defaultPositionStorage.position = @(IUPositionTypeRelative);
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        iu.placeholder = @"placeholder";
        iu.inputValue = @"hihihi";
        
        [manager setNeedsUpdateHTML:iu];
        [manager setNeedsUpdateCSS:iu];
        
    }];
    
    
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}

- (void)test17_PGTextField{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 17;
    testWC.testModule = @"PGTextField";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        PGTextField *iu = [[PGTextField alloc] initWithPreset];
        iu.defaultPositionStorage.position = @(IUPositionTypeRelative);
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        iu.placeholder = @"placeholder";
        iu.inputValue = @"hihihi";
        iu.type = IUTextFieldTypePassword;
        
        [manager setNeedsUpdateHTML:iu];
        [manager setNeedsUpdateCSS:iu];
        
    }];
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}

- (void)test18_PGSubmitButton{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 18;
    testWC.testModule = @"PGSubmitButton";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        PGSubmitButton *iu = [[PGSubmitButton alloc] initWithPreset];
        iu.defaultPositionStorage.position = @(IUPositionTypeRelative);
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        iu.label = @"testButton";
        
        [manager setNeedsUpdateHTML:iu];
        [manager setNeedsUpdateCSS:iu];
        
    }];
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}


- (void)test19_PGPageLinkSet{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 19;
    testWC.testModule = @"PGPageLinkSet";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        PGPageLinkSet *iu = [[PGPageLinkSet alloc] initWithPreset];
        iu.defaultPositionStorage.position = @(IUPositionTypeRelative);
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        iu.buttonMargin = 3;
        iu.selectedButtonBGColor = [NSColor greenColor];
        iu.defaultButtonBGColor = [NSColor blueColor];
        
        [manager setNeedsUpdateHTML:iu];
        [manager setNeedsUpdateCSS:iu];
        
    }];
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}

- (void)test20_PGForm{
    webViewLoadingExpectation = [self expectationWithDescription:@"load"];
    
    testWC.testNumber = 20;
    testWC.testModule = @"PGForm";
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadIU:page];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        [section setSourceManager:manager];
        
        PGForm *iu = [[PGForm alloc] initWithPreset];
        iu.defaultPositionStorage.position = @(IUPositionTypeRelative);
        [section addIU:iu error:nil];
        [manager setNeedsUpdateHTML:section];
        
        iu.target = @"test";
        
        [manager setNeedsUpdateHTML:iu];
        [manager setNeedsUpdateCSS:iu];
        
    }];
    
    //wait for pass btn action
    passBtnExpectation = [self expectationWithDescription:@"passBtn"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssert(result, @"Pass");
        
    }];
}



@end
