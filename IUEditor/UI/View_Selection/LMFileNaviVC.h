//
//  LMFileNaviVC.h
//  IUEditor
//
//  Created by JD on 3/24/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUProject.h"
#import "JDOutlineView.h"
#import "IUSheetController.h"
#import "IUIdentifierManager.h"

@protocol LMFileNaviDelegate
@end

@interface LMFileNaviVC : NSViewController <NSOutlineViewDelegate, NSMenuDelegate, NSControlTextEditingDelegate>

@property (nonatomic, readonly, weak) id  selection;
@property (strong, nonatomic) IBOutlet _binding_ IUSheetController *documentController;
@property (nonatomic, weak) IUProject *project;
@property (weak) id <LMFileNaviDelegate> delegate;

- (void)selectFirstDocument;
- (void)reloadNavigation;

@property IUIdentifierManager *identifierManager;

@end
