//
//  BBPGTextAreaPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBPGTextAreaPropertyVC.h"

@interface BBPGTextAreaPropertyVC ()

@property (weak) IBOutlet NSTextField *placeholderTextField;
@property (weak) IBOutlet NSTextField *inputValueTextField;

@end

@implementation BBPGTextAreaPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self outlet:_placeholderTextField bind:NSValueBinding property:@"placeholder"];
    [self outlet:_inputValueTextField bind:NSValueBinding property:@"inputValue"];
}

@end
