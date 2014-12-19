//
//  BBBottomToolBarVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBBottomToolBarVC.h"

@interface BBBottomToolBarVC ()

@property (weak) IBOutlet NSButton *hiddenFileTabButton;
@property (weak) IBOutlet NSComboBox *zoomComboBox;

@end

@implementation BBBottomToolBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_zoomComboBox addItemsWithObjectValues:@[@(200), @(180), @(150), @(120), @(100), @(80), @(60), @(40)]];
    [_zoomComboBox bind:NSValueBinding toObject:[NSUserDefaults standardUserDefaults] withKeyPath:@"zoom" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    
}

- (BOOL)control:(NSControl *)control didFailToFormatString:(NSString *)string errorDescription:(NSString *)error{
    
    if([control isEqualTo:_zoomComboBox]){
        NSString *digit = [string stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        if(digit){
            [control setStringValue:digit];
        }
    }
    
    return YES;
}

@end
