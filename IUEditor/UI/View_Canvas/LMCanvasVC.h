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
#import "IUResourceManager.h"

@class LMCanvasView;
@interface LMCanvasVC : NSViewController <IUSourceDelegate>

- (void)prepareDealloc;

@property (nonatomic) _binding_ IUSheet  *sheet;
@property (nonatomic) _binding_ NSString    *documentBasePath;
@property (nonatomic, weak) IUResourceManager  *resourceManager;

@property (nonatomic) IUController  *controller;

@property NSInteger selectedFrameWidth;
@property NSInteger maxFrameWidth;

- (void)addFrame:(NSInteger)frameSize;


- (void)windowDidResize:(NSNotification *)notification;

#pragma mark -
#pragma mark call by webView
- (void)didFinishLoadFrame;
- (void)removeSelectedIUs;
- (void)insertImage:(NSString *)name atIU:(NSString *)identifier;
- (void)changeIUPageHeight:(CGFloat)pageHeight minHeight:(CGFloat)minHeight;

//select IUs
- (BOOL)containsIU:(NSString *)IUID;
- (NSUInteger)countOfSelectedIUs;
- (void)deselectedAllIUs;
- (void)addSelectedIU:(NSString *)IU;
- (void)removeSelectedIU:(NSString *)IU;
- (void)setSelectedIU:(NSString *)IU;
- (void)selectIUInRect:(NSRect)frame;

- (void)saveCurrentTextEditorForWidth:(NSInteger)width;
- (void)disableTextEditor;
- (void)enableTextEditorForSelectedIU;
- (BOOL)isEnableTextEditor;

#pragma mark -
#pragma mark be set by IU
//load page
- (void)setSheet:(IUSheet *)sheet;
- (void)reloadSheet;


#pragma mark -
#pragma mark set IU
- (void)updateGridFrameDictionary:(NSMutableDictionary *)gridFrameDict;

- (void)moveIUToDiffPoint:(NSPoint)point totalDiffPoint:(NSPoint)totalPoint;
- (void)extendIUToTotalDiffSize:(NSSize)totalSize;
- (BOOL)checkExtendSelectedIU:(NSSize)size;
- (void)startFrameMoveWithUndoManager:(id)sender;
- (void)endFrameMoveWithUndoManager:(id)sender;


- (BOOL)makeNewIUByDragAndDrop:(IUBox *)newIU atPoint:(NSPoint)point atIU:(NSString *)parentIUID;
- (NSString *)currentHTML;

- (void)copy:(id)sender;
- (void)paste:(id)sender;

#if DEBUG
- (void)applyHtmlString:(NSString *)html;
- (void)reloadOriginalDocument;

#endif

- (void)performRightClick:(NSString*)IUID withEvent:(NSEvent*)event;
@end
