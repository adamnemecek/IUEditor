//
//  BBPropertyToolBarVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBPropertyToolBarVC.h"
#import "IUFontController.h"

@interface BBPropertyToolBarVC ()

//iubox frame property
@property (weak) IBOutlet NSTextField *xTextField;
@property (weak) IBOutlet NSTextField *yTextField;
@property (weak) IBOutlet NSTextField *wTextField;
@property (weak) IBOutlet NSTextField *hTextField;

@property (weak) IBOutlet NSStepper *xStepper;
@property (weak) IBOutlet NSStepper *yStepper;
@property (weak) IBOutlet NSStepper *wStepper;
@property (weak) IBOutlet NSStepper *hStepper;

@property (weak) IBOutlet NSButton *xUnitButton;
@property (weak) IBOutlet NSButton *yUnitButton;
@property (weak) IBOutlet NSButton *wUnitButton;
@property (weak) IBOutlet NSButton *hUnitButton;

//iubox center
@property (weak) IBOutlet NSButton *verticalCenterButton;
@property (weak) IBOutlet NSButton *horizontalCenterButton;

//iubox bg
@property (weak) IBOutlet NSColorWell *bgColorWell;

//iutext property
@property (weak) IBOutlet NSComboBox *fontNameComboBox;
@property (weak) IBOutlet NSPopUpButton *fontWeightPopUpButton;
@property (weak) IBOutlet NSMenuItem *lightWeigtMenuItem;
@property (weak) IBOutlet NSComboBox *fontSizeComboBox;
@property (weak) IBOutlet NSColorWell *fontColorWell;
@property (weak) IBOutlet NSSegmentedControl *fontAlignSegmentedControl;

//font controller
@property (weak) IUFontController *fontController;

//popover outlet
@property (weak) IBOutlet NSButton *extendedFrameButton;
@property (strong) IBOutlet NSPopover *framePopover;
@property (weak) IBOutlet NSTextField *minWidthTextField;
@property (weak) IBOutlet NSTextField *minHeightTextField;

@end

@implementation BBPropertyToolBarVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        _fontController = [IUFontController sharedFontController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //default binding
    
    
    //frame
    [self outlet:_xTextField bind:NSValueBinding cascadingPositionStorageProperty:@"x" options:@{NSNullPlaceholderBindingOption:@"-", NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];
    [self outlet:_yTextField bind:NSValueBinding cascadingPositionStorageProperty:@"y" options:@{NSNullPlaceholderBindingOption:@"-", NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];
    [self outlet:_wTextField bind:NSValueBinding cascadingStyleStorageProperty:@"width" options:@{NSNullPlaceholderBindingOption:@"-", NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];
    [self outlet:_hTextField bind:NSValueBinding cascadingStyleStorageProperty:@"height" options:@{NSNullPlaceholderBindingOption:@"-", NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];
    
    [self outlet:_xStepper bind:NSValueBinding cascadingPositionStorageProperty:@"x"];
    [self outlet:_yStepper bind:NSValueBinding cascadingPositionStorageProperty:@"y"];
    [self outlet:_wStepper bind:NSValueBinding cascadingStyleStorageProperty:@"width"];
    [self outlet:_hStepper bind:NSValueBinding cascadingStyleStorageProperty:@"height"];

    
    [self outlet:_verticalCenterButton bind:NSValueBinding property:@"enableVCenter"];
    [self outlet:_horizontalCenterButton bind:NSValueBinding property:@"enableHCenter"];
    
    //bg color
    [self outlet:_bgColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"bgColor1"];
    
    //text binding
    [self outlet:_fontNameComboBox bind:NSValueBinding cascadingStyleStorageProperty:@"fontName" options:@{NSNullPlaceholderBindingOption:@"-", NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];
    [self outlet:_fontWeightPopUpButton bind:NSSelectedIndexBinding cascadingStyleStorageProperty:@"fontWeight" options:@{NSNullPlaceholderBindingOption:@(1), NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];

    [self outlet:_fontSizeComboBox bind:NSValueBinding cascadingStyleStorageProperty:@"fontSize" options:@{NSNullPlaceholderBindingOption:@"-", NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];
    [self outlet:_fontColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"fontColor"];
    [self outlet:_fontAlignSegmentedControl bind:NSSelectedIndexBinding cascadingStyleStorageProperty:@"fontAlign"];
    
    //popover
    [self outlet:_minWidthTextField bind:NSValueBinding cascadingStyleStorageProperty:@"minWidth"];
    [self outlet:_minHeightTextField bind:NSValueBinding cascadingStyleStorageProperty:@"minHeight"];
    
    
}

- (void)dealloc{
    JDSectionInfoLog(IULogDealloc, @"");
}



#pragma mark - ibaction

- (IBAction)clickUnitButton:(id)sender {
    NSButton *clickedUnitButton = sender;
    //change from pixel to percent
    if([clickedUnitButton state] == NSOnState){
        
        for(IUBox *box in self.iuController.selectedObjects){
            NSRect percentFrame = [self.jsManager percentFrameForIdentifier:box.htmlID];
            [box.cascadingPositionStorage beginTransaction:self];
            [box.cascadingStyleStorage beginTransaction:self];


            if([sender isEqualTo:_xUnitButton]){
                [box.cascadingPositionStorage setX:@(percentFrame.origin.x) unit:@(IUFrameUnitPercent)];
            }
            else if([sender isEqualTo:_yUnitButton]){
                [box.cascadingPositionStorage setY:@(percentFrame.origin.y) unit:@(IUFrameUnitPercent)];
            }
            else if([sender isEqualTo:_wUnitButton]){
                [box.cascadingStyleStorage setWidth:@(percentFrame.size.width) unit:@(IUFrameUnitPercent)];
            }
            else if([sender isEqualTo:_hUnitButton]){
                [box.cascadingStyleStorage setHeight:@(percentFrame.size.height) unit:@(IUFrameUnitPercent)];
            }
            
            [box.cascadingStyleStorage commitTransaction:self];
            [box.cascadingPositionStorage commitTransaction:self];
        }
    }
    //change from percent to pixel
    else{
        for(IUBox *box in self.iuController.selectedObjects){
            NSRect pixelFrame = [self.jsManager pixelFrameForIdentifier:box.htmlID];
            [box.cascadingPositionStorage beginTransaction:self];
            [box.cascadingStyleStorage beginTransaction:self];
            
            
            if([sender isEqualTo:_xUnitButton]){
                [box.cascadingPositionStorage setX:@(pixelFrame.origin.x) unit:@(IUFrameUnitPixel)];
            }
            else if([sender isEqualTo:_yUnitButton]){
                [box.cascadingPositionStorage setY:@(pixelFrame.origin.y) unit:@(IUFrameUnitPixel)];
            }
            else if([sender isEqualTo:_wUnitButton]){
                [box.cascadingStyleStorage setWidth:@(pixelFrame.size.width) unit:@(IUFrameUnitPixel)];
            }
            else if([sender isEqualTo:_hUnitButton]){
                [box.cascadingStyleStorage setHeight:@(pixelFrame.size.height) unit:@(IUFrameUnitPixel)];
            }
            
            [box.cascadingStyleStorage commitTransaction:self];
            [box.cascadingPositionStorage commitTransaction:self];
        }
    }
}

- (IBAction)clickNilBgColorButton:(id)sender {
    [self.cascadingStyleStorage beginTransaction:self];
    self.cascadingStyleStorage.bgColor1 = nil;
    [self.cascadingStyleStorage commitTransaction:self];
}

- (IBAction)clickFontNameComboBox:(id)sender {
    NSString *fontName = [_fontNameComboBox stringValue];
    [self updateFontWeigtWithFontName:fontName];
}

- (void)updateFontWeigtWithFontName:(NSString *)fontName{
    BOOL hasLightWeigt = [_fontController hasLight:fontName];
    if(hasLightWeigt){
        [_lightWeigtMenuItem setEnabled:YES];
    }
    else{
        [_lightWeigtMenuItem setEnabled:NO];
    }
    
}

- (IBAction)clickFramePopoverButton:(id)sender {
    if([_framePopover isShown]){
        [_framePopover close];
    }
    else{
        [_framePopover showRelativeToRect:[_extendedFrameButton frame] ofView:self.view preferredEdge:NSMinYEdge];
    }

}
- (IBAction)clickFramePopoverCloseButton:(id)sender {
    if([_framePopover isShown]){
        [_framePopover close];
    }
}
- (IBAction)clickRemoveWidthButton:(id)sender {
    [self.cascadingStyleStorage beginTransaction:self];
    self.cascadingStyleStorage.width = nil;
    [self.cascadingStyleStorage commitTransaction:self];

}
- (IBAction)clickRemoveHeightButton:(id)sender {
    [self.cascadingStyleStorage beginTransaction:self];
    self.cascadingStyleStorage.height = nil;
    [self.cascadingStyleStorage commitTransaction:self];
}

@end
