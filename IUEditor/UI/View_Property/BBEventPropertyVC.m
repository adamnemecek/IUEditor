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
@property (weak) IBOutlet NSTextField *yTextField;
@property (weak) IBOutlet NSTextField *opacityTextField;

/* formatter */
@property (strong) IBOutlet NSNumberFormatter *pixelFormatter;
@property (strong) IBOutlet NSNumberFormatter *percentFormatter;

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
    
    /* style storages */
    [self outlet:_opacityTextField bind:NSValueBinding cascadingStyleStorageProperty:@"opacity" options:@{NSNullPlaceholderBindingOption:@"100%", NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];

    /* add observers */
    [self addObserver:self forKeyPath:[self pathForCascadingPositionStorageProperty:@"xUnit"] options:0 context:@"unit"];
    [self addObserver:self forKeyPath:[self pathForCascadingPositionStorageProperty:@"yUnit"] options:0 context:@"unit"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iuSelectionChange:) name:IUNotificationSelectionDidChange object:self.project];
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:[self pathForCascadingPositionStorageProperty:@"xUnit"]];
    [self removeObserver:self forKeyPath:[self pathForCascadingPositionStorageProperty:@"yUnit"]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    JDSectionInfoLog(IULogDealloc, @"");
}

#pragma mark - observing
- (void)unitContextDidChange:(NSDictionary *)dictionary{
    NSString *currentKeyPath = dictionary[kJDKey];
    NSString *currentKey = [currentKeyPath pathExtension];
    
    id value = [self valueForKeyPath:currentKeyPath];
    if([currentKey isEqualToString:@"xUnit"]){
        if (value && [value boolValue]){
            [_xTextField setFormatter:_percentFormatter];
        }
        else{
            [_xTextField setFormatter:_pixelFormatter];
        }
    }
    else if ([currentKey isEqualToString:@"yUnit"]){
        if (value && [value boolValue]){
            [_yTextField setFormatter:_percentFormatter];
        }
        else{
            [_yTextField setFormatter:_pixelFormatter];
        }
    }
}


- (void)iuSelectionChange:(NSNotification *)notification{
    if (self.cascadingActionStorage.scrollXPosition){
        [_enableScrollXButton setState:YES];
    }
    else{
        [_enableScrollXButton setState:NO];
    }
    
    if (self.cascadingActionStorage.scrollYPosition){
        [_enableScrollYButton setState:YES];
    }
    else{
        [_enableScrollYButton setState:NO];
    }
    if (self.cascadingActionStorage.scrollOpacity){
        [_enableScrollOpacityButton setState:YES];
    }
    else{
        [_enableScrollOpacityButton setState:NO];
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
