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

@interface IUSheetGroup : IUFileItem <NSCopying, JDCoding>


/**
 return children
 */
- (NSArray*)childrenFileItems;
/**
 @return all children file items including group file
 */
- (NSArray*)allChildrenFileItems;
/**
@return all children sheet file items
 */
- (NSArray *)allLeafChildrenFileItems;

/**
 Add Item. Item can be IUSheet or IUSheet Group
 */

- (void)addFileItem:(id<IUFileItemProtocol>)fileItem;
- (void)removeFileItem:(id<IUFileItemProtocol>)fileItem;
- (void)changeIndex:(id)item toIndex:(NSUInteger)newIndex;

- (id)sheetWithHtmlID:(NSString *)identifier;

@property (nonatomic) NSUndoManager *undoManager;

@end