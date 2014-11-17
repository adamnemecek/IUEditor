//
//  LMWC.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUSheetController.h"
#import "IUSheetGroup.h"
#import "WebCanvasView.h"
#import "IUController.h"
#import "LMFileNaviVC.h"
#import "IUSourceManager.h"


@class LMWindow;

@interface LMWC : NSWindowController <NSWindowDelegate, LMFileNaviDelegate>

@property (nonatomic, weak) _binding_ IUSheet *selectedNode;
@property (nonatomic, weak) _binding_ IUController   *IUController;
@property (nonatomic, weak) _binding_ IUSheetController   *documentController;
@property _binding_ NSRange selectedTextRange;

@property (nonatomic) IUBox *pastedNewIU;

//source Manager
@property IUSourceManager *sourceManager;



/** current sheet for notification 
 */
- (IUSheet *)currentSheet;
- (void)prepareDealloc;

- (void)selectFirstDocument;
- (IBAction)reloadCurrentDocument:(id)sender;
- (NSString *)projectName;
- (void)reloadNavigation;

- (void)setLeftInspectorState:(NSInteger)state;
- (void)setRightInspectorState:(NSInteger)state;
- (void)setLogViewState:(NSInteger)state;

-(void)setProgressBarValue:(CGFloat)value;
-(void)stopProgressBar:(id)sender;


@end