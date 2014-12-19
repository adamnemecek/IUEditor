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

/* media query popover view outlet */
@property (strong) IBOutlet NSPopover *mediaQuerySettingPopover;
@property (weak) IBOutlet NSTextField *sizeTextField;
@property (weak) IBOutlet NSTableView *mediaQueryTableView;


@end

@implementation BBMediaQueryVC{
    NSInteger _currentSelectedWidth;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [_mediaQueryPopupButton bind:NSContentBinding toObject:self withKeyPath:@"project.mqSizes" options:IUBindingDictNotRaisesApplicable];

}

- (void)dealloc{
    JDSectionInfoLog(IULogDealloc, @"");
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
    
    for (IUSheet *sheet in _project.allSheets) {
        for(IUBox *box in sheet.allChildren){
            [box setCurrentViewPort:_currentSelectedWidth];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQSelected object:self.view.window userInfo:@{IUNotificationMQSize:@(width), IUNotificationMQMaxSize:@(maxWidth), IUNotificationMQLargerSize:@(largerWidth), IUNotificationMQOldSize:@(oldSelectedWidth)} ];

}


#pragma mark - Popover View Control

- (IBAction)clickMediaQuerySettingButton:(id)sender {
    if([_mediaQuerySettingPopover isShown]){
        [_mediaQuerySettingPopover close];
    }
    else{
        [_mediaQueryTableView reloadData];
        [_mediaQuerySettingPopover showRelativeToRect:[self.view frame] ofView:self.view preferredEdge:NSMinYEdge];
    }
}


- (IBAction)clickPopoverCloseButton:(id)sender {
    if([_mediaQuerySettingPopover isShown]){
        [_mediaQuerySettingPopover close];
    }
}
- (IBAction)clickNewSizeButton:(id)sender {
    NSInteger size = [_sizeTextField integerValue];
    if([_project.mqSizes containsObject:@(size)] == NO){
        
        
        NSInteger oldMaxSize = [[_project.mqSizes firstObject] integerValue];
        NSInteger maxSize = size > oldMaxSize ? size : oldMaxSize;
        [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQAdded object:self.view.window
                                                          userInfo:@{IUNotificationMQSize:@(size),
                                                                     IUNotificationMQOldMaxSize:@(oldMaxSize),
                                                                     IUNotificationMQMaxSize:@(maxSize)}];
        [_mediaQueryTableView reloadData];

    }
}

- (IBAction)clickRemoveSizeButton:(id)sender forSize:(NSNumber *)size{
    NSInteger oldMaxSize = [[_project.mqSizes firstObject] integerValue];
    NSInteger maxSize = [size integerValue] == oldMaxSize ? [[_project.mqSizes objectAtIndex:1] integerValue] : oldMaxSize;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQRemoved object:self userInfo:@{IUNotificationMQSize:size, IUNotificationMQMaxSize:@(maxSize)}];
    [_mediaQueryTableView reloadData];

}

#pragma mark - Manage Popover Table View
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return _project.mqSizes.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSInteger mqSize = [[_project.mqSizes objectAtIndex:row] integerValue];
    NSTableCellView *cell;
    if(mqSize < IUMobileSize){
        cell = [tableView makeViewWithIdentifier:@"mobileMediaQueryCell" owner:self];
    }
    else if (mqSize < IUTabletSize){
        cell = [tableView makeViewWithIdentifier:@"tabletMediaQueryCell" owner:self];
    }
    else{//pc Size
        cell = [tableView makeViewWithIdentifier:@"pcMediaQueryCell" owner:self];
    }
    [cell.textField setStringValue:[NSString stringWithFormat:@"%ld px", mqSize]];
    cell.objectValue = @(mqSize);
    
    return cell;
}

@end
