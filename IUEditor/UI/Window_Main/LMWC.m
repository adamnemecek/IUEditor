//
//  LMWC.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMWC.h"
#import "LMWindow.h"

#import "IUSheetController.h"
#import "IUProject.h"
#import "IUSheetGroup.h"


#import "IUIdentifierManager.h"

#import "LMJSManager.h"


//connect VC
#import "LMAppearanceVC.h"
#import "LMResourceVC.h"
#import "LMClipArtVC.h"

#import "LMStackVC.h"
#import "LMWidgetLibraryVC.h"
#import "LMCanvasVC.h"
#import "LMEventVC.h"
#import "LMCommandVC.h"

#import "LMTopToolbarVC.h"
#import "LMBottomToolbarVC.h"
#import "LMIUPropertyVC.h"
#import "LMMediaQueryVC.h"

#import "IUDjangoProject.h"

#import "LMProjectConvertWC.h"
#import "IUProjectDocument.h"

#import "LMConsoleVC.h"
#import "LMProjectPropertyWC.h"

#import "LMServerWC.h"
#import "LMHerokuWC.h"

//connect new VC
#import "BBCommandVC.h"

@interface LMWC ()
//window toolbar
@property (weak) IBOutlet NSBox *buildToolbarBox;
@property (weak) IBOutlet NSImageView *selectionToolbarImageView;
@property (weak) IBOutlet NSTextField *selectionToolbarTF;
@property (weak) IBOutlet NSProgressIndicator *progressToolbarIndicator;
@property (weak) IBOutlet NSBox *mqBox;

//toolbar
@property (weak) IBOutlet NSView *topToolbarV;
@property (weak) IBOutlet NSView *bottomToolbarV;

//Left
@property (weak) IBOutlet NSLayoutConstraint *leftVConstraint;
@property (weak) IBOutlet NSSplitView *leftV;
@property (weak) IBOutlet NSView *leftTopV;
@property (weak) IBOutlet NSView *leftBottomV;

//Right-V
@property (weak) IBOutlet NSSplitView *rightV;
@property (weak) IBOutlet NSLayoutConstraint *rightVConstraint;

//Right-top
@property (weak) IBOutlet NSTabView *propertyTabV;
@property (weak) IBOutlet NSMatrix *propertyMatrix;
@property (weak) IBOutlet NSView *propertyV;
@property (weak) IBOutlet NSView *appearanceV;
@property (weak) IBOutlet NSView *eventV;

//Right-bottom
@property (weak) IBOutlet NSTabView *widgetTabV;
@property (weak) IBOutlet NSMatrix *clickWidgetTabMatrix;
@property (weak) IBOutlet NSView *widgetV;
@property (weak) IBOutlet NSView *resourceV;
@property (weak) IBOutlet NSView *clipartV;

//center
@property (weak) IBOutlet NSSplitView *centerSplitV;
@property (weak) IBOutlet NSView *centerV;
@property (weak) IBOutlet NSView *consoleV;

//server log
@property (weak) IBOutlet WebView *serverView;


@end

@implementation LMWC{
    IUProject   *_project;

    //VC for view
    //toolbar
    LMMediaQueryVC *mqVC;
    
    //left
    LMFileNaviVC    *fileNaviVC;
    LMStackVC       *stackVC;
    BBCommandVC     *commandVC;
    
    //center
    LMTopToolbarVC  *topToolbarVC;
    LMCanvasVC *canvasVC;
    LMConsoleVC *consoleVC;
    LMBottomToolbarVC     *bottomToolbarVC;

    //right top
    LMIUPropertyVC  *iuInspectorVC;
    LMAppearanceVC  *appearanceVC;
    LMEventVC       *eventVC;
    
    //right bottom
    LMWidgetLibraryVC   *widgetLibraryVC;
//    LMResourceVC    *resourceVC;
    LMClipArtVC     *clipArtVC;
    

    //sheet
    LMProjectConvertWC *pcWC;
    LMProjectPropertyWC *projectPropertyWC;
    LMServerWC *serverWC;
    LMHerokuWC *herokuWC;
    
    //view connecter
    //propertyVC -(get js result)- jsManager - canvasVC
    LMJSManager *jsManager;
    
    //log
    int consoleLogReferenceCount;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        //allocation
        stackVC = [[LMStackVC alloc] initWithNibName:@"LMStackVC" bundle:nil];
        fileNaviVC = [[LMFileNaviVC alloc] initWithNibName:@"LMFileNaviVC" bundle:nil];
        commandVC = [[BBCommandVC alloc] initWithNibName:[BBCommandVC class].className bundle:nil];
        canvasVC = [[LMCanvasVC alloc] initWithNibName:@"LMCanvasVC" bundle:nil];
        topToolbarVC = [[LMTopToolbarVC alloc] initWithNibName:@"LMTopToolbarVC" bundle:nil];
        bottomToolbarVC = [[LMBottomToolbarVC alloc] initWithNibName:@"LMBottomToolbarVC" bundle:nil];
        widgetLibraryVC = [[LMWidgetLibraryVC alloc] initWithNibName:@"LMWidgetLibraryVC" bundle:nil];
//        resourceVC = [[LMResourceVC alloc] initWithNibName:@"LMResourceVC" bundle:nil];
        clipArtVC = [[LMClipArtVC alloc] initWithNibName:@"LMClipArtVC" bundle:nil];
        appearanceVC = [[LMAppearanceVC alloc] initWithNibName:@"LMAppearanceVC" bundle:nil];
        iuInspectorVC = [[LMIUPropertyVC alloc] initWithNibName:[LMIUPropertyVC class].className bundle:nil];
        eventVC = [[LMEventVC alloc] initWithNibName:@"LMEventVC" bundle:nil];
        mqVC = [[LMMediaQueryVC alloc] initWithNibName:[LMMediaQueryVC class].className bundle:nil];
        mqVC.controller = canvasVC;

        
        //bind
        [self bind:@"IUController" toObject:stackVC withKeyPath:@"IUController" options:nil];
        [self bind:@"selectedNode" toObject:fileNaviVC withKeyPath:@"selection" options:nil];
        [self bind:@"documentController" toObject:fileNaviVC withKeyPath:@"documentController" options:nil];
    
        
        [canvasVC bind:@"controller" toObject:self withKeyPath:@"IUController" options:nil];
        [self bind:@"selectedTextRange" toObject:self withKeyPath:@"selectedTextRange" options:nil];
        [widgetLibraryVC bind:@"controller" toObject:self withKeyPath:@"IUController" options:nil];
        [appearanceVC bind:@"controller" toObject:self withKeyPath:@"IUController" options:nil];
        [iuInspectorVC bind:@"controller" toObject:self withKeyPath:@"IUController" options:nil];
        [eventVC bind:@"controller" toObject:self withKeyPath:@"IUController" options:nil];
        [topToolbarVC bind:@"sheetController" toObject:fileNaviVC withKeyPath:@"documentController" options:nil];
        [commandVC bind:@"docController" toObject:fileNaviVC withKeyPath:@"documentController" options:nil];

        
        
        //allocation JSManger
        jsManager = [[LMJSManager alloc] init];
        [jsManager setDelegate:canvasVC];
        
        //allocated jsmanager to VC (run js)
        [appearanceVC setJsManager:jsManager];

        
        //allocation sourcemanager
        _sourceManager = [[IUSourceManager alloc] init];
        [_sourceManager setCanvasVC:canvasVC];
        
        
        
        
    }
    return self;
}



- (void)windowDidLoad
{
    //consoleVC needs window to receive notification
    consoleVC = [[LMConsoleVC alloc] initWithNibName:@"LMConsoleVC" bundle:nil window:self.window];

    //window - toolbar
    [_buildToolbarBox addSubviewFullFrame:commandVC.view];
    [_mqBox addSubviewFullFrame:mqVC.view];
    
    //left-view
    [_leftTopV addSubviewFullFrame:stackVC.view];
    [_leftBottomV addSubviewFullFrame:fileNaviVC.view];

    
    ////////////////center view/////////////////////////
    [_centerV addSubviewFullFrame:canvasVC.view];
    
    
    [_topToolbarV addSubviewFullFrame:topToolbarVC.view];
    [_bottomToolbarV addSubviewFullFrame:bottomToolbarVC.view];
    [_consoleV addSubviewFullFrame:consoleVC.view];
    
    ////////////////right view/////////////////////////
    [_widgetV addSubviewFullFrame:widgetLibraryVC.view];
   // [_resourceV addSubviewFullFrame:resourceVC.view];
    [_clipartV addSubviewFullFrame:clipArtVC.view];
    
    [_appearanceV addSubviewFullFrame:appearanceVC.view];
    [_propertyV addSubviewFullFrame:iuInspectorVC.view];
    [_eventV addSubviewFullFrame:eventVC.view];
    

    // console log
    [self setLogViewState:0];
    
    //notification observer default
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseConsoleLogReferenceCount) name:IUNotificationConsoleStart object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decreaseConsoleLogReferenceCount) name:IUNotificationConsoleEnd object:self.window];
    
    //observer
    [_IUController addObserver:self forKeyPath:@"selectedObjects" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionPrior context:nil];

    
    
    //cell initialize
    NSCell *cell = [self.propertyMatrix cellAtRow:0 column:0];
    [self.propertyMatrix setToolTip:@"Appearance" forCell:cell];
    
    NSCell *cell2 = [self.propertyMatrix cellAtRow:0 column:1];
    [self.propertyMatrix setToolTip:@"Property" forCell:cell2];
    
    NSCell *cell3 = [self.propertyMatrix cellAtRow:0 column:2];
    [self.propertyMatrix setToolTip:@"Event" forCell:cell3];
    
    
    NSCell *cell7 = [self.clickWidgetTabMatrix cellAtRow:0 column:0];
    [self.clickWidgetTabMatrix setToolTip:@"Primary Widget" forCell:cell7];
    
    NSCell *cell8 = [self.clickWidgetTabMatrix cellAtRow:0 column:1];
    [self.clickWidgetTabMatrix setToolTip:@"Secondary Widget" forCell:cell8];
    
#if DEBUG
#else
    [[_serverView mainFrame] loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://server.iueditor.org/log.html"]]];
#endif
    
//    [stackVC setNotificationSender:_project];
//    [stackVC connectWithEditor];
    
    //load mq
    [mqVC loadWithMQWidths:_project.mqSizes];
    
    
}


- (void)prepareDealloc{
    [self unbind:@"IUController"];
    [self unbind:@"selectedNode"];
    [self unbind:@"documentController"];
    [self unbind:@"selectedTextRange"];
    
    [commandVC unbind:@"docController"];
    [canvasVC unbind:@"controller"];
    [widgetLibraryVC unbind:@"controller"];
    [appearanceVC unbind:@"controller"];
    [iuInspectorVC unbind:@"controller"];
    [topToolbarVC unbind:@"sheetController"];

    [canvasVC prepareDealloc];
//    [commandVC prepareDealloc];
    [iuInspectorVC prepareDealloc];
    [appearanceVC prepareDealloc];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IUNotificationConsoleStart object:self.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IUNotificationConsoleEnd object:self.window];

}


-(LMWindow*)window{
    return (LMWindow*)[super window];
}

- (void)setDocument:(IUProjectDocument *)document{
    //create project class
    [super setDocument:document];
    
    
    
    //document == nil means window will be closed
    if(document && document.project){
        
        //project error check
        _project = document.project;
        NSAssert(_project.pageGroup.childrenFileItems, @"");
        

        if (_project == nil) {
            return;
        }
        
        //project binding
        [canvasVC bind:@"documentBasePath" toObject:self withKeyPath:@"document.project.path" options:nil];

        
        //undo manager
        _IUController.undoManager = [document undoManager];
        
              
        //set project
        fileNaviVC.project = _project;
        widgetLibraryVC.project = _project;
        iuInspectorVC.project = _project;
        [_sourceManager setProject:_project];
        
        
        [document.undoManager disableUndoRegistration];
        
        [_project connectWithEditor];
        [_project setIsConnectedWithEditor];
        
        [document.undoManager enableUndoRegistration];
    
        
    }
}

- (void)reloadNavigation{
    [fileNaviVC reloadNavigation];
}

- (NSString *)projectName{
    return _project.name;
}

- (void)selectFirstDocument{
    [fileNaviVC selectFirstDocument];
}


#pragma mark - constraint

- (void)setLeftInspectorState:(NSInteger)state{
    [_leftV setHidden:!state];
    if(state){
        [_leftVConstraint setConstant:0];
    }
    else{
        [_leftVConstraint setConstant:-220];
    }
}

- (void)setRightInspectorState:(NSInteger)state{
    [_rightV setHidden:!state];
    
    if(state){
        [_rightVConstraint setConstant:0];
    }
    else{
        [_rightVConstraint setConstant:-300];
    }
}



#pragma mark - console

- (void)increaseConsoleLogReferenceCount{
    consoleLogReferenceCount ++;
    [self setLogViewState:consoleLogReferenceCount];
}

- (void)decreaseConsoleLogReferenceCount{
    consoleLogReferenceCount --;
    [self setLogViewState:consoleLogReferenceCount];
}

- (void)setLogViewState:(NSInteger)state{
    
    CGFloat height = [_centerSplitV bounds].size.height;

    if(state){
        CGFloat lastPosition = [[NSUserDefaults standardUserDefaults] doubleForKey:@"LastConsolePosition"];
        if (lastPosition == 0) {
            lastPosition = 50;
        }
       [_centerSplitV setPosition:height-lastPosition ofDividerAtIndex:0];
    }
    else{
        CGFloat position = _consoleV.frame.size.height;
        [[NSUserDefaults standardUserDefaults] setDouble:position forKey:@"LastConsolePosition"];
        [_centerSplitV setPosition:height ofDividerAtIndex:0];
    }
}

#pragma mark - node change

-(void)setSelectedNode:(NSObject*)selectedNode{
    _selectedNode = (IUSheet*) selectedNode;
    if ([selectedNode isKindOfClass:[IUSheet class]]) {
        
        [self.sourceManager loadSheet:(IUSheet *)selectedNode];
        
//        [stackVC setSheet:_selectedNode];
        [canvasVC setSheet:_selectedNode];
        [bottomToolbarVC setSheet:_selectedNode];
        [topToolbarVC setSheet:_selectedNode];
        
        //save for debug
        /*
        //remove this line : saving can't not in the package
        NSString *documentSavePath = [canvasVC.documentBasePath stringByAppendingPathComponent:[_selectedNode.name stringByAppendingPathExtension:@"html"]];
        [_selectedNode.editorSource writeToFile:documentSavePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
         */


        return;
    }
    else if ([selectedNode isKindOfClass:[IUProject class]]){
        return;
    }
    else if ([selectedNode isKindOfClass:[IUSheetGroup class]]){
        return;
    }
}

- (IBAction)reloadCurrentDocument:(id)sender{
    [self.sourceManager loadSheet:(IUSheet *)_selectedNode];
}


- (void)performDoubleClick:(NSNotification*)noti{
    [_propertyTabV selectTabViewItemAtIndex:1];
    [_propertyMatrix selectCellAtRow:0 column:1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [iuInspectorVC setFocusForDoubleClickAction];
    });
}


-(void)selectedObjectsDidChange:(NSDictionary*)change{
    [_selectionToolbarImageView setImage:[[[_IUController.selectedObjects firstObject] class] navigationImage]];
    
    NSString *currentIdentifier;
    if(_IUController.selectedObjects.count > 1){
        currentIdentifier = @"Multiple Selection";
    }
    else{
#if DEBUG
        currentIdentifier = ((IUBox *)[_IUController.selectedObjects firstObject]).htmlID;
#else
        currentIdentifier = ((IUBox *)[_IUController.selectedObjects firstObject]).name;
#endif
    }
    
    NSString *currentClassName = [_IUController selectionClassName];
    NSString *status = [NSString stringWithFormat:@"%@ | %@", currentClassName, currentIdentifier];
    
    [_selectionToolbarTF setStringValue:status];
    [_selectionToolbarTF sizeToFit];
}
- (IUSheet *)currentSheet{
    if ([_selectedNode isKindOfClass:[IUSheet class]]) {
        return _selectedNode;
    }
    
    return nil;
}


#pragma mark - select TabView


- (IBAction)clickPropertyMatrix:(id)sender {
    NSMatrix *propertyMatrix = sender;
    NSInteger index = [propertyMatrix selectedColumn];
    
    [_propertyTabV selectTabViewItemAtIndex:index];
}
- (IBAction)clickWidgetMatrix:(id)sender {
    NSMatrix *propertyMatrix = sender;
    NSInteger index = [propertyMatrix selectedColumn];
    
    [_widgetTabV selectTabViewItemAtIndex:index];

}

#pragma mark - window
- (void)windowWillClose:(NSNotification *)notification{
    if([_project isKindOfClass:[IUDjangoProject class]]){
        [commandVC stopServer:self];
    }
}

- (void)windowDidResize:(NSNotification *)notification{
    [canvasVC windowDidResize:notification];
}

#pragma mark - tool-bar action

-(void)setProgressBarValue:(CGFloat)value{
    [_progressToolbarIndicator setDoubleValue:value];
}

-(void)stopProgressBar:(id)sender{
    [_progressToolbarIndicator setDoubleValue:100.0];
    [_progressToolbarIndicator stopAnimation:sender];
    [_progressToolbarIndicator setHidden:YES];
}


#pragma mark - Sheet

- (IBAction)convertProject:(id)sender{
    //call from menu item
    pcWC = [[LMProjectConvertWC alloc] initWithWindowNibName:@"LMProjectConvertWC"];
    pcWC.currentProject = _project;
    
    [self.window beginSheet:pcWC.window completionHandler:^(NSModalResponse returnCode) {
        switch (returnCode) {
            case NSModalResponseOK:
                [self close];
                break;
            case NSModalResponseAbort:
            default:
                break;
        }
    }];
}

- (IBAction)openProjectPropertyWindow:(id)sender {

    if(projectPropertyWC == nil){
        projectPropertyWC = [[LMProjectPropertyWC alloc] initWithWindowNibName:[LMProjectPropertyWC class].className withIUProject:_project];
    }
    
    [self.window beginSheet:projectPropertyWC.window completionHandler:^(NSModalResponse returnCode) {
        //do nothing
    }];
}


- (IBAction)showServerWC:(id)sender{
    if (serverWC == nil) {
        serverWC = [[LMServerWC alloc] initWithWindowNibName:@"LMServerWC"];
        [serverWC setNotificationSender:self.window];
        [serverWC setProject:_project];
    }
    
    [self.window beginSheet:serverWC.window completionHandler:^(NSModalResponse returnCode) {
        //do nothing
    }];
}


- (IBAction)showHerokuWC:(id)sender{
    if (herokuWC == nil) {
        herokuWC = [[LMHerokuWC alloc] initWithWindowNibName:@"LMHerokuWC"];
        NSString *absoluteBuildPath = [_project absoluteBuildPath];
        [herokuWC setGitRepoPath:absoluteBuildPath];
    }
    
    [self.window beginSheet:herokuWC.window completionHandler:^(NSModalResponse returnCode) {
        //do nothing
    }];
    
}

- (void)windowWillBeginSheet:(NSNotification *)notification{
    if(herokuWC){
        [herokuWC willBeginSheet:notification];
    }
}

- (IBAction)cleanBuild:(id)sender{
    NSDirectoryEnumerator* en = [[NSFileManager defaultManager] enumeratorAtPath:_project.absoluteBuildPath];
    BOOL res;
    
    NSString* file;
    while (file = [en nextObject]) {
        if ([[file lastPathComponent] characterAtIndex:0] == '.') {
            //skip hidden file
            continue;
        }
        NSError *err;
        res = [[NSFileManager defaultManager] trashItemAtURL:[NSURL fileURLWithPath:[_project.absoluteBuildPath stringByAppendingPathComponent:file]] resultingItemURL:nil error:&err];
        NSAssert(res, @"error");
    }
}

- (IBAction)build:(id)sender{
    [commandVC build:sender];
}


- (IBAction)zoomIn:(id)sender
{
    [canvasVC zoomIn];
}


- (IBAction)zoomOut:(id)sender
{
    [canvasVC zoomOut];
}

- (IBAction)showOutline:(id)sender{
    [bottomToolbarVC clickBorderBtn:sender];
}
@end
