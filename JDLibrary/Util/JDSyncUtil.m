//
//  JDFTPModule.m
//  IUEditor
//
//  Created by jd on 2014. 7. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "JDSyncUtil.h"
#import "JDShellUtil.h"

@interface JDSyncUtil() <JDShellUtilPipeDelegate>
@end

@implementation JDSyncUtil {
    JDShellUtil *util;
    JDShellUtil *afterUtil;
}

- (BOOL)upload{
    if (self.protocol == JDSFTP) {
        
        NSString *src = [[NSBundle mainBundle] pathForResource:@"scp_upload" ofType:@"sh"];
        util = [[JDShellUtil alloc] init];
        NSString *command = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@", src, self.localDirectory, self.user, self.host, self.remoteDirectory, self.password];
        JDTraceLog(command, nil);
        [util execute:command delegate:self];
    }
    else {
        NSAssert(0, @"Not Yet Coded"); // not coded yet
    }
    return YES;
}

- (BOOL)terminate{
    [util.task terminate];
    return YES;
}


- (BOOL)download{
    if (self.protocol == JDSFTP) {
        NSString *src = [[NSBundle mainBundle] pathForResource:@"scp_download" ofType:@"sh"];
        util = [[JDShellUtil alloc] init];
        NSString *command = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@", src, self.localDirectory, self.user, self.host, self.remoteDirectory, self.syncDirectory, self.password];
        JDTraceLog(command, nil);
        [util execute:command delegate:self];
    }
    else {
        NSAssert(0, @"Not Yet Coded"); // not coded yet
    }
    return YES;
}

- (BOOL)isSyncing{
    return [util.task isRunning];
}


-(void)shellUtil:(JDShellUtil *)util standardErrorDataReceived:(NSData *)error{
    NSString *str = [[NSString alloc] initWithData:error encoding:NSUTF8StringEncoding];
    NSLog(str, nil);

    if (str) {
        [self.delegate syncUtilReceivedStdError:str];
    }
}

- (void)shellUtilExecutionFinished:(JDShellUtil *)_util{
    if (_util == util && _afterCommand) {
        NSString *src = [[NSBundle mainBundle] pathForResource:@"ssh" ofType:@"sh"];
        afterUtil = [[JDShellUtil alloc] init];
        NSString *command = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", src, self.user, self.password, self.host, self.afterCommand];
        NSLog(command, nil);
        [afterUtil execute:command delegate:self];
    }
    else {
        [self.delegate syncFinished:[_util.task terminationStatus]];
    }
}

- (void)shellUtil:(JDShellUtil *)util standardOutputDataReceived:(NSData *)data{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(str, nil);
    if (str) {
        [self.delegate syncUtilReceivedStdOutput:str];
    }
}
@end
