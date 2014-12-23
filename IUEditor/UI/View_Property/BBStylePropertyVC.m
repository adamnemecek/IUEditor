//
//  BBStylePropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBStylePropertyVC.h"
#import "BBExpandableView.h"

@interface BBStylePropertyVC ()

/* table view */
@property (weak) IBOutlet NSTableView *styleTableView;

/* table row view */
@property (strong) IBOutlet BBExpandableView *colorView;
@property (strong) IBOutlet BBExpandableView *radiusView;
@property (strong) IBOutlet BBExpandableView *borderView;
@property (strong) IBOutlet NSView *shadowView;

/* property outlet */
/* color */
@property (weak) IBOutlet NSColorWell *bgColorWell;

@property (weak) IBOutlet NSButton *gradientCheckButton;
@property (weak) IBOutlet NSColorWell *gradientStartColor;
@property (weak) IBOutlet NSColorWell *gradientEndColor;
@property (weak) IBOutlet NSSegmentedControl *gradientDirectionSegmentedControl;

/* radius */
@property (weak) IBOutlet NSSlider *radiusSlider;
@property (weak) IBOutlet NSTextField *radiusTextField;
@property (weak) IBOutlet NSStepper *radiusStepper;

@property (weak) IBOutlet NSSlider *topLeftRadiusSlider;
@property (weak) IBOutlet NSTextField *topLeftRadiusTextField;
@property (weak) IBOutlet NSStepper *topLeftRadiusStepper;

@property (weak) IBOutlet NSSlider *topRightRadiusSlider;
@property (weak) IBOutlet NSTextField *topRightRadiusTextField;
@property (weak) IBOutlet NSStepper *topRightRadiusStepper;

@property (weak) IBOutlet NSSlider *bottomLeftRadiusSlider;
@property (weak) IBOutlet NSTextField *bottomLeftRadiusTextField;
@property (weak) IBOutlet NSStepper *bottomLeftRadiusStepper;

@property (weak) IBOutlet NSSlider *bottomRightRadiusSlider;
@property (weak) IBOutlet NSTextField *bottomRightRadiusTextField;
@property (weak) IBOutlet NSStepper *bottomRightRadiusStepper;

/* border */
@property (weak) IBOutlet NSPopUpButton *borderTypePopupButton;
@property (weak) IBOutlet NSColorWell *borderColorWell;
@property (weak) IBOutlet NSTextField *borderSizeTextField;
@property (weak) IBOutlet NSStepper *borderSizeStepper;

@property (weak) IBOutlet NSColorWell *topBorderColorWell;
@property (weak) IBOutlet NSTextField *topBorderSizeTextField;
@property (weak) IBOutlet NSStepper *topBorderSizeStepper;

@property (weak) IBOutlet NSColorWell *leftBorderColorWell;
@property (weak) IBOutlet NSTextField *leftBorderSizeTextField;
@property (weak) IBOutlet NSStepper *leftBorderSizeStepper;

@property (weak) IBOutlet NSColorWell *bottomBorderColorWell;
@property (weak) IBOutlet NSTextField *bottomBorderSizeTextField;
@property (weak) IBOutlet NSStepper *bottomBorderSizeStepper;

@property (weak) IBOutlet NSColorWell *rightBorderColorWell;
@property (weak) IBOutlet NSTextField *rightBorderSizeTextField;
@property (weak) IBOutlet NSStepper *rightBorderSizeStepper;

/* shadow */
@property (weak) IBOutlet NSColorWell *shadowColorWell;

@property (weak) IBOutlet NSSlider *shadowColorVerticalSlider;
@property (weak) IBOutlet NSTextField *shadowColorVerticalTextField;
@property (weak) IBOutlet NSStepper *shadowColorVerticalStepper;

@property (weak) IBOutlet NSSlider *shadowColorHorizontalSlider;
@property (weak) IBOutlet NSTextField *shadowColorHorizontalTextField;
@property (weak) IBOutlet NSStepper *shadowColorHorizontalStepper;

@property (weak) IBOutlet NSSlider *shadowColorSpreadSlider;
@property (weak) IBOutlet NSTextField *shadowColorSpreadTextField;
@property (weak) IBOutlet NSStepper *shadowColorSpreadStepper;

@property (weak) IBOutlet NSSlider *shadowColorBlurSlider;
@property (weak) IBOutlet NSTextField *shadowColorBlurTextField;
@property (weak) IBOutlet NSStepper *shadowColorBlurStepper;


@end

@implementation BBStylePropertyVC{
    NSArray *_childrenViewArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _childrenViewArray = @[_colorView, _radiusView, _borderView, _shadowView];
    
    
    /* binding */
    /* bg */
    [self outlet:_bgColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"bgColor1"];
    [self outlet:_gradientStartColor bind:NSValueBinding cascadingStyleStorageProperty:@"bgColor1"];
    [self outlet:_gradientEndColor bind:NSValueBinding cascadingStyleStorageProperty:@"bgColor2"];
    [self outlet:_gradientDirectionSegmentedControl bind:NSSelectedIndexBinding cascadingStyleStorageProperty:@"bgColorDirection"];
    
    /* radius */
    [self outlet:_radiusSlider bind:NSValueBinding cascadingStyleStorageProperty:@"borderRadius"];
    [self outlet:_radiusTextField bind:NSValueBinding cascadingStyleStorageProperty:@"borderRadius"];
    [self outlet:_radiusStepper bind:NSValueBinding cascadingStyleStorageProperty:@"borderRadius"];
    
    [self outlet:_topLeftRadiusSlider bind:NSValueBinding cascadingStyleStorageProperty:@"topLeftBorderRadius"];
    [self outlet:_topLeftRadiusTextField bind:NSValueBinding cascadingStyleStorageProperty:@"topLeftBorderRadius"];
    [self outlet:_topLeftRadiusStepper bind:NSValueBinding cascadingStyleStorageProperty:@"topLeftBorderRadius"];

    [self outlet:_topRightRadiusSlider bind:NSValueBinding cascadingStyleStorageProperty:@"topRightBorderRadius"];
    [self outlet:_topRightRadiusTextField bind:NSValueBinding cascadingStyleStorageProperty:@"topRightBorderRadius"];
    [self outlet:_topRightRadiusStepper bind:NSValueBinding cascadingStyleStorageProperty:@"topRightBorderRadius"];
    
    [self outlet:_bottomLeftRadiusSlider bind:NSValueBinding cascadingStyleStorageProperty:@"bottomLeftborderRadius"];
    [self outlet:_bottomLeftRadiusTextField bind:NSValueBinding cascadingStyleStorageProperty:@"bottomLeftborderRadius"];
    [self outlet:_bottomLeftRadiusStepper bind:NSValueBinding cascadingStyleStorageProperty:@"bottomLeftborderRadius"];

    [self outlet:_bottomRightRadiusSlider bind:NSValueBinding cascadingStyleStorageProperty:@"bottomRightBorderRadius"];
    [self outlet:_bottomRightRadiusTextField bind:NSValueBinding cascadingStyleStorageProperty:@"bottomRightBorderRadius"];
    [self outlet:_bottomRightRadiusStepper bind:NSValueBinding cascadingStyleStorageProperty:@"bottomRightBorderRadius"];
    
    /* border */
    [self outlet:_borderColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"borderColor"];
    [self outlet:_borderSizeTextField bind:NSValueBinding cascadingStyleStorageProperty:@"borderWidth"];
    [self outlet:_borderSizeStepper bind:NSValueBinding cascadingStyleStorageProperty:@"borderWidth"];

    [self outlet:_topBorderColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"topBorderColor"];
    [self outlet:_topBorderSizeTextField bind:NSValueBinding cascadingStyleStorageProperty:@"topBorderWidth"];
    [self outlet:_topBorderSizeStepper bind:NSValueBinding cascadingStyleStorageProperty:@"topBorderWidth"];

    [self outlet:_leftBorderColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"leftBorderColor"];
    [self outlet:_leftBorderSizeTextField bind:NSValueBinding cascadingStyleStorageProperty:@"leftBorderWidth"];
    [self outlet:_leftBorderSizeStepper bind:NSValueBinding cascadingStyleStorageProperty:@"leftBorderWidth"];

    [self outlet:_rightBorderColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"rightBorderColor"];
    [self outlet:_rightBorderSizeTextField bind:NSValueBinding cascadingStyleStorageProperty:@"rightBorderWidth"];
    [self outlet:_rightBorderSizeStepper bind:NSValueBinding cascadingStyleStorageProperty:@"rightBorderWidth"];

    [self outlet:_bottomBorderColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"bottomBorderColor"];
    [self outlet:_bottomBorderSizeTextField bind:NSValueBinding cascadingStyleStorageProperty:@"bottomBorderWidth"];
    [self outlet:_bottomBorderSizeStepper bind:NSValueBinding cascadingStyleStorageProperty:@"bottomBorderWidth"];
    
    /* shadow */
    [self outlet:_shadowColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"shadowColor"];
    
    [self outlet:_shadowColorVerticalSlider bind:NSValueBinding cascadingStyleStorageProperty:@"shadowColorVertical"];
    [self outlet:_shadowColorVerticalTextField bind:NSValueBinding cascadingStyleStorageProperty:@"shadowColorVertical"];
    [self outlet:_shadowColorVerticalStepper bind:NSValueBinding cascadingStyleStorageProperty:@"shadowColorVertical"];

    [self outlet:_shadowColorHorizontalSlider bind:NSValueBinding cascadingStyleStorageProperty:@"shadowColorHorizontal"];
    [self outlet:_shadowColorHorizontalTextField bind:NSValueBinding cascadingStyleStorageProperty:@"shadowColorHorizontal"];
    [self outlet:_shadowColorHorizontalStepper bind:NSValueBinding cascadingStyleStorageProperty:@"shadowColorHorizontal"];

    [self outlet:_shadowColorSpreadSlider bind:NSValueBinding cascadingStyleStorageProperty:@"shadowColorSpread"];
    [self outlet:_shadowColorSpreadTextField bind:NSValueBinding cascadingStyleStorageProperty:@"shadowColorSpread"];
    [self outlet:_shadowColorSpreadStepper bind:NSValueBinding cascadingStyleStorageProperty:@"shadowColorSpread"];

    [self outlet:_shadowColorBlurSlider bind:NSValueBinding cascadingStyleStorageProperty:@"shadowColorBlur"];
    [self outlet:_shadowColorBlurTextField bind:NSValueBinding cascadingStyleStorageProperty:@"shadowColorBlur"];
    [self outlet:_shadowColorBlurStepper bind:NSValueBinding cascadingStyleStorageProperty:@"shadowColorBlur"];

    
}
- (void)dealloc{
    JDSectionInfoLog(IULogDealloc, @"");
}

- (void)reloadData{
    [_styleTableView reloadData];
}
#pragma mark - button action
- (IBAction)clickGradientEnableButton:(id)sender {
    if([sender state] == NSOnState){
        self.cascadingStyleStorage.bgColor2 = self.cascadingStyleStorage.bgColor1;
    }
    else{
        self.cascadingStyleStorage.bgColor2 = nil;
    }
}

- (IBAction)clickBGColorClearButton:(id)sender {
    self.cascadingStyleStorage.bgColor1 = nil;
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
    if([currentView isKindOfClass:[BBExpandableView class]]){
        return ((BBExpandableView *)currentView).currentHeight;
    }
    else{
        return currentView.frame.size.height;
    }
}


@end
