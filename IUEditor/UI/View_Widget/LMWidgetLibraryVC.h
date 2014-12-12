//
//  LMWidgetLibraryVC.h
//  IUEditor
//
//  Created by JD on 3/25/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUController.h"
#import "IUIdentifierManager.h"

@class IUProject;
__attribute__((deprecated))
@interface LMWidgetLibraryVC : NSViewController

@property (nonatomic, weak) _binding_ IUController *controller;
@property (nonatomic, weak) IUProject   *project;

@end