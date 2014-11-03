//
//  LMToolbarVC.m
//  IUEditor
//
//  Created by jd on 3/31/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMBottomToolbarVC.h"
#import "LMTutorialManager.h"
#import "LMHelpPopover.h"
#import "LMWC.h"
#import "LMHelpWC.h"

@interface LMBottomToolbarVC ()

@property (weak) IBOutlet NSComboBox *ghostImageComboBox;
@property (weak) IBOutlet NSButton *ghostBtn;
@property (weak) IBOutlet NSTextField *ghostXTF;
@property (weak) IBOutlet NSTextField *ghostYTF;
@property (weak) IBOutlet NSSlider *opacitySlider;


@property (weak) IBOutlet NSButton *refreshBtn;
@property (weak) IBOutlet NSButton *leftInspectorBtn;
@property (weak) IBOutlet NSButton *rightInspectorBtn;
@property (weak) IBOutlet NSButton *logBtn;
@property (weak) IBOutlet NSButton *borderBtn;
@property (weak) IBOutlet NSButton *mailBtn;

@property (weak) IBOutlet NSComboBox *zoomComboBox;

@end

@implementation LMBottomToolbarVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [self loadView];
    }
    return self;
}

- (void)awakeFromNib{
#pragma mark ghost
    
    _ghostImageComboBox.delegate = self;
    [_ghostBtn bind:@"state" toObject:[NSUserDefaults standardUserDefaults] withKeyPath:@"showGhost" options:nil];
    
    [_ghostImageComboBox bind:NSEnabledBinding toObject:[NSUserDefaults standardUserDefaults]  withKeyPath:@"showGhost" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    [_ghostXTF bind:NSEnabledBinding toObject:[NSUserDefaults standardUserDefaults]  withKeyPath:@"showGhost" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    [_ghostYTF bind:NSEnabledBinding toObject:[NSUserDefaults standardUserDefaults]  withKeyPath:@"showGhost" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    
    [_ghostImageComboBox bind:NSContentBinding toObject:self withKeyPath:@"resourceManager.imageFiles" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    [_ghostXTF bind:NSValueBinding toObject:self withKeyPath:@"sheet.ghostX" options:IUBindingDictNumberAndNotRaisesApplicable];
    [_ghostYTF bind:NSValueBinding toObject:self withKeyPath:@"sheet.ghostY" options:IUBindingDictNumberAndNotRaisesApplicable];
    [_opacitySlider bind:NSValueBinding toObject:self withKeyPath:@"sheet.ghostOpacity" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    
    
#pragma mark bottom right tools
    [self addObserver:self forKeyPath:@"sheet.ghostImageName" options:0 context:nil];
    _ghostImageComboBox.delegate = self;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"showLeftInspector"] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"showLeftInspector"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"showRightInspector"] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"showRightInspector"];
    }
    

//initialize
    BOOL showBorder = [[NSUserDefaults standardUserDefaults] boolForKey:@"showBorder"];
    [_borderBtn setState:showBorder];
    
    BOOL showLeftInspector = [[NSUserDefaults standardUserDefaults] boolForKey:@"showLeftInspector"];
    [_leftInspectorBtn setState:showLeftInspector];
    
    BOOL showRightInspector = [[NSUserDefaults standardUserDefaults] boolForKey:@"showRightInspector"];
    [_rightInspectorBtn setState:showRightInspector];
    
}

-(void) dealloc{
    [JDLogUtil log:IULogDealloc string:@"BottomToolBar"];
    [self removeObserver:self forKeyPath:@"sheet.ghostImageName"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"sheet.ghostImageName"]){
        if ([[_ghostImageComboBox stringValue] isEqualToString:_sheet.ghostImageName] == NO) {
            if (_sheet.ghostImageName == nil) {
                [_ghostImageComboBox setStringValue:@""];
            }
            else {
                [_ghostImageComboBox setStringValue:_sheet.ghostImageName];
            }
        }
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)comboBoxSelectionDidChange:(NSNotification *)notification{
    
    NSComboBox *comboBox = notification.object;
    if([comboBox isEqualTo:_ghostImageComboBox]){
        
        NSString *fileName = [_ghostImageComboBox objectValueOfSelectedItem];
        if(fileName == nil){
            [_ghostImageComboBox selectItemWithObjectValue:self.sheet.ghostImageName];
        }
        else{
            self.sheet.ghostImageName = fileName;
        }
    }
}



- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    NSString *fileName = [control stringValue];
    self.sheet.ghostImageName = fileName;
    return YES;
}



- (void)setResourceManager:(IUResourceManager *)resourceManager{
    _resourceManager = resourceManager;
}


#pragma mark - bottom tool


- (IBAction)clickBorderBtn:(id)sender {
    BOOL showBorder = [[NSUserDefaults standardUserDefaults] boolForKey:@"showBorder"];
    [[NSUserDefaults standardUserDefaults] setBool:!showBorder forKey:@"showBorder"];
}
- (IBAction)clickGhostBtn:(NSButton*)sender {
    //show tutorial if needed
    BOOL showGhost = [[NSUserDefaults standardUserDefaults] boolForKey:@"showGhost"];
    [[NSUserDefaults standardUserDefaults] setBool:!showGhost forKey:@"showGhost"];
}
- (IBAction)clickRefreshBtn:(id)sender {
    LMWC *lmWC = [NSApp mainWindow].windowController;
    [lmWC reloadCurrentDocument:self];
}

- (IBAction)toggleLeftInspector:(id)sender {
    LMWC *lmWC = [NSApp mainWindow].windowController;
    NSInteger state = [_leftInspectorBtn state];
    [lmWC setLeftInspectorState:state];

}
- (IBAction)toggleRightInspector:(id)sender {
    
    LMWC *lmWC = [NSApp mainWindow].windowController;
    NSInteger state = [_rightInspectorBtn state];
    [lmWC setRightInspectorState:state];
    
}

- (void)setConsoleViewEnable:(BOOL)enable{
    [_logBtn setEnabled:enable];
}
- (IBAction)toggleLogView:(id)sender {
    LMWC *lmWC = [NSApp mainWindow].windowController;
    NSInteger state = [_logBtn state];
    [lmWC setLogViewState:state];

}

#pragma mark - mail

- (IBAction)clickEmailBtn:(id)sender {
    NSString *url = [IUEmail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[NSWorkspace sharedWorkspace]  openURL:[NSURL URLWithString:url]];
}

@end
