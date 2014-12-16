//
//  CanvasWebView.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 21..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "IUCanvasController.h"


@interface WebCanvasView : WebView {
}

@property (nonatomic, weak) id<IUCanvasController>  controller;

//call javascript
- (void)runJSAfterRefreshCSS __deprecated;
- (void)updateFrameDict __deprecated;

/* call java script to reframe iubox */
/**
 @brief set height of page content by calculating section or page content's children height
 */
- (void)resizePageContent;
/**
 @brief set center of iubox (horizontal center or vertical center) using html attr by Javascript
 */
- (void)reframeCenter;
/**
 @breif set height of sidebar by Javascript
 */
- (void)resizeSidebar;

//call any javascript
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;
- (id)evaluateWebScript:(NSString *)script;

/**
 update grid frame dictionary after move iu
 @param array of moved iu's identfier
 */
- (void)updateFrameDictionaryWithIdentifiers:(NSArray *)identifiers;

#pragma mark -
- (NSString *)IdentifierAtPoint:(NSPoint)point;
- (BOOL)isTextEditorAtPoint:(NSPoint)point;

@end
