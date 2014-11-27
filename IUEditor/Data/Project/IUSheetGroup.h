//
//  IUSheetGroup.h
//  IUEditor
//
//  Created by JD on 3/26/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDCoder.h"
#import "IUFileItem.h"

@class IUProject;
@class IUSheet;

@interface IUSheetGroup : IUFileItem < NSCoding, NSCopying, JDCoding>


/**
 return all children sheets
 */
- (NSArray*)childrenFileItems;

/**
 Add Item. Item can be IUSheet or IUSheet Group
 */

- (void)addFileItem:(id<IUFileItemProtocol>)fileItem;
- (void)removeFileItem:(id<IUFileItemProtocol>)fileItem;
- (void)changeIndex:(id)item toIndex:(NSUInteger)newIndex;

- (id)sheetWithHtmlID:(NSString *)identifier;

@property (nonatomic) NSUndoManager *undoManager;

@end