//
//  BBServerSettingWC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUProject.h"

#import "JDSyncUtil.h"

@interface BBServerSettingWC : NSWindowController <JDSyncUtilDeleagate>

@property (weak) IUProject *project;

@end
