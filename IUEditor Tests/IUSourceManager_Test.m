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
#import "IUText.h"

@interface IUSourceManager_Test : XCTestCase <IUProjectProtocol, IUSourceManagerDelegate>

@end

@implementation IUSourceManager_Test {
    /* delegation source */
    WebCanvasView *_webView;

    
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
    _webView = [[WebCanvasView alloc] init];
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

- (WebView *)webCanvasView{
    return _webView;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
    [webViewLoadingExpectation fulfill];
}

- (void)test1_loadPage {
    webViewLoadingExpectation = [self expectationWithDescription:@"test1"];
    
    IUPage *page = [[IUPage alloc] initWithPreset];
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
    
    IUPage *page = [[IUPage alloc] initWithPreset];

    ((IUStyleStorage *)page.liveStyleStorage).bgColor = [NSColor greenColor];
    [manager loadSheet:page];
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        DOMDocument *dom =  [[[self webCanvasView] mainFrame] DOMDocument];
        DOMElement *pageElement = [dom getElementById:page.htmlID];
        XCTAssertTrue([pageElement.style.cssText containsString:@"background-color"]);
    }];
}

- (void)test4_cssSourceManager{
    webViewLoadingExpectation = [self expectationWithDescription:@"test4"];
    IUPage *page = [[IUPage alloc] initWithPreset];
    [page.livePositionStorage setX:@(50)];
    
    [manager loadSheet:page];
    
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        IUBox *box = section.children[0];
        
        [box.liveStyleStorage setWidth:@(100)];
        
        [manager setNeedsUpdateCSS:box];
        
        DOMDocument *dom =  [[[self webCanvasView] mainFrame] DOMDocument];
        DOMHTMLElement *boxElement = (DOMHTMLElement *)[dom getElementById:box.htmlID];
        NSLog(@"%@", boxElement.style.cssText);
        XCTAssertTrue([boxElement.style.cssText containsString:@"100px"]);
    }];
    
}

- (void)test5_cssHover{
    webViewLoadingExpectation = [self expectationWithDescription:@"test5"];
    IUPage *page = [[IUPage alloc] initWithPreset];
    
    [manager loadSheet:page];
    
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        
        IUBox *section = ((IUBox*)page.pageContent.children[0]);
        IUBox *box = section.children[0];
        
        ((IUStyleStorage *)box.hoverStyleManager.liveStorage).bgColor = [NSColor yellowColor];
        
        [manager setNeedsUpdateCSS:box];
        
        DOMDocument *dom =  [[[self webCanvasView] mainFrame] DOMDocument];
        DOMHTMLStyleElement *styleElement = (DOMHTMLStyleElement *)[dom getElementById:@"default"];
        NSLog(@"%@", styleElement.innerHTML);
        XCTAssertTrue([styleElement.innerHTML containsString:@"background-color"]);
    }];
    
}



- (void)test7_loadPageAndHeader {
    webViewLoadingExpectation = [self expectationWithDescription:@"test3"];
    
    IUClass *class = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:class];
    XCTAssertNotNil(header.htmlID);
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    
    [manager loadSheet:page];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        DOMDocument *dom =  [[_webView mainFrame] DOMDocument];
        DOMElement *pageElement = [dom getElementById:header.htmlID];
        XCTAssertNotNil(pageElement);
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
    return @[@"iueditor.js", @"iuframe.js", @"iugooglemap_theme.js"];
}

- (NSArray *)defaultCopyJSArray{
    return nil;
}
- (NSArray *)defaultOutputJSArray{
    return [self defaultCopyJSArray];
}
- (NSArray *)defaultOutputIEJSArray{
    return nil;
}

@end
