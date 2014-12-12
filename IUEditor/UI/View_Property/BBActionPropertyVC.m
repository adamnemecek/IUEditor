//
//  BBActionPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBActionPropertyVC.h"

@interface BBActionPropertyVC ()

/* children views of table view */
@property (strong) IBOutlet NSView *linkView;
@property (strong) IBOutlet NSView *mouseOverView;

/* link view outlet*/
@property (weak) IBOutlet NSPopUpButton *linkPagePopupButton;
@property (weak) IBOutlet NSPopUpButton *linkDivPopupButton;

@property (weak) IBOutlet NSTextField *linkURLTextField;

/* mouse over view outlet */
/* this property cannot be changed */
@property (weak) IBOutlet NSColorWell *selectedBgColorWell;
@property (weak) IBOutlet NSColorWell *selectedTextColorWell;

@property (weak) IBOutlet NSColorWell *hoverBGColorWell;
@property (weak) IBOutlet NSTextField *hoverTimeTextField;
@property (weak) IBOutlet NSColorWell *hoverTextColorWell;
@property (weak) IBOutlet NSTextField *hoverBGXpositionTextField;
@property (weak) IBOutlet NSTextField *hoverBGYPositionTextField;

@end

@implementation BBActionPropertyVC{
    NSArray *_childrenViewArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _childrenViewArray = @[_linkView, _mouseOverView];
    
    //binding
    /* link */
    
    
    /* mouse hover */
    [self outlet:_selectedBgColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"bgColor"];
    [self outlet:_selectedTextColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"fontColor"];
    

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
