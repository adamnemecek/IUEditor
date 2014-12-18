//
//  BBDefaultProjectPreferenceVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUProject.h"
#import "IUResource.h"


@interface BBDefaultProjectPreferenceVC : NSViewController

@property (weak) IUProject *project;
@property (weak) IUResourceRootItem *resourceRootItem;


@end
