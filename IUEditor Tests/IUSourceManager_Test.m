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
#import "LMCanvasVC.h"
#import "LMCanvasView.h"

@interface IUSourceManager_Test : XCTestCase <IUProjectProtocol, IUSourceManagerDelegate>

@end

@implementation IUSourceManager_Test {
    /* delegation source */
    
    LMCanvasVC *canvasVC;
    IUCompiler *compiler;
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
    
    
    
    canvasVC = [[LMCanvasVC alloc] initWithNibName:[LMCanvasVC class].className bundle:nil];
    
    [[w contentView] addSubview:canvasVC.view];
    
    [((LMCanvasView *)canvasVC.view).webView setFrameLoadDelegate:self];

    [w makeKeyAndOrderFront:nil];
    CGFloat xPos = NSWidth([[w screen] frame])/2 - NSWidth([w frame])/2;
    CGFloat yPos = NSHeight([[w screen] frame])/2 - NSHeight([w frame])/2;
    [w setFrame:NSMakeRect(xPos, yPos, NSWidth([w frame]), NSHeight([w frame])) display:YES];

    
    /*
    _webView = [[WebView alloc] init];
    [_webView setFrame:CGRectMake(0, 0, 500, 500)];
    [_webView setFrameLoadDelegate:self];
    [[w contentView] addSubview:_webView];
    [w makeKeyAndOrderFront:nil];
    CGFloat xPos = NSWidth([[w screen] frame])/2 - NSWidth([w frame])/2;
    CGFloat yPos = NSHeight([[w screen] frame])/2 - NSHeight([w frame])/2;

    [w setFrame:NSMakeRect(xPos, yPos, NSWidth([w frame]), NSHeight([w frame])) display:YES];
     */
    
    compiler = [[IUCompiler alloc] init];
    
    manager = [[IUSourceManager alloc] init];
    [manager setCanvasVC:canvasVC];
    [manager setCompiler:compiler];
    

}

- (WebView *)webView{
    return ((LMCanvasView *)canvasVC.view).webView;
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
        DOMDocument *dom =  [[[self webView] mainFrame] DOMDocument];
        DOMHTMLElement *element = (DOMHTMLElement*)[dom documentElement];
        XCTAssertNotNil(element);
        
        DOMElement *pageElement = [dom getElementById:page.htmlID];
        XCTAssertNotNil(pageElement);
    }];
}

- (void)test2_loadPageAndCheckCSS {
    webViewLoadingExpectation = [self expectationWithDescription:@"test1"];
    
    IUPage *page = [[IUPage alloc] initWithProject:self options:nil];
    [page.liveCSSStorage setX:@(50)];
    [manager loadSheet:page];
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        DOMDocument *dom =  [[[self webView] mainFrame] DOMDocument];
        DOMElement *pageElement = [dom getElementById:page.htmlID];
        XCTAssertTrue([pageElement.style.cssText containsString:@"left: 50px"]);
    }];
}

- (void)test3_frame{
    
    webViewLoadingExpectation = [self expectationWithDescription:@"test1"];

    
    IUPage *page = [[IUPage alloc] initWithProject:self options:nil];
//    [page.cssD.liveStorage setX:@(50)];
    [page setSourceManager:manager];
    [page setCanvasVC:canvasVC];
    
    [manager loadSheet:page];

    IUBox *section = ((IUBox*)page.pageContent.children[0]);
    IUBox *box = section.children[0];
    
    box.text = @"hihi";
    
    [manager setNeedsUpdateHTML:box];
    
    /*
    [section setSourceManager:manager];
    
    IUBox *parent = [[IUBox alloc] initWithProject:page.project options:nil];
    [section addIU:parent error:nil];
//    [section updateHTML];
    [parent setSourceManager:manager];
    
    [parent.cssManager.liveStorage setX:@(0)];
    [parent.cssManager.liveStorage setY:@(0)];
    [parent.cssManager.liveStorage setWidth:@(100)];
    [parent.cssManager.liveStorage setHeight:@(100)];
    
    IUBox *child = [[IUBox alloc] initWithProject:page.project options:nil];
    [parent addIU:child error:nil];
//    [parent updateHTML];

    [child setSourceManager:manager];

    
    [child.cssManager.liveStorage setX:@(0)];
    [child.cssManager.liveStorage setY:@(0)];
    [child.cssManager.liveStorage setWidth:@(50)];
    [child.cssManager.liveStorage setHeight:@(50)];
    
    [child updateCSS];
    
    [manager loadSheet:page];
    
    [child.cssManager.liveStorage setWidthUnitAndChangeWidth:@(IUFrameUnitPercent)];
    
    [manager loadSheet:page];

    [child updateCSS];
    
    XCTAssert([child.cssManager.liveStorage.xUnit isEqualToNumber:@(IUFrameUnitPercent)]);

    [manager loadSheet:page];

     */
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        DOMDocument *dom =  [[[self webView] mainFrame] DOMDocument];
        DOMElement *pageElement = [dom getElementById:page.htmlID];
        XCTAssertTrue([pageElement.style.cssText containsString:@"left: 50px"]);
       
        DOMElement *boxElement = [dom getElementById:box.htmlID];
        XCTAssertTrue([pageElement.innerText containsString:@"hihi"]);
        
        /*
        DOMElement *childElement = [dom getElementById:child.htmlID];
        NSLog(@"css : %@", childElement.style.cssText);
        XCTAssertTrue([childElement.style.cssText containsString:@"%"]);
         */
        
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
- (IUCompiler *)compiler{
    return compiler;
}
@end
