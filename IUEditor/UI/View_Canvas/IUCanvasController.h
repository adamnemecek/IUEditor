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

- (IUBox *)tryIUBoxByIdentifier:(NSString *)identifier;

//General Function
//change iu frame
- (void)moveIUToDiffPoint:(NSPoint)point totalDiffPoint:(NSPoint)totalPoint;
- (void)extendIUToTotalDiffSize:(NSSize)totalSize;
- (void)startFrameMoveWithUndoManager:(id)sender;
- (void)endFrameMoveWithUndoManager:(id)sender;
- (void)selectIUInRect:(NSRect)frame;

//call by webView
- (void)webViewdidFinishLoadFrame;
- (BOOL)makeNewIUByDragAndDrop:(IUBox *)newIU atPoint:(NSPoint)point atParentIU:(IUBox *)parentIU;
-(void)changeIUPageHeight:(CGFloat)pageHeight minHeight:(CGFloat)minHeight;
- (CGFloat)heightOfCanvas;
- (void)updateGridFrameDictionary:(NSMutableDictionary *)gridFrameDict;

//callby canvasview
- (NSInteger)selectedFrameWidth;
- (NSInteger)maxFrameWidth;

- (BOOL)isEnableTextEditor;
- (void)enableTextEditorForSelectedIU;
- (void)disableTextEditor;

- (void)copy:(id)sender;
- (void)paste:(id)sender;


- (BOOL)containsIU:(IUBox *)iu;
- (void)deselectedIU:(IUBox *)iu;
- (void)removeSelectedIUs;
- (void)addSelectedIU:(IUBox *)IU;
- (void)setSelectedIU:(IUBox *)iu;

-(NSUInteger)countOfSelectedIUs;

//call  by sizeview
- (void)disableUpdateCSS:(id)sender;
- (void)enableUpdateCSS:(id)sender;
- (BOOL)isUpdateCSSEnabled;


@end


#endif
