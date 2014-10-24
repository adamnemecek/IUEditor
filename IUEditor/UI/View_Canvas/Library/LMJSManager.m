//
//  LMJSmanager.m
//  IUEditor
//
//  Created by seungmi on 2014. 10. 24..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMJSManager.h"

@interface LMJSManager()

@property (nonatomic) id<IUSourceDelegate> delegate;

@end

@implementation LMJSManager

- (void)setDelegate:(id<IUSourceDelegate>)aDelegate{
    _delegate = aDelegate;
}


- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args{
    return [self.delegate callWebScriptMethod:function withArguments:args];
}
- (id)evaluateWebScript:(NSString *)script{
    return [self.delegate evaluateWebScript:script];
}


@end
