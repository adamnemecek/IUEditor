//
//  BBWidgetLibraryVC.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 12. 1..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBWidgetLibraryVC.h"

@interface BBWidgetLibraryViewCell : NSTableCellView

@end


@interface BBWidgetLibraryVC () <NSTableViewDataSource, NSTableViewDelegate> {
    NSArray *_widgets;
    NSArray *_widgetInfosInCurrentSelectedGroup;
}
@property (weak) IBOutlet NSTableView *tableView;

@property (nonatomic) NSInteger selectedGroupIndex; // selected popup index
- (NSArray *)widgetInfosInCurrentSelectedGroup; // provide table cell contents
- (NSArray *)namesOfWidgetGroups; //provides content in popupbutton
@end


@implementation BBWidgetLibraryVC


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setSelectedGroupIndex:(NSInteger)selectedGroupIndex{
    [self willChangeValueForKey:@"selectedGroupIndex"];
    _selectedGroupIndex = selectedGroupIndex;
    [self updateWidgetInfosInCurrentSelectedGroup];
    [self.tableView reloadData];
    [self didChangeValueForKey:@"selectedGroupIndex"];
}

- (void)setWidgets:(NSArray *)widgets {
    [self willChangeValueForKey:@"namesOfWidgetGroups"];
    _widgets = [widgets copy];
    [self updateWidgetInfosInCurrentSelectedGroup];
    [self.tableView reloadData];
    [self didChangeValueForKey:@"namesOfWidgetGroups"];
}

- (NSArray *)namesOfWidgetGroups{
    return [_widgets valueForKey:@"name"];
}

- (void)updateWidgetInfosInCurrentSelectedGroup {
    NSArray *widgetList = _widgets[_selectedGroupIndex][@"widgets"];
    NSMutableArray *retArray = [NSMutableArray array];
    for (NSString *widgetName in widgetList) {
        Class c = NSClassFromString(widgetName);
        NSImage *widgetImage = [c classImage];
        NSString *name = widgetName;
        NSString *shortDesc = [c shortDescription];
        
        [retArray addObject:@{@"name":name, @"image":widgetImage, @"shortDesc":shortDesc}];
    }
    _widgetInfosInCurrentSelectedGroup = retArray;
}

- (NSArray *)widgetInfosInCurrentSelectedGroup{
    return _widgetInfosInCurrentSelectedGroup;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_widgetInfosInCurrentSelectedGroup count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *result = [tableView makeViewWithIdentifier:@"MyView" owner:self];
    
    // There is no existing cell to reuse so create a new one
    if (result == nil) {
        
        // Create the new NSTextField with a frame of the {0,0} with the width of the table.
        // Note that the height of the frame is not really relevant, because the row height will modify the height.
        NSArray *nibObjects;
        [[NSBundle mainBundle] loadNibNamed:@"BBWidgetCellView" owner:self topLevelObjects:&nibObjects];
        result = [nibObjects[0] isKindOfClass:[NSView class]] ? nibObjects[0] : nibObjects[1];
        result.identifier = @"MyView";
    }
    
    // result is now guaranteed to be valid, either as a reused cell
    // or as a new cell, so set the stringValue of the cell to the
    // nameArray value at row
    // result.stringValue = [self.nameArray objectAtIndex:row];
    result.objectValue = _widgetInfosInCurrentSelectedGroup[row];
    // Return the result
    return result;
}




@end
