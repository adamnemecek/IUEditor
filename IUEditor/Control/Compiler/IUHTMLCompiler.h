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

@class IUSheet;

@interface IUHTMLCompiler : NSObject

@property IUCompiler *compiler;

- (JDCode *)wholeHTMLCode:(IUBox *)iu target:(IUTarget)target;


@end
