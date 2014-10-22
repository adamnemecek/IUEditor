//
//  IUTreeController.h
//  IUEditor
//
//  Created by jd on 4/3/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUBox.h"

@class IUSheet;
@class IUImport;

// NOTIFICATION : IUSelectionChangeNotification is called
//      when selection is changed

@interface IUController : NSTreeController

-(NSArray*)selectedPedigree;

-(void)setSelectedObjectsByIdentifiers:(NSArray*)identifiers;
-(void)trySetSelectedObjectsByIdentifiers:(NSArray *)identifiers;

-(NSArray*)selectedIdentifiers;
-(NSArray*)selectedIdentifiersWithImportIdentifier;

-(id)IUBoxByIdentifier:(NSString *)identifier;
/**
 brief: check import id
 */
-(id)tryIUBoxByIdentifier:(NSString *)identifier;
-(NSSet *)IUBoxesByIdentifiers:(NSArray *)identifiers;

-(IUImport*)importIUInSelectionChain;

-(void)copySelectedIUToPasteboard:(id)sender;
-(void)pasteToSelectedIU:(id)sender;

-(IUBox*)firstDeepestBox;

- (BOOL)isSelectionSameClass;
- (NSString *)selectionClassName;

@property NSUndoManager *undoManager;
@property _binding_ NSRange selectedTextRange;

@end
