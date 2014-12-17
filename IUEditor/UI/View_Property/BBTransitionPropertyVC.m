//
//  BBTransitionPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBTransitionPropertyVC.h"

@interface BBTransitionPropertyVC ()

@property (weak) IBOutlet NSPopUpButton *animationTypePopUpButton;
@property (weak) IBOutlet NSTextField *durationTextField;
@property (weak) IBOutlet NSPopUpButton *eventTypePopUpButton;

@end

@implementation BBTransitionPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self outlet:_animationTypePopUpButton bind:NSValueBinding property:@"animation"];
    [self outlet:_durationTextField bind:NSValueBinding property:@"duration"];
    [self outlet:_eventTypePopUpButton bind:NSValueBinding property:@"eventType"];
}

@end
