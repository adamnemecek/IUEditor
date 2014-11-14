//
//  IUHTMLCompiler.h
//  IUEditor
//
//  Created by seungmi on 2014. 9. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDCode.h"
#import "IUCompiler.h"
#import "IUCSSCompiler.h"

@class IUSheet;

@interface IUHTMLCompiler : NSObject

@property IUCompiler *compiler;
@property IUCSSCompiler *cssCompiler;

- (JDCode *)wholeHTMLCode:(IUBox *)iu target:(IUTarget)target withCSS:(BOOL)withCSS;

- (JDCode *)unitBoxHTMLCode:(IUBox *)iu target:(IUTarget)target withCSS:(BOOL)withCSS viewPort:(NSInteger)viewPort;


@end
