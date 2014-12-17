//
//  BBPGFormPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBPGFormPropertyVC.h"

@interface BBPGFormPropertyVC ()

@property (weak) IBOutlet NSComboBox *targetComboBox;

@end

@implementation BBPGFormPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self outlet:_targetComboBox bind:NSValueBinding property:@"target"];
}

@end
