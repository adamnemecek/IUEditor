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

@end

@implementation BBEventPropertyVC{
    NSArray *_childrenViewArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _childrenViewArray = @[_scrollAnimatorView];
}

- (void)dealloc{
    JDSectionInfoLog(IULogDealloc, @"");
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
