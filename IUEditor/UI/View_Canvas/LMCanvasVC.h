//
//  LMCanvasViewController.h
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 2..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "IUSheet.h"
#import "IUController.h"
#import "IUCanvasController.h"
#import "WebCanvasView.h"
#import "IUSourceManager.h"
#import "BBJSManagerProtocol.h"

@class LMCanvasView;

/**
 IUSourceManagerDelegate : call by sourceManager through IU
 BBJSManagerProtocol : call by VCs to run javascript
 IUCanvasController : call by canvasview, webview, gridview
 */
@interface LMCanvasVC : NSViewController <IUCanvasController, IUSourceManagerDelegate, BBJSManagerProtocol>


@property (nonatomic, weak) IUSheet  *sheet;
@property (nonatomic, weak) IUController  *controller;
@property (nonatomic) NSInteger selectedFrameWidth;
@property NSInteger maxFrameWidth;


//call by wc
- (void)windowDidResize:(NSNotification *)notification;

- (void)zoomIn;
- (void)zoomOut;

#if DEBUG
- (WebCanvasView *)webCanvasView;
#endif

@end
