//
//  BBEventPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBEventPropertyVC.h"

@interface BBEventPropertyVC ()
/* children views */
@property (strong) IBOutlet NSView *scrollAnimatorView;

/* property setting outlets */
/* action storage */
@property (weak) IBOutlet NSTextField *scrollXTextField;
@property (weak) IBOutlet NSTextField *scrollYTextField;
@property (weak) IBOutlet NSTextField *scrollOpacityTextField;

@property (weak) IBOutlet NSButton *enableScrollXButton;
@property (weak) IBOutlet NSButton *enableScrollYButton;
@property (weak) IBOutlet NSButton *enableScrollOpacityButton;

/* default  position, style storages*/
@property (weak) IBOutlet NSTextField *xTextField;
@property (weak) IBOutlet NSButton *xUnitButton;
@property (weak) IBOutlet NSButton *scrollXUnitButton;

@property (weak) IBOutlet NSTextField *yTextField;
@property (weak) IBOutlet NSButton *yUnitButton;
@property (weak) IBOutlet NSButton *scrollYUnitButton;

@property (weak) IBOutlet NSTextField *opacityTextField;

@end

@implementation BBEventPropertyVC{
    NSArray *_childrenViewArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _childrenViewArray = @[_scrollAnimatorView];
    
    /* action storages */
    [self outlet:_scrollXTextField bind:NSValueBinding cascadingActionStorageProperty:@"scrollXPosition"];
    [self outlet:_scrollYTextField bind:NSValueBinding cascadingActionStorageProperty:@"scrollYPosition"];
    [self outlet:_scrollOpacityTextField bind:NSValueBinding cascadingActionStorageProperty:@"scrollOpacity"];
    
    /* position storages */
    [self outlet:_xTextField bind:NSValueBinding cascadingPositionStorageProperty:@"x"];
    [self outlet:_yTextField bind:NSValueBinding cascadingPositionStorageProperty:@"y"];
    
    [self outlet:_xUnitButton bind:NSValueBinding cascadingPositionStorageProperty:@"xUnit"];
    [self outlet:_scrollXUnitButton bind:NSValueBinding cascadingPositionStorageProperty:@"xUnit"];
    
    [self outlet:_yUnitButton bind:NSValueBinding cascadingPositionStorageProperty:@"yUnit"];
    [self outlet:_scrollYUnitButton bind:NSValueBinding cascadingPositionStorageProperty:@"yUnit"];
    
    [_xUnitButton setEnabled:NO];
    [_scrollXUnitButton setEnabled:NO];
    [_yUnitButton setEnabled:NO];
    [_scrollYUnitButton setEnabled:NO];
    
    /* style storages */
    [self outlet:_opacityTextField bind:NSValueBinding cascadingStyleStorageProperty:@"opacity"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iuSelectionChange:) name:IUNotificationSelectionDidChange object:self.project];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    JDSectionInfoLog(IULogDealloc, @"");
}
#pragma mark -

- (void)iuSelectionChange:(NSNotification *)notification{
    if (self.cascadingActionStorage.scrollXPosition){
        [_scrollXTextField setEnabled:YES];
    }
    else{
        [_scrollXTextField setEnabled:NO];
    }
    
    if (self.cascadingActionStorage.scrollYPosition){
        [_scrollYTextField setEnabled:YES];
    }
    else{
        [_scrollYTextField setEnabled:NO];
    }
    if (self.cascadingActionStorage.scrollOpacity){
        [_scrollOpacityTextField setEnabled:YES];
    }
    else{
        [_scrollOpacityTextField setEnabled:NO];
    }
    
}
- (IBAction)clickScrollXPoisitionButton:(id)sender {
    if([sender state] == NO){
        self.cascadingActionStorage.scrollXPosition = nil;
    }
    [_scrollXTextField setEnabled:[sender state]];

}
- (IBAction)clickScrollYPositionButton:(id)sender {
    if([sender state] == NO){
        self.cascadingActionStorage.scrollYPosition = nil;
    }
    [_scrollYTextField setEnabled:[sender state]];
    
}
- (IBAction)clickScrollOpacityButton:(id)sender {
    if([sender state] == NO){
        self.cascadingActionStorage.scrollOpacity = nil;
    }

    [_scrollOpacityTextField setEnabled:[sender state]];

}



#pragma mark - table view

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_childrenViewArray count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return [_childrenViewArray objectAtIndex:row];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    NSView *currentView = [_childrenViewArray objectAtIndex:row];
    return currentView.frame.size.height;
}

@end
