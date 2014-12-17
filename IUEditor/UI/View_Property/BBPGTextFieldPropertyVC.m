//
//  BBPGTextFieldPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBPGTextFieldPropertyVC.h"

@interface BBPGTextFieldPropertyVC ()

@property (weak) IBOutlet NSTextField *placeholderTextField;
@property (weak) IBOutlet NSTextField *inputValueTextField;
@property (weak) IBOutlet NSMatrix *typeMatrix;

@end

@implementation BBPGTextFieldPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self outlet:_placeholderTextField bind:NSValueBinding property:@"placeholder"];
    [self outlet:_inputValueTextField bind:NSValueBinding property:@"inputValue"];
    [self outlet:_typeMatrix bind:NSSelectedIndexBinding property:@"type"];
}

@end
