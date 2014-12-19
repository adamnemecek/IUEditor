//
//  BBMediaQueryVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUProject.h"

@interface BBMediaQueryVC : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IUProject *project;

@end
