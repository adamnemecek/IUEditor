//
//  IUSourceManager_Test.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUSourceManager.h"
#import <WebKit/WebKit.h>
#import "IUProject.h"
#import "IUBox.h"
#import "IUPage.h"

@interface IUSourceManager_Test : XCTestCase <IUProjectProtocol, IUSourceManagerDelegate>

@end

@implementation IUSourceManager_Test {
    /* delegation source */
    WebView *_webView;

    
    IUSourceManager *manager;
    NSWindow *w;
    XCTestExpectation *webViewLoadingExpectation;
}

- (void)setUp {
    [super setUp];
    
    
    NSRect windowFrame = NSMakeRect(0, 0, 500, 500);
    w  = [[NSWindow alloc] initWithContentRect:windowFrame
                                     styleMask:NSClosableWindowMask
                                       backing:NSBackingStoreBuffered
                                         defer:NO];
    _webView = [[WebView alloc] init];
    [_webView setFrame:CGRectMake(0, 0, 500, 500)];
    [_webView setFrameLoadDelegate:self];
    [[w contentView] addSubview:_webView];
    [w makeKeyAndOrderFront:nil];
    CGFloat xPos = NSWidth([[w screen] frame])/2 - NSWidth([w frame])/2;
    CGFloat yPos = NSHeight([[w screen] frame])/2 - NSHeight([w frame])/2;

    [w setFrame:NSMakeRect(xPos, yPos, NSWidth([w frame]), NSHeight([w frame])) display:YES];
    
    manager = [[IUSourceManager alloc] init];
    [manager setCanvasVC:self];
    [manager setCompiler:[[IUCompiler alloc] init]];
}

- (WebView *)webView{
    return _webView;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
    [webViewLoadingExpectation fulfill];
}
/*
- (void)test0 {
    webViewLoadingExpectation = [self expectationWithDescription:@"test0"];

    //this test does not do anything: checking test enviroment
    [[_webView mainFrame] loadHTMLString:@"Start Source Manager Test" baseURL:nil];

    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {}];
}
*/

- (void)test1_loadPage {
    webViewLoadingExpectation = [self expectationWithDescription:@"test1"];
    
    IUPage *page = [[IUPage alloc] initWithProject:self options:nil];
    [manager loadSheet:page];
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        DOMDocument *dom =  [[_webView mainFrame] DOMDocument];
        DOMHTMLElement *element = (DOMHTMLElement*)[dom documentElement];
        XCTAssertNotNil(element);
        
        DOMElement *pageElement = [dom getElementById:page.htmlID];
        XCTAssertNotNil(pageElement);
    }];
}

- (void)test2_loadPageAndCheckCSS {
    webViewLoadingExpectation = [self expectationWithDescription:@"test1"];
    
    IUPage *page = [[IUPage alloc] initWithProject:self options:nil];
    [page.cssManager.liveStorage setX:@(50)];
    [manager loadSheet:page];
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        DOMDocument *dom =  [[_webView mainFrame] DOMDocument];
        DOMElement *pageElement = [dom getElementById:page.htmlID];
        XCTAssertTrue([pageElement.style.cssText containsString:@"left: 50px"]);
    }];
}




/* prepare update. for example, text editor enable/disable */
- (void)beginUpdate{
    
}
- (void)commitUpdate{
    
}

/* call javascript */
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args{
    return nil;
}


/* media query view ports */
- (NSArray *)mqSizes{
    return nil;
}

/* support manager for IUBox */
- (IUIdentifierManager*)identifierManager{
    return nil;
}
- (NSString*)IUProjectVersion{
    return nil;
}
- (IUClass *)classWithName:(NSString *)name{
    return nil;
}

- (BOOL)enableMinWidth __deprecated{
    return YES;
}

- (IUProjectType)projectType{
    return IUProjectTypeDefault;
}

- (NSString*)absoluteBuildPath{
    return nil;
}

- (NSString *)author{
    return nil;
}

- (NSString *)name{
    return nil;
}

- (NSString *)favicon{
    return nil;
}

- (NSArray *)defaultEditorJSArray{
    return nil;
}

- (NSArray *)defaultCopyJSArray{
    return nil;
}
- (NSArray *)defaultOutputJSArray{
    return nil;
}
- (NSArray *)defaultOutputIEJSArray{
    return nil;
}

@end
