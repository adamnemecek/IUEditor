//
//  JDShellUtil.m
//  IUEditor
//
//  Created by jd on 2014. 7. 10..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "JDShellUtil.h"

@implementation JDShellUtil{
    NSFileHandle *inputHandle;
    NSFileHandle *outputHandle;
    NSFileHandle *errorHandle;
    NSTask *_task;
    __weak id <JDShellUtilPipeDelegate> _delegate;
}

+(NSInteger) execute:(NSString*)executePath atDirectory:(NSString*)directoryPath arguments:(NSArray*)arguments stdOut:(NSString**)stdOutLog stdErr:(NSString**)stdErrLog{
    NSAssert(executePath, @"execute path is nil");
    NSTask *task;
    
    task = [[NSTask alloc] init];
    [task setLaunchPath: executePath];
    
    if ([arguments count]) {
        [task setArguments: arguments];
    }
    
    NSPipe *pipe = [NSPipe pipe];
    NSPipe *pipe2 = [NSPipe pipe];
    
    [task setStandardOutput:pipe];
    [task setStandardError:pipe2];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    NSFileHandle *file2 = [pipe2 fileHandleForReading];
    
    [task setCurrentDirectoryPath:directoryPath];
    [task launch];
    [task waitUntilExit];
    
    if (stdOutLog) {
        NSData *data = [file readDataToEndOfFile];
        *stdOutLog = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    }
    if (stdErrLog) {
        NSData *data = [file2 readDataToEndOfFile];
        *stdErrLog = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    }
    
    return [task terminationStatus];
}

+(NSInteger)execute:(NSString*)command{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    [task setArguments: @[@"-c" , command,]];
    [task launch];
    [task waitUntilExit];
    return [task terminationStatus];
}

+(NSInteger)execute:(NSString*)command stdOut:(NSString**)stdOutLog stdErr:(NSString**)stdErrLog{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    [task setArguments: @[@"-c" , command,]];
    
    NSPipe *stdOutPipe = [NSPipe pipe];
    [task setStandardOutput: stdOutPipe];
    NSFileHandle *stdOutHandle = [stdOutPipe fileHandleForReading];
    
    NSPipe *stdErrPipe = [NSPipe pipe];
    [task setStandardError: stdErrPipe];
    NSFileHandle *stdErrHandle = [stdErrPipe fileHandleForReading];
    
    [task launch];
    [task waitUntilExit];
    
    if (stdOutLog) {
        NSData *stdOutData = [stdOutHandle readDataToEndOfFile];
        *stdOutLog = [[NSString alloc] initWithData:stdOutData encoding:NSUTF8StringEncoding];
    }
    if (stdErrLog) {
        NSData *stdErrData = [stdErrHandle readDataToEndOfFile];
        *stdErrLog = [[NSString alloc] initWithData:stdErrData encoding:NSUTF8StringEncoding];
    }
    
    return [task terminationStatus];
}

- (NSTask*)task{
    return _task;
}

-(void)stop{
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
    [_task terminate];
    [_task waitUntilExit];
}


-(int)execute:(NSString*)command atDirectory:(NSString*)directory arguments:(NSArray*)arguments delegate:(id <JDShellUtilPipeDelegate>)  delegate{
    _delegate = delegate;
    _task = [[NSTask alloc] init];
    [_task setLaunchPath:command];
    [_task setCurrentDirectoryPath:directory];
    [_task setArguments:arguments];
    
    NSPipe *stdInputPipe = [NSPipe pipe];
    [_task setStandardInput: stdInputPipe];
    inputHandle = [stdInputPipe fileHandleForWriting];
    
    NSPipe *stdOutPipe = [NSPipe pipe];
    [_task setStandardOutput: stdOutPipe];
    outputHandle = [stdOutPipe fileHandleForReading];
    
    NSPipe *stdErrPipe = [NSPipe pipe];
    [_task setStandardError: stdErrPipe];
    errorHandle = [stdErrPipe fileHandleForReading];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputHandleDataReceived:) name:NSFileHandleDataAvailableNotification  object:outputHandle];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorHandleDataReceived:) name:NSFileHandleDataAvailableNotification  object:errorHandle];
    
    [outputHandle waitForDataInBackgroundAndNotify];
    [errorHandle waitForDataInBackgroundAndNotify];
    
    __weak id <JDShellUtilPipeDelegate> weakDelegate = _delegate;
    __weak typeof(self) weakSelf = self;
    
    _task.terminationHandler =  ^(NSTask *aTask){
        if ([weakDelegate respondsToSelector:@selector(shellUtilExecutionFinished:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakDelegate shellUtilExecutionFinished:weakSelf];
            });
        }
    };
    
    [_task launch];
    return [_task processIdentifier];
}


-(int)execute:(NSString*)command delegate:(id <JDShellUtilPipeDelegate>)  delegate{
    _delegate = delegate;
    _task = [[NSTask alloc] init];
    [_task setLaunchPath: @"/bin/sh"];
    [_task setArguments: @[@"-c" , command,]];
    
    
    NSPipe *stdInputPipe = [NSPipe pipe];
    [_task setStandardInput: stdInputPipe];
    inputHandle = [stdInputPipe fileHandleForWriting];
    
    NSPipe *stdOutPipe = [NSPipe pipe];
    [_task setStandardOutput: stdOutPipe];
    outputHandle = [stdOutPipe fileHandleForReading];

    NSPipe *stdErrPipe = [NSPipe pipe];
    [_task setStandardError: stdErrPipe];
    errorHandle = [stdErrPipe fileHandleForReading];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputHandleDataReceived:) name:NSFileHandleDataAvailableNotification  object:outputHandle];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorHandleDataReceived:) name:NSFileHandleDataAvailableNotification  object:errorHandle];

    
    
    [outputHandle waitForDataInBackgroundAndNotify];
    [errorHandle waitForDataInBackgroundAndNotify];
    
    __weak id <JDShellUtilPipeDelegate> weakDelegate = _delegate;
    __weak typeof(self) weakSelf = self;

    _task.terminationHandler =  ^(NSTask *aTask){
        if ([weakDelegate respondsToSelector:@selector(shellUtilExecutionFinished:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakDelegate shellUtilExecutionFinished:weakSelf];
            });
        }
    };
    
    [_task launch];
    return [_task processIdentifier];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:outputHandle];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:errorHandle];
}

- (void)outputHandleDataReceived:(NSNotification*)noti{
    NSData *d = [outputHandle availableData];
    [_delegate shellUtil:self standardOutputDataReceived:d];
    if ([self.task isRunning]) {
        [outputHandle waitForDataInBackgroundAndNotify];
    }
}

- (void)errorHandleDataReceived:(NSNotification*)noti{
    NSData *d = [errorHandle availableData];
    [_delegate shellUtil:self standardErrorDataReceived:d];
    if ([self.task isRunning]) {
        [errorHandle waitForDataInBackgroundAndNotify];
    }
}

-(void)writeDataToStandardInput:(NSData*)data{
    [outputHandle writeData:data];
}

+ (BOOL)canFindCommand:(NSString*)command{
    NSString *stdOut;
    NSString *stdErr;
    [self execute:command stdOut:&stdOut stdErr:&stdErr];
    if ([stdErr containsString:@"command not found"]) {
        return NO;
    }
    return YES;
}


@end
