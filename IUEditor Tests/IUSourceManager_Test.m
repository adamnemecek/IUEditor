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
#import "XCTestCase+AsyncTesting.h"

@interface IUSourceManager_Test : XCTestCase <IUProjectProtocol, IUSourceManagerDelegate>

@end

@implementation IUSourceManager_Test {
    WebView *_webView;
    IUCompiler *_compiler;
    IUSourceManager *manager;
    NSWindowController *wc;
    NSWindow *w;
}

- (void)setUp {
    [super setUp];
    
//    });
    
    _webView = [[WebView alloc] init];
    [_webView setUIDelegate:self];
    [_webView setResourceLoadDelegate:self];
    [_webView setFrameLoadDelegate:self];
    
    wc = [[NSWindowController alloc] initWithWindow:[[NSWindow alloc] init]];
    [[wc.window contentView] addSubviewFullFrame:_webView];
    [wc.window makeKeyAndOrderFront:self];

    _compiler = [[IUCompiler alloc] init];
    manager = [[IUSourceManager alloc] init];
    [manager setCanvasVC:self];
    [manager setCompiler:_compiler];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
    NSLog(@"hahahah");
    
    DOMDocument *dom =  [frame DOMDocument];
    DOMHTMLElement *element = (DOMHTMLElement*)[dom documentElement];
    NSString *htmlSource = [element outerHTML];

    NSLog(htmlSource, nil);

}

- (void)test0 {
#if 0
    // Create an expectation object.
    // This test only has one, but it's possible to wait on multiple expectations.
    
    XCTestExpectation *documentOpenExpectation = [self expectationWithDescription:@"document open"];

    // Insert code here to initialize your application
    NSRect frame = NSMakeRect(0, 0, 500, 500);
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    w  = [[NSWindow alloc] initWithContentRect:frame
                                     styleMask:NSBorderlessWindowMask
                                       backing:NSBackingStoreBuffered
                                         defer:NO];
    WebView *webView = [[WebView alloc] init];
    [webView setFrame:CGRectMake(0, 0, 200, 200)];
//    [[w contentView] addSubview:webView];
    [[webView mainFrame] loadHTMLString:@"qwer" baseURL:nil];
    [w makeKeyAndOrderFront:nil];
    CGFloat xPos = NSWidth([[w screen] frame])/2 - NSWidth([w frame])/2;
    CGFloat yPos = NSHeight([[w screen] frame])/2 - NSHeight([w frame])/2;
    [w setFrame:NSMakeRect(xPos, yPos, NSWidth([w frame]), NSHeight([w frame])) display:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [NSThread sleepForTimeInterval:10];
        [documentOpenExpectation fulfill];
    });
    
    // The test will pause here, running the run loop, until the timeout is hit
    // or all expectations are fulfilled.
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        int i=0;
    }];

#endif

}


- (void)test1_loadPage {
    
    
    // Insert code here to initialize your application
    NSRect frame = NSMakeRect(0, 0, 200, 200);
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    w  = [[NSWindow alloc] initWithContentRect:frame
                                     styleMask:NSBorderlessWindowMask
                                       backing:NSBackingStoreBuffered
                                         defer:NO];
    WebView *webView = [[WebView alloc] init];
    [webView setFrame:CGRectMake(0, 0, 500, 500)];
    [[w contentView] addSubview:webView];
    [[webView mainFrame] loadHTMLString:@"qwer" baseURL:nil];
    [w makeKeyAndOrderFront:nil];
    CGFloat xPos = NSWidth([[w screen] frame])/2 - NSWidth([w frame])/2;
    CGFloat yPos = NSHeight([[w screen] frame])/2 - NSHeight([w frame])/2;
    [w setFrame:NSMakeRect(xPos, yPos, NSWidth([w frame]), NSHeight([w frame])) display:YES];

    [self waitForTimeout:10];

    
    [[_webView mainFrame] loadHTMLString:@"sdfgd" baseURL:nil];
    
    DOMDocument *dom =  [[_webView mainFrame] DOMDocument];
    DOMHTMLElement *element = (DOMHTMLElement*)[dom documentElement];
    NSString *htmlSource = [element outerHTML];

    NSLog(htmlSource, nil);
    
    
    /*
    // This is an example of a functional test case.
    IUPage *page = [[IUPage alloc] initWithProject:self options:nil];
    
    //create project
    [manager loadSheet:page];

    NSLog(manager.source);
    
    XCTAssert(manager.source, @"Pass");
     */
}

- (void)test2{
    while (1) {
    }
}
/* get DOM */

- (WebView *)webView{
    return _webView;
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

- (IUCompiler *)compiler __deprecated{
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
