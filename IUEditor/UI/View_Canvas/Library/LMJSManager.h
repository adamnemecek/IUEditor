//
//  LMJSmanager.h
//  IUEditor
//
//  Created by seungmi on 2014. 10. 24..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUSourceDelegate.h"


/**
    This class is only for inspector viewcontroller
 */
@interface LMJSManager : NSObject

- (void)setDelegate:(id<IUSourceDelegate>)aDelegate;

- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;
- (id)evaluateWebScript:(NSString *)script;


@end
