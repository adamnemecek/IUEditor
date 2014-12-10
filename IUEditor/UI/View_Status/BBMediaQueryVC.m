//
//  BBMediaQueryVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBMediaQueryVC.h"

@interface BBMediaQueryVC ()

@property (weak) IBOutlet NSPopUpButton *mediaQueryPopupButton;

@end

@implementation BBMediaQueryVC{
    NSInteger _currentSelectedWidth;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [_mediaQueryPopupButton bind:NSContentBinding toObject:self withKeyPath:@"project.mqSizes" options:IUBindingDictNotRaisesApplicable];
    
}

- (NSWindowController *)currentWC{
    return [[self.view window] windowController];
}

- (IBAction)clickMediaQueryPopupButton:(id)sender {
    NSInteger selectedWidth = [[[_mediaQueryPopupButton selectedItem] representedObject] integerValue];
    [self selectMediaQueryWidth:selectedWidth];
}


- (void)selectMediaQueryWidth:(NSInteger)width{
    NSInteger maxWidth = self.project.maxViewPort;
    NSInteger largerWidth;
    if([_mediaQueryPopupButton indexOfSelectedItem] > 0){
        largerWidth = [[[_mediaQueryPopupButton itemAtIndex:[_mediaQueryPopupButton indexOfSelectedItem] -1] representedObject] integerValue];
    }
    else{
        largerWidth = maxWidth;
    }
    
    NSInteger oldSelectedWidth = _currentSelectedWidth;
    _currentSelectedWidth = width;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQSelected object:[self currentWC] userInfo:@{IUNotificationMQSize:@(width), IUNotificationMQMaxSize:@(maxWidth)}];
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQSelectedWithInfo object:[self currentWC] userInfo:@{IUNotificationMQSize:@(width), IUNotificationMQMaxSize:@(maxWidth), IUNotificationMQLargerSize:@(largerWidth), IUNotificationMQOldSize:@(oldSelectedWidth)} ];
    
}


- (IBAction)clickMediaQuerySettingButton:(id)sender {
    
}

@end
