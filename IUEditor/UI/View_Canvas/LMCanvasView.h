//
//  LMCanvasView.h
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 2..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SizeView.h"
#import "WebCanvasView.h"
#import "GridView.h"
#import "NSFlippedView.h"

@interface LMCanvasView : NSView

@property (nonatomic) IBOutlet id<IUCanvasController>  controller;

@property (weak) IBOutlet NSScrollView *mainScrollView;
@property  NSFlippedView *mainView;

@property WebCanvasView *webView;
@property GridView *gridView;

- (BOOL)receiveKeyEvent:(NSEvent *)theEvent;
- (void)receiveMouseEvent:(NSEvent *)theEvent;

- (void)windowDidResize:(NSNotification *)notification;
- (void)setHeightOfMainView:(CGFloat)height;
- (void)extendMainViewToFullSize;
- (void)setRulerOffsets;
- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;


- (void)startDraggingFromGridView;

@end
