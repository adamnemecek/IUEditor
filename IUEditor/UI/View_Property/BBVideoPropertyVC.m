//
//  BBVideoPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBVideoPropertyVC.h"

@interface BBVideoPropertyVC ()

@property (weak) IBOutlet NSComboBox *videoComboBox;
@property (weak) IBOutlet NSTextField *altTextTextField;
@property (weak) IBOutlet NSButton *controlButton;
@property (weak) IBOutlet NSButton *coverButton;
@property (weak) IBOutlet NSButton *loopButton;
@property (weak) IBOutlet NSButton *muteButton;
@property (weak) IBOutlet NSButton *autoplayButton;

@end

@implementation BBVideoPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self outlet:_videoComboBox bind:NSValueBinding property:@"videoPath"];
    [self outlet:_altTextTextField bind:NSValueBinding property:@"altText"];
    [self outlet:_controlButton bind:NSValueBinding property:@"enableControl"];
    [self outlet:_coverButton bind:NSValueBinding property:@"cover"];
    [self outlet:_loopButton bind:NSValueBinding property:@"enableLoop"];
    [self outlet:_muteButton bind:NSValueBinding property:@"enableMute"];
    [self outlet:_autoplayButton bind:NSValueBinding property:@"enableAutoplay"];
}

@end
