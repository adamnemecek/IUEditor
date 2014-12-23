//
//  BBFramePropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBFramePropertyVC.h"

@interface BBFramePropertyVC ()

@property (weak) IBOutlet NSPopUpButton *positionPopUpButton;
@property (weak) IBOutlet NSPopUpButton *secondPositionPopUpButton;
@property (weak) IBOutlet NSPopUpButton *overflowPopUpButton;

@end

@implementation BBFramePropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self outlet:_positionPopUpButton bind:NSSelectedIndexBinding cascadingPositionStorageProperty:@"position"];
    [self outlet:_secondPositionPopUpButton bind:NSSelectedIndexBinding cascadingPositionStorageProperty:@"secondPosition"];
    
    [self outlet:_overflowPopUpButton bind:NSSelectedIndexBinding cascadingStyleStorageProperty:@"overflowType"];
}

@end
