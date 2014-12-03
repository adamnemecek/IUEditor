//
//  BBWC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBWC.h"

#import "BBDefaultVCs.h"

@interface BBWC ()


//top tool bar
@property (weak) IBOutlet NSView *topBarView;
@property (weak) IBOutlet NSView *structureView;
@property (weak) IBOutlet NSView *toolBarView;

//canvas
@property (weak) IBOutlet NSView *canvasView;

//inspector view (left)
@property (weak) IBOutlet NSBox *propertyIconBox;
@property NSMatrix *propertyIconMatrix;
@property (strong) IBOutlet NSButtonCell *propertyIconButtonCell;

//property tab view
@property (weak) IBOutlet NSTabView *propertySettingTabView;
@property (weak) IBOutlet NSLayoutConstraint *propertySettingTabViewRightConstraint;

//setting view ina tab view
@property (weak) IBOutlet NSView *tabWidgetView;
@property (weak) IBOutlet NSView *tabPropertyView;
@property (weak) IBOutlet NSView *tabImageView;
@property (weak) IBOutlet NSView *tabStyleView;
@property (weak) IBOutlet NSView *tabActionView;
@property (weak) IBOutlet NSView *tabEventView;
@property (weak) IBOutlet NSView *tabLibraryView;
@property (weak) IBOutlet NSView *tabTracingView;
@property (weak) IBOutlet NSView *tabStructureView;
@property (weak) IBOutlet NSView *tabBackEndView;

//bottom view
@property (weak) IBOutlet NSView *pageTabView;

@end

@implementation BBWC{
    //wc properties
    BBPropertyTabType _currentTabType;
    
    //view controllers
    BBTopToolBarVC *_topToolBarVC;
    
}

- (id)initWithWindow:(NSWindow *)window{
    self = [super initWithWindow:window];
    if(self){
        //initailize property
        _currentTabType = BBPropertyTabTypeWidget;
        
        //alloc VC
        _topToolBarVC = [[BBTopToolBarVC alloc] initWithNibName:[BBTopToolBarVC class].className bundle:nil];
        
      
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    
    //allocation property icon matrix
    //xib에서 만들면 warning이 생김. - matrix만 code로 구현.
    _propertyIconMatrix  = [[NSMatrix alloc] initWithFrame:NSZeroRect mode:NSRadioModeMatrix prototype:_propertyIconButtonCell numberOfRows:10 numberOfColumns:1];
    _propertyIconMatrix.cellSize = NSMakeSize(38, 42);
    [_propertyIconMatrix setAllowsEmptySelection:YES];
    [_propertyIconMatrix setTarget:self];
    [_propertyIconMatrix setAction:@selector(clickPropertyIconMatrix:)];
    
    NSArray *matrixCellArray = [_propertyIconMatrix cells];
    for(int i=0; i<10; i++){
        NSButtonCell *cell = [matrixCellArray objectAtIndex:i];
        //0번재 cell은 다루지 않음.
        BBPropertyTabType currentType = i;
        switch (currentType) {
            case BBPropertyTabTypeWidget:
                [cell setImage:[NSImage imageNamed:@"tab_01_widget_off"]];
                [cell setAlternateImage:[NSImage imageNamed:@"tab_01_widget_on"]];
                break;
            case BBPropertyTabTypeProperty:
                [cell setImage:[NSImage imageNamed:@"tab_02_property_off"]];
                [cell setAlternateImage:[NSImage imageNamed:@"tab_02_property_on"]];
                break;
            case BBPropertyTabTypeImage:
                [cell setImage:[NSImage imageNamed:@"tab_03_image_off"]];
                [cell setAlternateImage:[NSImage imageNamed:@"tab_03_image_on"]];
                break;
            case BBPropertyTabTypeStyle:
                [cell setImage:[NSImage imageNamed:@"tab_04_style_off"]];
                [cell setAlternateImage:[NSImage imageNamed:@"tab_04_style_on"]];
                break;
            case BBPropertyTabTypeAction:
                [cell setImage:[NSImage imageNamed:@"tab_05_action_off"]];
                [cell setAlternateImage:[NSImage imageNamed:@"tab_05_action_on"]];
                break;
            case BBPropertyTabTypeEvent:
                [cell setImage:[NSImage imageNamed:@"tab_06_event_off"]];
                [cell setAlternateImage:[NSImage imageNamed:@"tab_06_event_on"]];
                break;
            case BBPropertyTabTypeLibrary:
                [cell setImage:[NSImage imageNamed:@"tab_07_library_off"]];
                [cell setAlternateImage:[NSImage imageNamed:@"tab_07_library_on"]];
                break;
            case BBPropertyTabTypeTracing:
                [cell setImage:[NSImage imageNamed:@"tab_08_tracing_off"]];
                [cell setAlternateImage:[NSImage imageNamed:@"tab_08_tracing_on"]];
                break;
            case BBPropertyTabTypeStructure:
                [cell setImage:[NSImage imageNamed:@"tab_09_structure_off"]];
                [cell setAlternateImage:[NSImage imageNamed:@"tab_09_structure_on"]];
                break;
            case BBPropertyTabTypeBackEnd:
                [cell setImage:[NSImage imageNamed:@"tab_10_backend_off"]];
                [cell setAlternateImage:[NSImage imageNamed:@"tab_10_backend_on"]];
                break;
            default:
                break;
        }
    }
    [_propertyIconBox addSubviewTopHalfFullFrame:_propertyIconMatrix];

    //connect VCs
    [_topBarView addSubviewFullFrame:_topToolBarVC.view];   

}

#pragma mark - property Icon

- (IBAction)clickPropertyIconMatrix:(id)sender {
    
    BBPropertyTabType type = (int)[_propertyIconMatrix selectedRow];
    if(type == _currentTabType){
        [_propertyIconMatrix deselectAllCells];
        _currentTabType = BBPropertyTabTypeNone;
        [self closePropertySettingTabView];
    }
    else{
        [_propertyIconMatrix selectCellAtRow:type column:1];
        _currentTabType = type;
        [self openPropertySettingTabViewForIndex:type];
    }
    
}

- (void)openPropertySettingTabViewForIndex:(int)index{
    [_propertySettingTabView selectTabViewItemAtIndex:index];
    [_propertySettingTabViewRightConstraint setConstant:37];
}
- (void)closePropertySettingTabView{
    [_propertySettingTabViewRightConstraint setConstant:(-241+38)];
}

@end
