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



@implementation BBWidgetLibraryVC {
    NSDictionary *_widgets;
    NSTableCellView *_selectedCell;
    NSArray *_widgetCells; /* should be saved for retain selection */
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_widgetTypePopUpButton bind:NSContentBinding toObject:self withKeyPath:@"namesOfWidgetTypes" options:IUBindingDictNotRaisesApplicable];
    [_widgetTypePopUpButton selectItemWithTitle:@"All"];
    [self reloadWidgets];
    
    //add observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectWidget:) name:IUNotificationNewIUCreatedByCanvas object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectWidget:) name:IUWidgetLibrarySelectionDidChangeNotification object:self.view.window];


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


/* notification called by other VCs */
- (void)selectWidget:(NSNotification *)notification{
    if([notification.name isEqualToString:IUNotificationNewIUCreatedByCanvas]){
        [_tableView deselectAll:self];
        _selectedCell = nil;
    }
    else if([notification.name isEqualToString:IUWidgetLibrarySelectionDidChangeNotification]){
        id sender = [notification.userInfo objectForKey:IUWidgetLibrarySender];
        if([sender isNotEqualTo:self]){
            NSString *className = [notification.userInfo objectForKey:IUWidgetLibraryKey];
            if(className){
                NSUInteger index =0;
                for(NSTableCellView *cell in _widgetCells){
                    if([cell.objectValue[@"className"] isEqualToString:className]){
                        break;
                    }
                    index++;
                }
                [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
                _selectedCell = [self.tableView selectedCell];
            }
            else{
                
                [_tableView deselectAll:self];
                _selectedCell = nil;
            }
            
        }
    }
}

- (IBAction)clickWidgetLibraryTableView:(id)sender {
    
    NSTableCellView *cell = _tableView.selectedRow != -1 ? [_widgetCells objectAtIndex:_tableView.selectedRow] : nil;

    if (cell == nil || [cell isEqualTo:_selectedCell]) { //clear selection
        if([cell isEqualTo:_selectedCell]){
            [_tableView deselectAll:self];
        }
        _selectedCell = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:IUWidgetLibrarySelectionDidChangeNotification object:self.view.window userInfo:@{IUWidgetLibrarySender:self}];
    }
    else {
        _selectedCell = cell;
        [[NSNotificationCenter defaultCenter] postNotificationName:IUWidgetLibrarySelectionDidChangeNotification object:self.view.window userInfo:@{IUWidgetLibraryKey:cell.objectValue[@"className"], IUWidgetLibrarySender:self}];
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
        
        NSTableCellView *widgetViewCell = [_tableView makeViewWithIdentifier:@"widgetCell" owner:self];
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
