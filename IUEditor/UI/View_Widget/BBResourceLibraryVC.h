//
//  BBResourceLibraryVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUResource.h"

@interface BBResourceLibraryVC : NSViewController <NSOutlineViewDelegate>

@property (nonatomic, weak) IUResourceRootItem *resourceRootItem;

@end
