//
//  LMServerWC.h
//  IUEditor
//
//  Created by jd on 2014. 7. 28..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IUProject.h"

#import "JDSyncUtil.h"
#import "JDShellUtil.h"


@interface LMServerWC : NSWindowController <JDShellUtilPipeDelegate, JDSyncUtilDeleagate>

@property (weak) id notificationSender;

- (void)setProject:(IUProject *)project;
- (IUProject *)project;
- (IUServerInfo*)serverInfo;

- (IBAction)upload:(id)sender;
- (IBAction)serverRestart:(id)sender;

@end
