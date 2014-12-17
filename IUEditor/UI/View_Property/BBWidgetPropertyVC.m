//
//  BBWidgetPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBWidgetPropertyVC.h"

@interface BBWidgetPropertyVC ()

@property (weak) IBOutlet NSTableView *widgetPropertyTableView;

@end

@implementation BBWidgetPropertyVC{
    NSArray *_childrenViewArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _childrenViewArray = [NSArray array];
    
    //add observer to iuselection 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIUSelection:) name:IUNotificationSelectionDidChange object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    JDSectionInfoLog(IULogDealloc, @"");

}


#pragma mark - notification
- (void)changeIUSelection:(NSNotification *)notification{
    NSString *selectedClassName = [notification.userInfo objectForKey:@"selectionClassName"];
    
    if([selectedClassName isEqualToString:[IUBox className]]){
        //TODO:
    }
    
    [_widgetPropertyTableView reloadData];

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
