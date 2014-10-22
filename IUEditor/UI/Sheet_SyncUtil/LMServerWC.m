//
//  LMServerWC.m
//  IUEditor
//
//  Created by jd on 2014. 7. 28..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMServerWC.h"

@interface LMServerWC ()

@end

@implementation LMServerWC{
    __weak IUProject *_project;
    
    JDShellUtil *restartServerShell;
    JDSyncUtil *syncUtil;
}


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        syncUtil = [[JDSyncUtil alloc] init];
        syncUtil.delegate = self;
    }
    return self;
}

- (void)setProject:(IUProject *)project{
    _project = project;
}

- (IUProject *)project{
    return _project;
}

- (IUServerInfo*)serverInfo{
    return _project.serverInfo;
}

/* do not use - db overwrite problem
- (IBAction)download:(id)sender{
    NSAssert(_notificationSender, @"Should Have Notification Sender");
    if (syncUtil.isSyncing) {
        [JDLogUtil alert:@"Syncing was Progressing. Kill it and start new downloading"];
        [syncUtil terminate];
    }
    if ([self.serverInfo isSyncValid]) {
        syncUtil.user = self.serverInfo.syncUser;
        syncUtil.host = self.serverInfo.host;
        syncUtil.password = self.serverInfo.syncPassword;
        syncUtil.protocol = 0;
        syncUtil.remoteDirectory = self.serverInfo.remotePath;
        syncUtil.localDirectory = self.serverInfo.localPath;
        syncUtil.syncDirectory = self.serverInfo.syncItem;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleStart object:_notificationSender userInfo:nil];
        syncUtil.tag = 0; //0 for download, 1 for upload
        [syncUtil download];
    }
    else {
        [JDLogUtil alert:@"server info not valid. click project and set server info."];
    }
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}
*/

- (IBAction)upload:(id)sender{
    NSAssert(_notificationSender, @"Should Have Notification Sender");
    if (syncUtil.isSyncing) {
        [JDLogUtil alert:@"Upload was Progressing. Kill it and start new uploading"];
        [syncUtil terminate];
    }
    if ([self.serverInfo isSyncValid]) {
        syncUtil.user = self.serverInfo.syncUser;
        syncUtil.host = self.serverInfo.host;
        syncUtil.password = self.serverInfo.syncPassword;
        syncUtil.protocol = 0;
        syncUtil.remoteDirectory = self.serverInfo.remotePath;
        syncUtil.localDirectory = _project.absoluteBuildPath;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleStart object:_notificationSender userInfo:nil];
        [syncUtil upload];
    }
    else {
        [JDLogUtil alert:@"server info not valid. click project and set server info."];
    }
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (IBAction)serverRestart:(id)sender{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ssh" ofType:@"sh"];
    
    if (self.serverInfo.restartPassword && self.serverInfo.host && self.serverInfo.restartCommand) {
        NSString *command = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",filePath , self.serverInfo.restartUser, self.serverInfo.restartPassword, self.serverInfo.host, self.serverInfo.restartCommand];
        
        
        restartServerShell = [[JDShellUtil alloc] init];
        [restartServerShell execute:command delegate:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleStart object:_notificationSender];
    }
    else {
        [JDLogUtil alert:@"Set Project Property First"];
    }
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (void)syncUtilReceivedStdOutput:(NSString*)aMessage{
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleLog object:_notificationSender userInfo:@{IUNotificationConsoleLogText: aMessage}];
    
}
- (void)syncUtilReceivedStdError:(NSString*)aMessage{
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleLog object:_notificationSender userInfo:@{IUNotificationConsoleLogText: aMessage}];
}

- (void)syncFinished:(int)terminationStatus{
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleEnd object:_notificationSender userInfo:nil];
    
}

- (void)shellUtil:(JDShellUtil*)util standardOutputDataReceived:(NSData*)data{
    NSString *log = [[NSString alloc] initWithData:data encoding:4];
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleLog object:_notificationSender userInfo:@{@"Log": log}];
}

- (void)shellUtil:(JDShellUtil*)util standardErrorDataReceived:(NSData*)data{
    NSString *log = [[NSString alloc] initWithData:data encoding:4];
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleLog object:_notificationSender userInfo:@{@"Log": log}];
}

- (void) shellUtilExecutionFinished:(JDShellUtil *)util{
    if (util.name) {
        NSString *log = [NSString stringWithFormat:@" ------ %@ Ended -----", util.name];
        [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleLog object:_notificationSender userInfo:@{IUNotificationConsoleLogText: log}];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleEnd object:_notificationSender];
}

- (IBAction)close:(id)sender{
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (void)cancelOperation:(id)sender{
    [self close:self];
}

@end
