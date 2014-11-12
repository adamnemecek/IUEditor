//
//  IUResourceGroup.h
//  IUEditor
//
//  Created by JD on 3/20/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JDCoder.h"

@protocol IUResourcePathProtocol <NSObject, JDCoding>
@optional
- (NSString*)relativePath;
- (NSString*)absolutePath;
@end

@class IUResourceFile;

@interface IUResourceGroup : NSObject <IUResourcePathProtocol, NSCoding, NSCopying, JDCoding>
@property NSString *name;
@property (weak) id <IUResourcePathProtocol> parent;

- (IUResourceFile*)addResourceFileWithContentOfPath:(NSString*)filePath;
- (BOOL)addResourceGroup:(IUResourceGroup*)group;
- (BOOL)removeResourceFile:(IUResourceFile*)file;

- (NSUndoManager *)undoManager;
- (NSArray*)childrenFiles;


@end