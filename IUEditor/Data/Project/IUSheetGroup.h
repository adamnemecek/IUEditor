//
//  IUSheetGroup.h
//  IUEditor
//
//  Created by JD on 3/26/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUFileProtocol.h"
#import "JDCoder.h"

@class IUProject;
@class IUSheet;

@interface IUSheetGroup : NSObject < NSCoding, NSCopying, JDCoding>

@property (weak) IUProject *project;
@property NSString *name;

- (NSArray*)childrenFiles;
- (void)addSheet:(IUSheet*)sheet;
- (void)removeSheet:(IUSheet *)sheet;
- (void)changeIndex:(IUSheet *)sheet toIndex:(NSUInteger)newIndex;
- (id)sheetWithHtmlID:(NSString *)identifier;

- (NSUndoManager *)undoManager;

@end