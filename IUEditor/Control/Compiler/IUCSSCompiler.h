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


@interface IUCSSCompiler : NSObject

/* storage mode */
- (IUCSSCode*)cssCodeForIU:(IUBox*)iu;
- (IUCSSCode*)cssCodeForIU:(IUBox*)iu rule:(NSString*)rule target:(IUTarget)target viewPort:(NSInteger)viewPort option:(NSDictionary *)option;

//@property IUCompiler *compiler;

@end


/**
 Generator category for subclassing
 */
