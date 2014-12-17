//
//  BBFontPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBFontPropertyVC.h"
#import "LMFontController.h"

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
@property (weak) LMFontController *fontController;

@end

@implementation BBFontPropertyVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        _fontController = [LMFontController sharedFontController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self outlet:_fontNameComboBox bind:NSValueBinding cascadingStyleStorageProperty:@"fontName"];
    [self outlet:_fontSizeComboBox bind:NSValueBinding cascadingStyleStorageProperty:@"fontSize"];
    [self outlet:_fontWeightPopUpButton bind:NSSelectedIndexBinding cascadingStyleStorageProperty:@"fontWeight"];
    
    [self outlet:_fontColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"fontColor"];
    [self outlet:_lineHeightComboBox bind:NSValueBinding cascadingStyleStorageProperty:@"fontLineHeight"];
    [self outlet:_letterSpacingComboBox bind:NSValueBinding cascadingStyleStorageProperty:@"fontLetterSpacing"];
    [self outlet:_fontAlignSegmentedControl bind:NSSelectedIndexBinding cascadingStyleStorageProperty:@"fontAlign"];

    [self outlet:_textTypeMatrix bind:NSSelectedIndexBinding property:@"textType"];
}

@end
