//
//  IUCSSBaseCompiler.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 12. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUCSSCode.h"
#import "IUBox.h"

/** 
 @description IUCSSBaseCompiler generate css code for IUBox
 */

@interface IUCSSBaseCompiler : NSObject

- (IUCSSCode*)cssCodeForIU:(IUBox*)iu target:(IUTarget)target viewPort:(NSInteger)viewPort option:(NSDictionary *)option;

@property NSString *editorResourcePrefix;
@property NSString *outputResourcePrefix;

@end
