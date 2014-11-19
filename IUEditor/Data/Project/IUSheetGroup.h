//
//  IUSheetGroup.h
//  IUEditor
//
//  Created by JD on 3/26/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDCoder.h"

@class IUProject;
@class IUSheet;

@interface IUSheetGroup : NSObject < NSCoding, NSCopying, JDCoding>

@property (weak) IUProject *project;
@property NSString *name;

/**
 return all children sheets
 */
- (NSArray*)childrenFiles;

/**
 Add Item. Item can be IUSheet or IUSheet Group
 */
- (void)addItem:(id)item;
- (void)removeItem:(id)item;
- (void)changeIndex:(id)item toIndex:(NSUInteger)newIndex;

- (id)sheetWithHtmlID:(NSString *)identifier;

- (NSUndoManager *)undoManager;

@end