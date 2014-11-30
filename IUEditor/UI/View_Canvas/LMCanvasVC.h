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

@class LMCanvasView;

/**
 IUSourceDelegate : call by IU
 IUCanvasController : call by canvasview, webview, gridview
 */
@interface LMCanvasVC : NSViewController <IUSourceDelegate, IUCanvasController>


- (void)prepareDealloc;

@property (nonatomic) _binding_ IUSheet  *sheet;
@property (nonatomic) _binding_ NSString    *documentBasePath;
@property (nonatomic, weak) IUResourceManager  *resourceManager;
@property (nonatomic) IUController  *controller;
@property (nonatomic) NSInteger selectedFrameWidth;
@property NSInteger maxFrameWidth;


//call by wc
- (void)windowDidResize:(NSNotification *)notification;
- (void)setSheet:(IUSheet *)sheet;

- (void)zoomIn;
- (void)zoomOut;


#if DEBUG
- (void)applyHtmlString:(NSString *)html;
- (void)reloadOriginalDocument;
- (IBAction)showCurrentSource:(id)sender;
#endif

@end
