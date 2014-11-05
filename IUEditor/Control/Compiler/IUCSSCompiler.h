//
//  IUCSSCompiler.h
//  IUEditor
//
//  Created by jd on 2014. 8. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUCompiler.h"

@class IUCompiler;
@class IUResourceManager;

@interface IUCSSCode : NSObject
- (NSDictionary*)stringTagDictionaryWithIdentifier:(int)viewport;
- (NSDictionary*)stringTagDictionaryWithIdentifierForOutputViewport:(int)viewport;
- (NSDictionary*)stringTagDictionaryWithIdentifierForTarget:(IUTarget)target viewPort:(int)viewport;


- (NSArray*)allViewports;
- (NSArray*)allIdentifiers;

- (NSDictionary*)stringTagDictionaryWithIdentifier_storage:(IUTarget)target viewPort:(int)viewPort;

@end

@interface IUCSSStorageCode : NSObject
- (IUTarget)target;
- (NSInteger)viewPort;
- (NSArray *)allIdentifiers;
@end


@interface IUCSSCompiler : NSObject
- (id)initWithResourceManager:(IUResourceManager*)resourceManager;
- (IUCSSCode*)cssCodeForIU:(IUBox*)iu;
- (IUCSSCode*)cssCodeForIU_storage:(IUBox*)iu;
@property IUCompiler *compiler;

@end


/**
 Generator category for subclassing
 */

typedef enum _IUUnit{
    IUUnitNone,
    IUUnitPixel,
    IUUnitPercent,
} IUUnit;


