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
 
}

- (void)dealloc{
    
}

- (void)setProject:(IUProject *)project{
    _project = project;
 
    //[_mediaQueryPopupButton bind:NSContentBinding toObject:self.project withKeyPath:@"mqSizes" options:IUBindingDictNotRaisesApplicable];
    
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
    
    for (IUSheet *sheet in _project.allSheets) {
        for(IUBox *box in sheet.allChildren){
            [box setCurrentViewPort:_currentSelectedWidth];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQSelected object:self.view.window userInfo:@{IUNotificationMQSize:@(width), IUNotificationMQMaxSize:@(maxWidth), IUNotificationMQLargerSize:@(largerWidth), IUNotificationMQOldSize:@(oldSelectedWidth)} ];

}


- (IBAction)clickMediaQuerySettingButton:(id)sender {
    
}

@end
