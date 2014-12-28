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
#import "IUCompiler.h"

@interface IUCSSCompiler : NSObject

/* storage mode */
- (IUCSSCode*)cssCodeForIU:(IUBox*)iu rule:(NSString*)rule target:(IUTarget)target viewPort:(NSInteger)viewPort option:(NSDictionary *)option;

- (NSArray*)cssCodesForIUWithChildren:(IUBox*)iu rule:(NSString*)rule target:(IUTarget)target viewPort:(NSInteger)viewPort option:(NSDictionary *)option;

- (NSDictionary*)cssCodeDictionaryForIUWithChildren:(IUBox*)iu rule:(NSString*)rule target:(IUTarget)target viewPort:(NSInteger)viewPort option:(NSDictionary *)option;

- (JDCode *)outputCSSCodeForSheet:(IUSheet *)sheet rule:(NSString *)rule;


/**
compiler has common functions to compile iubox
 */
@property (nonatomic) id<IUCompilerProtocol> compiler;

@property (nonatomic) NSString *editorResourcePrefix;
@property (nonatomic) NSString *outputResourcePrefix;

@end


/**
 Generator category for subclassing
 */
