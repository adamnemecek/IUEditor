//
//  BBFontPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBFontPropertyVC.h"
#import "IUFontController.h"

@interface BBFontPropertyVC ()
@property (weak) IBOutlet NSComboBox *fontNameComboBox;
@property (weak) IBOutlet NSComboBox *fontSizeComboBox;
@property (weak) IBOutlet NSPopUpButton *fontWeightPopUpButton;
@property (weak) IBOutlet NSColorWell *fontColorWell;
@property (weak) IBOutlet NSComboBox *lineHeightComboBox;
@property (weak) IBOutlet NSComboBox *letterSpacingComboBox;
@property (weak) IBOutlet NSSegmentedControl *fontAlignSegmentedControl;
@property (weak) IBOutlet NSMatrix *textTypeMatrix;

//font controller
@property (weak) IUFontController *fontController;

@end

@implementation BBFontPropertyVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        _fontController = [IUFontController sharedFontController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self outlet:_fontNameComboBox bind:NSValueBinding cascadingStyleStorageProperty:@"fontName"];
    [self outlet:_fontSizeComboBox bind:NSValueBinding cascadingStyleStorageProperty:@"fontSize"];
    [self outlet:_fontWeightPopUpButton bind:NSSelectedIndexBinding cascadingStyleStorageProperty:@"fontWeight" options:@{NSNullPlaceholderBindingOption:@(1), NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];
    
    [self outlet:_fontColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"fontColor"];
    [self outlet:_lineHeightComboBox bind:NSValueBinding cascadingStyleStorageProperty:@"fontLineHeight" options:@{NSNullPlaceholderBindingOption:@"1.0", NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];
    [self outlet:_letterSpacingComboBox bind:NSValueBinding cascadingStyleStorageProperty:@"fontLetterSpacing" options:@{NSNullPlaceholderBindingOption:@"0.0", NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];
    [self outlet:_fontAlignSegmentedControl bind:NSSelectedIndexBinding cascadingStyleStorageProperty:@"fontAlign"];

    [self outlet:_textTypeMatrix bind:NSSelectedIndexBinding property:@"textType"];
}

@end
