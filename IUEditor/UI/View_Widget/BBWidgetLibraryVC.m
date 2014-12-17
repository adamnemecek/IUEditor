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
@property (weak) IBOutlet NSPopUpButton *widgetTypePopUpButton;


- (NSArray *)namesOfWidgetTypes; //provides content in popupbutton
@end


@interface BBWidgetLibraryViewCell : NSTableCellView
@property BOOL isSelected;
@end

@implementation BBWidgetLibraryViewCell

@end


@implementation BBWidgetLibraryVC {
    NSDictionary *_widgets;
    BBWidgetLibraryViewCell *_selectedCell;
    NSArray *_widgetCells; /* should be saved for retain selection */
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_widgetTypePopUpButton bind:NSContentBinding toObject:self withKeyPath:@"namesOfWidgetTypes" options:IUBindingDictNotRaisesApplicable];
    [_widgetTypePopUpButton selectItemWithTitle:@"All"];
    [self reloadWidgets];
    
    //add observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deselectCurrentWidget:) name:IUNotificationNewIUCreatedByCanvas object:self.view.window];

}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    JDSectionInfoLog(IULogDealloc, @"");

}


- (void)reloadWidgets{
    [self makeWidgetCells];
    [self.tableView reloadData];
    [self.tableView deselectAll:self];
}

/* notification called by canvas after make iu*/
- (void)deselectCurrentWidget:(NSNotification *)notification{
    [_tableView deselectAll:self];
    _selectedCell.isSelected = NO;
    _selectedCell = nil;
}

- (IBAction)clickWidgetLibraryTableView:(id)sender {
    
    BBWidgetLibraryViewCell *cell = _tableView.selectedRow != -1 ? [_widgetCells objectAtIndex:_tableView.selectedRow] : nil;

    if (cell == nil || [cell isEqualTo:_selectedCell]) { //clear selection
        if([cell isEqualTo:_selectedCell]){
            [_tableView deselectAll:self];
        }
        _selectedCell.isSelected = NO;
        _selectedCell = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:IUWidgetLibrarySelectionDidChangeNotification object:self.view.window userInfo:nil];
    }
    else {
        _selectedCell.isSelected = NO;
        cell.isSelected = YES;
        _selectedCell = cell;
        [[NSNotificationCenter defaultCenter] postNotificationName:IUWidgetLibrarySelectionDidChangeNotification object:self.view.window userInfo:@{IUWidgetLibraryKey:cell.objectValue[@"className"]}];
    }
}

- (IBAction)clickWidgetTypeButton:(id)sender {
    [self reloadWidgets];
}

#pragma mark - load widgets

- (void)setWidgetNameList:(NSArray *)widgetNameList {
    [self willChangeValueForKey:@"namesOfWidgetTypes"];
    
    NSMutableDictionary *widgetTypeDictionary = [NSMutableDictionary dictionary];
    
    [widgetTypeDictionary setObject:widgetNameList forKey:@"All"];

    
    for(NSString *className in widgetNameList){
        Class widgetClass = NSClassFromString(className);
        NSString *widgetType = [widgetClass widgetType];
        NSMutableArray *widgetTypeList = [widgetTypeDictionary objectForKey:widgetType];
        if(widgetTypeList == nil){
            widgetTypeList = [NSMutableArray array];
            [widgetTypeDictionary setObject:widgetTypeList forKey:widgetType];
        }
        
        [widgetTypeList addObject:className];
        
    }
    
    _widgets = [widgetTypeDictionary copy];
    
    [self didChangeValueForKey:@"namesOfWidgetTypes"];
    
    [self reloadWidgets];
}


- (NSArray *)namesOfWidgetTypes{
    return [_widgets allKeys];
}

- (void)makeWidgetCells {
    NSArray *widgetList = _widgets[[_widgetTypePopUpButton titleOfSelectedItem]];
    
    NSMutableArray *widgetCellMutableArray = [NSMutableArray array];
    for (NSString *widgetName in widgetList) {
        Class widgetClass = NSClassFromString(widgetName);
        NSImage *widgetImage = [widgetClass classImage];
        NSString *shortDesc = [widgetClass shortDescription];
        
        NSArray *nibObjects;
        [[NSBundle mainBundle] loadNibNamed:@"BBWidgetCellView" owner:self topLevelObjects:&nibObjects];
        BBWidgetLibraryViewCell *widgetViewCell = [nibObjects[0] isKindOfClass:[NSView class]] ? nibObjects[0] : nibObjects[1];
        widgetViewCell.objectValue = @{@"className":widgetName, @"image":widgetImage, @"shortDesc":shortDesc};
        [widgetCellMutableArray addObject:widgetViewCell];
    }
    
    _widgetCells = [widgetCellMutableArray copy];
}

#pragma mark - tableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_widgetCells count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return _widgetCells[row];
}




@end
