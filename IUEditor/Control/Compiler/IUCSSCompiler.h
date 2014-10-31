//
//  IUCSSCompiler.h
//  IUEditor
//
//  Created by jd on 2014. 8. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUBox.h"
#import "IUCompiler.h"


@interface IUCSSCode : NSObject
- (NSDictionary*)stringTagDictionaryWithIdentifier:(int)viewport;
- (NSDictionary*)stringTagDictionaryWithIdentifierForOutputViewport:(int)viewport;
- (NSArray*)allViewports;
- (NSArray*)allIdentifiers;
@end


@interface IUCSSCompiler : NSObject
- (id)initWithResourceManager:(IUResourceManager*)resourceManager;
- (IUCSSCode*)cssCodeForIU:(IUBox*)iu;
- (IUCSSCode*)cssCodeForIU_Storage:(IUBox*)iu;
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


