//
//  BBServerSettingWC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBServerSettingWC.h"

@interface BBServerSettingWC ()

@property (weak) IBOutlet NSTextField *hostTextField;
@property (weak) IBOutlet NSTextField *userNameTextField;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
@property (weak) IBOutlet NSTextField *remotePathTextField;

@end

@implementation BBServerSettingWC{
    JDSyncUtil *_syncUtil;
}

- (id)initWithWindowNibName:(NSString *)windowNibName{
    self = [super initWithWindowNibName:windowNibName];
    if(self){
        _syncUtil = [[JDSyncUtil alloc] init];
        _syncUtil.delegate = self;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

    [_hostTextField bind:NSValueBinding toObject:self withKeyPath:@"project.serverInfo.host" options:IUBindingDictNotRaisesApplicable];
    [_userNameTextField bind:NSValueBinding toObject:self withKeyPath:@"project.serverInfo.syncUser" options:IUBindingDictNotRaisesApplicable];
    [_passwordTextField bind:NSValueBinding toObject:self withKeyPath:@"project.serverInfo.syncPassword" options:IUBindingDictNotRaisesApplicable];
    [_remotePathTextField bind:NSValueBinding toObject:self withKeyPath:@"project.serverInfo.remotePath" options:IUBindingDictNotRaisesApplicable];
}
- (IBAction)clickUploadButton:(id)sender {

    if (_syncUtil.isSyncing) {
        [JDLogUtil alert:@"Upload was Progressing. Kill it and start new uploading"];
        [_syncUtil terminate];
    }
    if ([self.project.serverInfo isSyncValid]) {
        _syncUtil.user = self.project.serverInfo.syncUser;
        _syncUtil.host = self.project.serverInfo.host;
        _syncUtil.password = self.project.serverInfo.syncPassword;
        _syncUtil.protocol = 0;
        _syncUtil.remoteDirectory = self.project.serverInfo.remotePath;
        _syncUtil.localDirectory = _project.absoluteBuildPath;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IUConsoleDidStartNotification object:[NSApp mainWindow] userInfo:nil];
        [_syncUtil upload];
    }
    else {
        [JDLogUtil alert:@"server info not valid. click project and set server info."];
    }
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}
- (IBAction)clickCancelButton:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

#pragma mark - JDSyncUtil Delegate
- (void)syncUtilReceivedStdOutput:(NSString*)aMessage{
    [[NSNotificationCenter defaultCenter] postNotificationName:IUConsoleLogDidArriveNotification object:[NSApp mainWindow] userInfo:@{IULogKey: aMessage}];

}
- (void)syncUtilReceivedStdError:(NSString*)aMessage{
    [[NSNotificationCenter defaultCenter] postNotificationName:IUConsoleLogDidArriveNotification object:[NSApp mainWindow] userInfo:@{IULogKey: aMessage}];

}
- (void)syncFinished:(int)terminationStatus{
    [[NSNotificationCenter defaultCenter] postNotificationName:IUConsoleDidEndNotification object:[NSApp mainWindow] userInfo:nil];
 
}

@end
