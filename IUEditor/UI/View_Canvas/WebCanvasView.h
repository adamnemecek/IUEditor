//
//  CanvasWebView.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 21..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class LMCanvasVC;

@interface WebCanvasView : WebView {
}

@property LMCanvasVC* VC;

//call javascript
- (void)runJSAfterRefreshCSS;
- (void)updateFrameDict;
- (void)reframeCenter;
- (void)resizePageContent;

//call any javascript
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;
- (id)evaluateWebScript:(NSString *)script;

#pragma mark -

- (NSSize)parentBlockElementSize:(NSString *)identifier;
- (NSString *)IUAtPoint:(NSPoint)point;
- (DOMElement *)DOMElementAtPoint:(NSPoint)point;
- (BOOL)isTextEditorAtPoint:(NSPoint)point;

@end
