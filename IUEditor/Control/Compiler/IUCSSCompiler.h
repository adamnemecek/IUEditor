//
//  IUCSSCompiler.h
//  IUEditor
//
//  Created by jd on 2014. 8. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUBox.h"
#import "IUCSSCode.h"

@class IUCompiler;
@class IUResourceManager;

@interface IUCSSStorageCode : NSObject
- (IUTarget)target;
- (NSInteger)viewPort;
- (NSArray *)allIdentifiers;
@end


@interface IUCSSCompiler : NSObject
- (void)setResourceManager:(IUResourceManager*)resourceManager;
- (IUCSSCode*)cssCodeForIU:(IUBox*)iu;
- (IUCSSCode*)cssCodeForIU_storage:(IUBox*)iu;
@property IUCompiler *compiler;

@end


/**
 Generator category for subclassing
 */
