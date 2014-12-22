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
    BOOL _isLoadedMaxViewPort;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [_mediaQueryPopupButton bind:NSContentBinding toObject:self withKeyPath:@"project.viewPorts" options:IUBindingDictNotRaisesApplicable];
    [self.view addObserver:self forKeyPath:@"window" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)dealloc{
    JDSectionInfoLog(IULogDealloc, @"");
}

- (void)windowDidChange:(NSDictionary *)change{
    //window가 붙자마자 media query default select
    if ([change[@"new"] isKindOfClass:[NSWindow class]]) {
        [self loadMaxViewPort];
    }
}

- (void)loadMaxViewPort{
    if(_isLoadedMaxViewPort == NO){
        if([self isViewLoaded] && self.project){
            _isLoadedMaxViewPort = YES;
            //init with mediaquery
            [self selectMediaQueryWidth:_project.maxViewPort];
        }
    }
}

- (void)setProject:(IUProject *)project{
    _project = project;
  
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
    if(self.view.window){
        [[NSNotificationCenter defaultCenter] postNotificationName:IUProjectDidChangeSelectedViewPortNotification object:self.view.window userInfo:@{IUViewPortKey:@(width), IUMaxViewPortKey:@(maxWidth), IULargerViewPortKey:@(largerWidth), IUOldViewPortKey:@(oldSelectedWidth)} ];
    }

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
    if([_project.viewPorts containsObject:@(size)] == NO){
        
        
        NSInteger oldMaxSize = [[_project.viewPorts firstObject] integerValue];
        NSInteger maxSize = size > oldMaxSize ? size : oldMaxSize;
        [[NSNotificationCenter defaultCenter] postNotificationName:IUProjectDidAddViewPortNotification object:self.view.window
                                                          userInfo:@{IUViewPortKey:@(size),
                                                                     IUOldMaxSizeKey:@(oldMaxSize),
                                                                     IUMaxViewPortKey:@(maxSize)}];
        [_mediaQueryTableView reloadData];

    }
}

- (IBAction)clickRemoveSizeButton:(id)sender forSize:(NSNumber *)size{
    NSInteger oldMaxSize = [[_project.viewPorts firstObject] integerValue];
    NSInteger maxSize = [size integerValue] == oldMaxSize ? [[_project.viewPorts objectAtIndex:1] integerValue] : oldMaxSize;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IUProjectDidRemoveViewPortNotification object:self userInfo:@{IUViewPortKey:size, IUMaxViewPortKey:@(maxSize)}];
    [_mediaQueryTableView reloadData];

}

#pragma mark - Manage Popover Table View
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return _project.viewPorts.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSInteger viewPort = [[_project.viewPorts objectAtIndex:row] integerValue];
    NSTableCellView *cell;
    if(viewPort < IUMobileSize){
        cell = [tableView makeViewWithIdentifier:@"mobileMediaQueryCell" owner:self];
    }
    else if (viewPort < IUTabletSize){
        cell = [tableView makeViewWithIdentifier:@"tabletMediaQueryCell" owner:self];
    }
    else{//pc Size
        cell = [tableView makeViewWithIdentifier:@"pcMediaQueryCell" owner:self];
    }
    [cell.textField setStringValue:[NSString stringWithFormat:@"%ld px", viewPort]];
    cell.objectValue = @(viewPort);
    
    return cell;
}

@end
