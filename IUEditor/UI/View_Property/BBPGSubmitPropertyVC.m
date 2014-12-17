//
//  BBPGSubmitPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBPGSubmitPropertyVC.h"

@interface BBPGSubmitPropertyVC ()

@property (weak) IBOutlet NSTextField *labelTextField;

@end

@implementation BBPGSubmitPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self outlet:_labelTextField bind:NSValueBinding property:@"label"];
}

@end
