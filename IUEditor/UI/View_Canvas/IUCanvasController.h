//
//  IUCanvasController.h
//  IUEditor
//
//  Created by seungmi on 2014. 10. 23..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#ifndef IUEditor_IUCanvasController_h
#define IUEditor_IUCanvasController_h

#import "IUBox.h"

//call by webview, gridview, canvasview
@protocol IUCanvasController <NSObject>
@required

@property (nonatomic) NSInteger selectedFrameWidth;
@property NSInteger maxFrameWidth;


- (IUBox *)tryIUBoxByIdentifier:(NSString *)identifier;

//General Function
//change iu frame
- (void)moveIUToTotalDiffPoint:(NSPoint)totalPoint;
- (void)extendIUToTotalDiffSize:(NSSize)totalSize;
- (void)startFrameMoveWithTransaction:(id)sender;
- (void)endFrameMoveWithTransaction:(id)sender;
- (void)setSelectIUsInRect:(NSRect)frame;

//call by webView
- (void)webViewdidFinishLoadFrame;
- (BOOL)makeNewIUWithClassName:(NSString *)className withFrame:(NSRect)frame atParentIU:(IUBox *)parentIU;
- (BOOL)makeNewIUByDragAndDrop:(IUBox *)newIU atPoint:(NSPoint)point atParentIU:(IUBox *)parentIU __deprecated;
-(void)changeIUPageHeight:(CGFloat)pageHeight;
- (CGFloat)heightOfCanvas;
- (void)updateGridFrameDictionary:(NSMutableDictionary *)gridFrameDict;
- (void)saveCurrentTextEditor;

//callby canvasview
- (NSInteger)selectedFrameWidth;
- (NSInteger)maxFrameWidth;

- (BOOL)isEnableTextEditor;
- (void)enableTextEditorForSelectedIU;
- (void)disableTextEditor;

- (void)copy:(id)sender;
- (void)paste:(id)sender;


- (BOOL)containsIdentifier:(NSString *)identifier;
- (void)deselectedIdentifier:(NSString *)identifier;
- (void)removeSelectedIUs;
- (void)addSelectedIdentifier:(NSString *)identifier;
- (void)setSelectedIdentifier:(NSString *)identifier;

-(NSUInteger)countOfSelectedIUs;


@end


#endif
