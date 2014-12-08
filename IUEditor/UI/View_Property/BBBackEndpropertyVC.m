//
//  BBBackEndpropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBBackEndPropertyVC.h"

@interface BBBackEndPropertyVC ()
/* children view */
@property (strong) IBOutlet NSView *contentView;
@property (strong) IBOutlet NSView *visibleView;
@property (strong) IBOutlet NSView *ellipsisView;


@end

@implementation BBBackEndPropertyVC{
    NSArray *_childrenViewArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _childrenViewArray = @[_contentView, _visibleView, _ellipsisView];
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
