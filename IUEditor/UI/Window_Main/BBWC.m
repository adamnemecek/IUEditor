//
//  BBWC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBWC.h"

#import "LMWindow.h"

#import "BBDefaultVCs.h"
#import "IUProjectDocument.h"

#if DEBUG

#import "LMDebugSourceWC.h"

#endif

@interface BBWC ()

@property (strong) IBOutlet LMWindow *mainWindow;

//top tool bar
@property (weak) IBOutlet NSView *topToolBarView;
@property (weak) IBOutlet NSView *structureToolBarView;
@property (weak) IBOutlet NSView *propertyToolBarView;

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

//debug
@property (weak) IBOutlet NSButton *debugButton;

@end

@implementation BBWC{
    //wc properties
    IUProject *_project;
    BBPropertyTabType _currentTabType;
    IUSheet *_currentSheet;
    
    //view controllers
    BBTopToolBarVC *_topToolBarVC;
    BBStructureToolBarVC *_structureToolBarVC;
    BBPropertyToolBarVC *_propertyToolBarVC;
    
    LMCanvasVC *_canvasVC;
    
    //property vcs
    BBWidgetLibraryVC *_widgetLibraryVC;
    BBWidgetPropertyVC *_widgetPropertyVC;
    BBStylePropertyVC *_stylePropertyVC;
    BBImagePropertyVC *_imagePropertyVC;
    BBActionPropertyVC *_actionPropertyVC;
    BBEventPropertyVC *_eventPropertyVC;
    BBResourceLibraryVC *_resourceLibraryVC;
    BBTracingPropertyVC *_tracingPropertyVC;
    BBProjectStructureVC *_projectStructureVC;
    BBBackEndPropertyVC *_backEndPropertyVC;
    
    
#if DEBUG
    LMDebugSourceWC *_debugWC;

#endif
    
}

- (id)initWithWindow:(NSWindow *)window{
    self = [super initWithWindow:window];
    if(self){
        //initailize property
        _currentTabType = BBPropertyTabTypeWidget;
        
        
        //alloc VC
        //toolbar
        _topToolBarVC = [[BBTopToolBarVC alloc] initWithNibName:[BBTopToolBarVC className] bundle:nil];
        _structureToolBarVC = [[BBStructureToolBarVC alloc] initWithNibName:[BBStructureToolBarVC className] bundle:nil];
        _propertyToolBarVC = [[BBPropertyToolBarVC alloc] initWithNibName:[BBPropertyToolBarVC className] bundle:nil];
        
        //canvas
        _canvasVC = [[LMCanvasVC alloc] initWithNibName:[LMCanvasVC className] bundle:nil];

        
        //property
        _widgetLibraryVC = [[BBWidgetLibraryVC alloc] initWithNibName:[BBWidgetLibraryVC className] bundle:nil];
        _widgetPropertyVC = [[BBWidgetPropertyVC alloc] initWithNibName:[BBWidgetPropertyVC className] bundle:nil];
        _stylePropertyVC = [[BBStylePropertyVC alloc] initWithNibName:[BBStylePropertyVC className] bundle:nil];
        _imagePropertyVC = [[BBImagePropertyVC alloc] initWithNibName:[BBImagePropertyVC className] bundle:nil];
        _actionPropertyVC = [[BBActionPropertyVC alloc] initWithNibName:[BBActionPropertyVC className] bundle:nil];
        _eventPropertyVC = [[BBEventPropertyVC alloc] initWithNibName:[BBEventPropertyVC className] bundle:nil];
        _resourceLibraryVC = [[BBResourceLibraryVC alloc] initWithNibName:[BBResourceLibraryVC className] bundle:nil];
        _tracingPropertyVC = [[BBTracingPropertyVC alloc] initWithNibName:[BBTracingPropertyVC className] bundle:nil];
        _projectStructureVC = [[BBProjectStructureVC alloc] initWithNibName:[BBProjectStructureVC className] bundle:nil];
        _backEndPropertyVC = [[BBBackEndPropertyVC alloc] initWithNibName:[BBBackEndPropertyVC className] bundle:nil];

        
        
        
        //alloc manager & controller
        _sourceManager = [[IUSourceManager alloc] init];
        [_sourceManager setCanvasVC:_canvasVC];
        
        _iuController = [[IUController alloc] init];
        
        //initailize manager
        [_topToolBarVC setSourceManager:_sourceManager];
        [_projectStructureVC setIuController:_iuController];
        [_structureToolBarVC setIuController:_iuController];
        [_propertyToolBarVC setIuController:_iuController];
        
#if DEBUG
        _debugWC = [[LMDebugSourceWC alloc] initWithWindowNibName:@"LMDebugSourceWC"];
        _debugWC.canvasVC = _canvasVC;
#endif
        
      
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
#if DEBUG
    [_debugButton setHidden:NO];
#else
    [_debugButton setHidden:YES];
#endif
    
    
    //allocation property icon matrix
    //xib에서 만들면 warning이 생김. - matrix만 code로 구현.
    _propertyIconMatrix  = [[NSMatrix alloc] initWithFrame:NSZeroRect mode:NSRadioModeMatrix prototype:_propertyIconButtonCell numberOfRows:10 numberOfColumns:1];
    _propertyIconMatrix.cellSize = NSMakeSize(39, 34);
    _propertyIconMatrix.intercellSpacing = NSMakeSize(0, 8);
    [_propertyIconMatrix setAllowsEmptySelection:YES];
    [_propertyIconMatrix setTarget:self];
    [_propertyIconMatrix setAction:@selector(clickPropertyIconMatrix:)];
    
    NSArray *matrixCellArray = [_propertyIconMatrix cells];
    for(int i=0; i<10; i++){
        NSButtonCell *matrixCell = [matrixCellArray objectAtIndex:i];
        BBPropertyTabType currentType = i;
        switch (currentType) {
            case BBPropertyTabTypeWidget:
                [matrixCell setImage:[NSImage imageNamed:@"tab_01_widget_off"]];
                [matrixCell setAlternateImage:[NSImage imageNamed:@"tab_01_widget_on"]];
                break;
            case BBPropertyTabTypeProperty:
                [matrixCell setImage:[NSImage imageNamed:@"tab_02_property_off"]];
                [matrixCell setAlternateImage:[NSImage imageNamed:@"tab_02_property_on"]];
                break;
            case BBPropertyTabTypeImage:
                [matrixCell setImage:[NSImage imageNamed:@"tab_03_image_off"]];
                [matrixCell setAlternateImage:[NSImage imageNamed:@"tab_03_image_on"]];
                break;
            case BBPropertyTabTypeStyle:
                [matrixCell setImage:[NSImage imageNamed:@"tab_04_style_off"]];
                [matrixCell setAlternateImage:[NSImage imageNamed:@"tab_04_style_on"]];
                break;
            case BBPropertyTabTypeAction:
                [matrixCell setImage:[NSImage imageNamed:@"tab_05_action_off"]];
                [matrixCell setAlternateImage:[NSImage imageNamed:@"tab_05_action_on"]];
                break;
            case BBPropertyTabTypeEvent:
                [matrixCell setImage:[NSImage imageNamed:@"tab_06_event_off"]];
                [matrixCell setAlternateImage:[NSImage imageNamed:@"tab_06_event_on"]];
                break;
            case BBPropertyTabTypeLibrary:
                [matrixCell setImage:[NSImage imageNamed:@"tab_07_library_off"]];
                [matrixCell setAlternateImage:[NSImage imageNamed:@"tab_07_library_on"]];
                break;
            case BBPropertyTabTypeTracing:
                [matrixCell setImage:[NSImage imageNamed:@"tab_08_tracing_off"]];
                [matrixCell setAlternateImage:[NSImage imageNamed:@"tab_08_tracing_on"]];
                break;
            case BBPropertyTabTypeStructure:
                [matrixCell setImage:[NSImage imageNamed:@"tab_09_structure_off"]];
                [matrixCell setAlternateImage:[NSImage imageNamed:@"tab_09_structure_on"]];
                break;
            case BBPropertyTabTypeBackEnd:
                [matrixCell setImage:[NSImage imageNamed:@"tab_10_backend_off"]];
                [matrixCell setAlternateImage:[NSImage imageNamed:@"tab_10_backend_on"]];
                break;
            default:
                break;
        }
    }
    [_propertyIconBox addSubviewTopHalfFullFrame:_propertyIconMatrix];
    
    //connect VCs
    //toolbar
    [_topToolBarView addSubviewFullFrame:_topToolBarVC.view];
    [_structureToolBarView addSubviewFullFrame:_structureToolBarVC.view];
    [_propertyToolBarView addSubviewFullFrame:_propertyToolBarVC.view];
    
    //canvas
    [_canvasView addSubviewFullFrame:_canvasVC.view];
    
    //tab
    [_tabWidgetView addSubviewFullFrame:_widgetLibraryVC.view];
    [_tabPropertyView addSubviewFullFrame:_widgetPropertyVC.view];
    [_tabStyleView addSubviewFullFrame:_stylePropertyVC.view];
    [_tabImageView addSubviewFullFrame:_imagePropertyVC.view];
    [_tabActionView addSubviewFullFrame:_actionPropertyVC.view];
    [_tabEventView addSubviewFullFrame:_eventPropertyVC.view];
    [_tabLibraryView addSubviewFullFrame:_resourceLibraryVC.view];
    [_tabTracingView addSubviewFullFrame:_tracingPropertyVC.view];
    [_tabStructureView addSubviewFullFrame:_projectStructureVC.view];
    [_tabBackEndView addSubviewFullFrame:_backEndPropertyVC.view];
    
    
    //set CanvasVC
    [_mainWindow setCanvasVC:_canvasVC];
    [_propertyToolBarVC setJsManager:_canvasVC];
    [_imagePropertyVC setJsManager:_canvasVC];
    
    
    //add observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSheetSelection:) name:IUNotificationSheetSelectionDidChange object:nil];
    
    [self loadFirstPage];
    

}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDocument:(IUProjectDocument *)document{
    [super setDocument:document];
    if (document && document.project){
        _project = document.project;
        
        //allocation when project is set
        _pageController = [[IUSheetController alloc] initWithSheetGroup:_project.pageGroup];
        _classController = [[IUSheetController alloc] initWithSheetGroup:_project.classGroup];
        
        //load properties when project is set
        //view part
        [_widgetLibraryVC setWidgetNameList:[[_project class] widgetList]];
        
        //project
        [_sourceManager setProject:_project];
        
        [_topToolBarVC setProject:_project];
        [_actionPropertyVC setProject:_project];
        
        //sheet controllers
        [_projectStructureVC setPageController:_pageController];
        [_projectStructureVC setClassController:_classController];
        [_structureToolBarVC setPageController:_pageController];
        [_structureToolBarVC setClassController:_classController];
        
        //resource
        [_imagePropertyVC setResourceRootItem:document.resourceRootItem];
        [_resourceLibraryVC setResourceRootItem:document.resourceRootItem];
        [_tracingPropertyVC setResourceRootItem:document.resourceRootItem];
        
        //iucontroller
        [_canvasVC setController:_iuController];
        
        
        //set iudata is connected
        [document.undoManager disableUndoRegistration];
        
        [_project connectWithEditor];
        [_project setIsConnectedWithEditor];
        
        [document.undoManager enableUndoRegistration];
        
        [self loadFirstPage];
        
    }
    
}

/**
 load first page (mostly, index page)
 called twice by setDocument and viewDidLoad
 restoreDocument, makeNewDocument process is different
 restoreDocument : setDocument -> viewDidLoad
 makeNewDocument : viewDidLoad -> setDocument
 */
- (void)loadFirstPage{
    [_pageController setSelectedObject:_pageController.firstSheet];
}

#pragma mark - property Icon

- (IBAction)clickPropertyIconMatrix:(id)sender {
    
    BBPropertyTabType tabType = (int)[_propertyIconMatrix selectedRow];
    if([_propertyIconMatrix selectedRow] < 0){
        return;
    }
    if(tabType == _currentTabType){
        [_propertyIconMatrix deselectAllCells];
        _currentTabType = BBPropertyTabTypeNone;
        [self closePropertySettingTabView];
    }
    else{
        [_propertyIconMatrix selectCellAtRow:tabType column:1];
        _currentTabType = tabType;
        [self openPropertySettingTabViewForIndex:tabType];
    }
    
}

- (void)openPropertySettingTabViewForIndex:(int)index{
    [_propertySettingTabView selectTabViewItemAtIndex:index];
    [_propertySettingTabViewRightConstraint setConstant:37];
}
- (void)closePropertySettingTabView{
    [_propertySettingTabViewRightConstraint setConstant:(-241+38)];
}

#pragma mark - manage Sheets

- (void)changeSheetSelection:(NSNotification *)notification{
    
    id selectedObject = [notification.userInfo objectForKey:@"selectedObject"];
    if ([selectedObject isKindOfClass:[IUSheet class]] ){
        IUSheet *sheet = selectedObject;
        [_iuController setContent:sheet];
        [_iuController setSelectedObject:_iuController.firstDeepestBox];
        [self.sourceManager loadSheet:sheet];
        [_canvasVC setSheet:sheet];
        
        _currentSheet = sheet;
    }

}

- (void)reloadCurrentSheet:(id)sender{
    [self.sourceManager loadSheet:_currentSheet];
    [_canvasVC setSheet:_currentSheet];
}

#pragma mark -
- (NSString *)projectName{
    return _project.name;
}

#pragma mark - debug
#if DEBUG

- (IBAction)clickDebugButton:(id)sender {
    [_debugWC showCurrentSource:self];
}

#endif


@end
