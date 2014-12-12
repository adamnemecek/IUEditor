//
//  BBMediaQueryVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBMediaQueryVC.h"
#import "IUSheet.h"

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
- (void)setProject:(IUProject *)project{
    _project = project;
    
    //init with mediaquery
    [self selectMediaQueryWidth:_project.maxViewPort];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQSelected object:self.view.window userInfo:@{IUNotificationMQSize:@(width), IUNotificationMQMaxSize:@(maxWidth), IUNotificationMQLargerSize:@(largerWidth), IUNotificationMQOldSize:@(oldSelectedWidth)} ];
    
    for (IUSheet *sheet in _project.allSheets) {
        for(IUBox *box in sheet.allChildren){
            [box setCurrentViewPort:_currentSelectedWidth];
        }
    }
    
}


- (IBAction)clickMediaQuerySettingButton:(id)sender {
    
}

@end
