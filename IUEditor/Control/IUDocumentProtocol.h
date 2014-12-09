//
//  IUDocumentProtocol.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#ifndef IUEditor_IUDocumentProtocol_h
#define IUEditor_IUDocumentProtocol_h

#import "IUSourceManager.h"
#import "IUResource.h"

@protocol IUDocumentProtocol <NSObject>
@required
//source Manager
@property IUSourceManager *sourceManager;
//identifier Manager
@property IUIdentifierManager *identifierManager;
//resource rootItem
@property IUResourceRootItem *resourceRootItem;

- (BOOL)removeResourceFileItem:(IUResourceFileItem *)fileItem;
- (void)addResourceFileItemPaths:(NSArray *)fileItemPaths;


@end

#endif
