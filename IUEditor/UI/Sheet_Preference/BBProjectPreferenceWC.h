//
//  BBProjectPreferenceWC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUProject.h"
#import "IUResource.h"

@interface BBProjectPreferenceWC : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IUProject *project;
@property (nonatomic, weak) IUResourceRootItem *resourceRootItem;

@end
