//
//  LMTopToolbarVC.h
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IUSheetController.h"
#import "IUSheetGroup.h"
#import "LMFileTabItemVC.h"

typedef enum{
    LMTabDocumentTypeNone,
    LMTabDocumentTypeOpen,
    LMTabDocumentTypeHidden,
    
}LMTabDocumentType;

@interface LMTopToolbarVC : NSViewController

@property (weak)  IUSheetController *sheetController;
- (void)setSheet:(IUSheet *)sheet;

//tabItem delegate
- (void)selectTab:(IUSheet *)documentNode;
- (void)closeTab:(LMFileTabItemVC *)tabItem sender:(id)sender;

@end
