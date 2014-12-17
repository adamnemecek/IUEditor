//
//  BBWebVideoPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBWebVideoPropertyVC.h"

@interface BBWebVideoPropertyVC ()
@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSButton *loopButton;
@property (weak) IBOutlet NSMatrix *playTypeMatrix;

@end

@implementation BBWebVideoPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self outlet:_urlTextField bind:NSValueBinding property:@"movieLink"];
    [self outlet:_loopButton bind:NSValueBinding property:@"enableLoop"];
    [self outlet:_playTypeMatrix bind:NSSelectedIndexBinding property:@"playType"];
}

@end
