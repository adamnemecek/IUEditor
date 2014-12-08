//
//  IUProjectDocument.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 6. 9..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUDocumentProtocol.h"

#import "IUProject.h"
#import "IUResource.h"

#import "BBWC.h"

@interface IUProjectDocument : NSDocument <IUDocumentProtocol>

@property IUProject *project;

/* IUDocumentProtocol */
@property IUResourceRootItem *resourceRootItem;
@property IUSourceManager *sourceManager;
@property IUIdentifierManager *identifierManager;


- (BOOL)makeNewProjectWithOption:(NSDictionary *)option URL:(NSURL *)url;
- (BBWC *)butterflyWindowController;

- (BOOL)removeResourceFileItemName:(NSString *)fileItemName;
- (void)addResourceFileItemPaths:(NSArray *)fileItemPaths;


@end
