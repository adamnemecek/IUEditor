//
//  BBBackEndpropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBBackEndPropertyVC.h"
#import "IUText.h"

@interface BBBackEndPropertyVC ()
/* children view */
@property (weak) IBOutlet NSTableView *backEndTableView;
@property (strong) IBOutlet NSView *contentView;
@property (strong) IBOutlet NSView *visibleView;
@property (strong) IBOutlet NSView *ellipsisView;

/* property outlets */
@property (weak) IBOutlet NSTextField *contentTextField;
@property (weak) IBOutlet NSTextField *visibleTextField;
@property (weak) IBOutlet NSTextField *ellipsisTextField;
@property (weak) IBOutlet NSStepper *ellipsisStepper;


@end

@implementation BBBackEndPropertyVC{
    NSMutableArray *_childrenViewArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _childrenViewArray = [NSMutableArray array];
    [self outlet:_contentTextField bind:NSValueBinding property:@"pgContentVariable"];
    [self outlet:_visibleTextField bind:NSValueBinding property:@"pgVisibleConditionVariable"];
    [self outlet:_ellipsisTextField bind:NSValueBinding cascadingPropertyStorageProperty:@"pgEllipsisLine" options:@{NSNullPlaceholderBindingOption:@"0 line", NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];
    [self outlet:_ellipsisStepper bind:NSValueBinding cascadingPropertyStorageProperty:@"pgEllipsisLine" options:@{NSNullPlaceholderBindingOption:@"0 line", NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];

    
    //add observer to iuselection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIUSelection:) name:IUNotificationSelectionDidChange object:self.project];

}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    JDSectionInfoLog(IULogDealloc, @"");
}
#pragma mark - notification
- (void)changeIUSelection:(NSNotification *)notification{
    [_childrenViewArray removeAllObjects];
    [_childrenViewArray addObjectsFromArray:@[_contentView, _visibleView]];
    //select VC from className
    NSString *selectedClassName = [notification.userInfo objectForKey:@"selectionClassName"];
    if ([selectedClassName isEqualToString:[IUText className]]){
        [_childrenViewArray addObject:_ellipsisView];
    }
    
    [_backEndTableView reloadData];

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
