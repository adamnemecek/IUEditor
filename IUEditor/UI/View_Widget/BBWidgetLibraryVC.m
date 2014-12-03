//
//  BBWidgetLibraryVC.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 12. 1..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBWidgetLibraryVC.h"

@class BBWidgetLibraryViewCell;

@interface BBWidgetLibraryVC () <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *tableView;
- (NSArray *)namesOfWidgetGroups; //provides content in popupbutton

@end


@interface BBWidgetLibraryViewCell : NSTableCellView
@property BOOL isSelected;
@end

@implementation BBWidgetLibraryViewCell

@end


@implementation BBWidgetLibraryVC {
    NSArray *_widgets;
    BBWidgetLibraryViewCell *_selectedCell;
    NSArray *_widgetCells; /* should be saved for retain selection */
}


- (void)tableViewSelectionIsChanging:(NSNotification *)notification{
    BBWidgetLibraryViewCell *cell = _tableView.selectedRow != -1 ? [_widgetCells objectAtIndex:_tableView.selectedRow] : nil;
    
    if (cell == nil) { //clear selection
        _selectedCell.isSelected = NO;
        _selectedCell = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:IUWidgetSelectionDidChangeNotification object:self.view.window userInfo:nil];
    }
    else {
        _selectedCell.isSelected = NO;
        cell.isSelected = YES;
        _selectedCell = cell;
        [[NSNotificationCenter defaultCenter] postNotificationName:IUWidgetSelectionDidChangeNotification object:self.view.window userInfo:@{IUWidgetKey:cell.objectValue[@"name"]}];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setSelectedGroupIndex:(NSInteger)selectedGroupIndex{
    [self willChangeValueForKey:@"selectedGroupIndex"];
    
    _selectedGroupIndex = selectedGroupIndex;
    [self makeWidgetCells];
    [self.tableView reloadData];
    [self tableViewSelectionIsChanging:nil]; // clear selection
    
    [self didChangeValueForKey:@"selectedGroupIndex"];
}

- (void)setWidgets:(NSArray *)widgets {
    [self willChangeValueForKey:@"namesOfWidgetGroups"];
    
    _widgets = [widgets copy];
    [self makeWidgetCells];
    [self.tableView reloadData];
    [self tableViewSelectionIsChanging:nil]; // clear selection
    
    [self didChangeValueForKey:@"namesOfWidgetGroups"];
}

- (NSArray *)namesOfWidgetGroups{
    return [_widgets valueForKey:@"name"];
}

- (void)makeWidgetCells {
    NSArray *widgetList = _widgets[_selectedGroupIndex][@"widgets"];
    
    NSMutableArray *widgetCellMutableArray = [NSMutableArray array];
    for (NSString *widgetName in widgetList) {
        Class widgetClass = NSClassFromString(widgetName);
        NSImage *widgetImage = [widgetClass classImage];
        NSString *name = widgetName;
        NSString *shortDesc = [widgetClass shortDescription];
        
        NSArray *nibObjects;
        [[NSBundle mainBundle] loadNibNamed:@"BBWidgetCellView" owner:self topLevelObjects:&nibObjects];
        BBWidgetLibraryViewCell *widgetViewCell = [nibObjects[0] isKindOfClass:[NSView class]] ? nibObjects[0] : nibObjects[1];
        widgetViewCell.objectValue = @{@"name":name, @"image":widgetImage, @"shortDesc":shortDesc};
        [widgetCellMutableArray addObject:widgetViewCell];
    }
    
    _widgetCells = [widgetCellMutableArray copy];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_widgetCells count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return _widgetCells[row];
}




@end
