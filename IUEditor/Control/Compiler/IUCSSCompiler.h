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

@interface IUCSSStorageCode : NSObject
- (IUTarget)target;
- (NSInteger)viewPort;
- (NSArray *)allIdentifiers;
@end


@interface IUCSSCompiler : NSObject

/* storage mode */
- (IUCSSCode*)cssCodeForIU:(IUBox*)iu;
- (IUCSSCode*)cssCodeForIU:(IUBox*)iu target:(IUTarget)target viewPort:(int)viewPort;

@property IUCompiler *compiler;

@end


/**
 Generator category for subclassing
 */
