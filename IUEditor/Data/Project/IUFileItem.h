//
//  IUFileItem.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 26..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDCoder.h"

@class IUProject;
@protocol IUFileItemProtocol <NSObject>

@optional
- (NSArray *)childrenFileItems;
- (void)addFileItem:(id <IUFileItemProtocol>) fileItem;
- (void)removeFileItem:(id <IUFileItemProtocol>) fileItem;
- (void)changeFileItem:(id <IUFileItemProtocol>)fileItem toIndex:(NSInteger)index;

- (void)setParentFileItem:(id <IUFileItemProtocol>) parentFileItem;

@required
- (IUProject *)project;
- (NSString *)name;
- (id <IUFileItemProtocol>)parentFileItem;
- (BOOL)isLeaf;
@end


/**
 IUFileItem. You should not use this class. 
 Use IUProject, IUSheet or IUSheetGroup instead
 */
@interface IUFileItem : NSObject <IUFileItemProtocol, JDCoding>
- (IUProject *)project;
@property NSString *name;
@property (weak) id <IUFileItemProtocol> parentFileItem;


@end
