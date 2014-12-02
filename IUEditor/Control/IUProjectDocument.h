//
//  IUProjectDocument.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 6. 9..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUProject.h"
#import "IUResource.h"

#import "LMWC.h"


@interface IUProjectDocument : NSDocument

@property IUProject *project;
@property IUResourceRootItem *resource;

/* manager */
//source Manager
@property IUSourceManager *sourceManager;
//identifier Manager
@property IUIdentifierManager *identifierManager;


- (BOOL)makeNewProjectWithOption:(NSDictionary *)option URL:(NSURL *)url;
- (LMWC *)lemonWindowController;

- (BOOL)removeResourceFileItemName:(NSString *)fileItemName;
- (void)addResourceFileItemPaths:(NSArray *)fileItemPaths;


@end
