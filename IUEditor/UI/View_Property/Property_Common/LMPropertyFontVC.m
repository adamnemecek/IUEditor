//
//  LMPropertyTextVC.m
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyFontVC.h"
#import "IUCSS.h"
#import "LMFontController.h"
#import "PGTextField.h"
#import "PGTextView.h"
#import "PGSubmitButton.h"
#import "IUMenuItem.h"

@interface LMPropertyFontVC ()

@property (weak) IBOutlet NSComboBox *fontCB;
@property (weak) IBOutlet NSComboBox *fontSizeComboBox;
@property (weak) IBOutlet NSColorWell *fontColorWell;

@property (weak) IBOutlet NSSegmentedControl *fontStyleB;
@property (weak) IBOutlet NSSegmentedControl *textAlignB;
@property (weak) IBOutlet NSComboBox *lineHeightB;
@property (weak) IBOutlet NSComboBox *letterSpacingComboBox;

@property (weak) IBOutlet NSButton *autoHeightBtn;
@property (weak) IBOutlet NSMatrix *fontWeightMatrix;
@property (weak) IBOutlet NSButtonCell *lightWeightButtonCell;

@property (weak) LMFontController *fontController;
@property (strong) IBOutlet NSDictionaryController *fontListDC;

@property NSArray *fontDefaultSizes;
@property NSArray *fontDefaultLetterSpacing;
@end

@implementation LMPropertyFontVC{
    NSArray *observingList;
    BOOL isUpdateDisabled;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.fontDefaultSizes = @[@(6), @(8), @(9), @(10), @(11), @(12),
                                  @(14), @(18), @(21), @(24), @(30), @(36), @(48), @(60), @(72)];
        self.fontDefaultLetterSpacing = @[@(0), @(-2.0), @(-1.0), @(0.5), @(1.0), @(2.0)];
        [self loadView];
        
    }
    return self;
}

- (void)setController:(IUController *)controller{
    [super setController:controller];
    
    
    [self outlet:_textAlignB bind:NSSelectedIndexBinding cssTag:IUCSSTagTextAlign];
    [self outlet:_autoHeightBtn bind:NSValueBinding property:@"lineHeightAuto"];
    [self outlet:_autoHeightBtn bind:NSEnabledBinding cssTag:IUCSSTagPixelHeight options:IUBindingDictNumberAndNotRaisesApplicable];
    
    //observing for undo
    observingList = @[
                      /*
                      [self pathForCSSTag:IUCSSTagFontName],
                      [self pathForCSSTag:IUCSSTagFontWeight],
                      [self pathForCSSTag:IUCSSTagFontItalic],
                      [self pathForCSSTag:IUCSSTagFontDecoration],
                      [self pathForCSSTag:IUCSSTagFontSize],
                      [self pathForCSSTag:IUCSSTagLineHeight],
                       */
                      @"controller.selectedObjects",
                      ];
    [self addObserver:self forKeyPaths:observingList options:0 context:@"font"];

    
    _fontController = [LMFontController sharedFontController];
    [_fontListDC bind:NSContentDictionaryBinding toObject:_fontController withKeyPath:@"fontDict" options:nil];
    [_fontCB bind:NSContentBinding toObject:_fontListDC withKeyPath:@"arrangedObjects.key" options:IUBindingDictNotRaisesApplicable];
    
    [self outlet:_fontColorWell bind:NSValueBinding cssTag:IUCSSTagFontColor];
    
    //combobox delegate
    _fontCB.delegate = self;
    _fontSizeComboBox.delegate = self;
    _fontSizeComboBox.dataSource = self;
    _lineHeightB.delegate = self;
    _letterSpacingComboBox.delegate = self;
    _letterSpacingComboBox.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableUpdate) name:IUNotificationSelectionWillChange object:controller];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableUpdate) name:IUNotificationSelectionDidChange object:controller];
}

- (void)disableUpdate{
    isUpdateDisabled = YES;
}

- (void)enableUpdate{
    isUpdateDisabled = NO;
    [self fontContextDidChange:nil];
}

- (void)dealloc{
    [self removeObserver:self forKeyPaths:observingList];
}

/**
 Check Font should be enabled for current IUController selection
 */
- (BOOL)isEnabledForCurrentSelection{
    if(self.controller.selectedObjects.count < 1){
        return NO;
    }
    
    return YES;
}

- (void)fontContextDidChange:(NSDictionary *)change{
    if (isUpdateDisabled) {
        return;
    }
    isUpdateDisabled = YES;
    if([self isEnabledForCurrentSelection]){
        [_fontStyleB setEnabled:YES];
        
        id italicValue = [self valueForCSSTag:IUCSSTagFontItalic];
        if ([italicValue respondsToSelector:@selector(boolValue)]) {
            [_fontStyleB setSelected:[italicValue boolValue] forSegment:0];
        }
        else {
            [_fontStyleB setSelected:NO forSegment:0];
        }
        
        id underlineValue = [self valueForCSSTag:IUCSSTagFontDecoration];
        if ([underlineValue respondsToSelector:@selector(boolValue)]) {
            [_fontStyleB setSelected:[underlineValue boolValue] forSegment:1];
        }
        else {
            [_fontStyleB setSelected:NO forSegment:1];
        }

        //set current value
        for(IUBox *box in self.controller.selectedObjects){
            [_fontController setCurrentFontToIUBox:box];
        }
        
        //set font name
        NSString *iuFontName = [self valueForCSSTag:IUCSSTagFontName];
        if(iuFontName == NSMultipleValuesMarker){
            NSString *placeholder = [NSString stringWithValueMarker:NSMultipleValuesMarker];
            [[_fontCB cell] setPlaceholderString:placeholder];
            [_fontCB setStringValue:@""];
        }
        else if(iuFontName != nil){
            [[_fontCB cell] setPlaceholderString:@""];
            [_fontCB setStringValue:iuFontName];
        }
        else{
            [_fontCB setStringValue:@""];
        }
        
        
        //set Font size
        if([self valueForCSSTag:IUCSSTagFontSize] == NSMultipleValuesMarker){
            NSString *placeholder = [NSString stringWithValueMarker:NSMultipleValuesMarker];
            [[_fontSizeComboBox cell] setPlaceholderString:placeholder];
            [_fontSizeComboBox setStringValue:@""];
            
        }
        else{
            NSUInteger iuFontSize = [[self valueForCSSTag:IUCSSTagFontSize] integerValue];
            [[_fontSizeComboBox cell] setPlaceholderString:@""];
            [_fontSizeComboBox setStringValue:[NSString stringWithFormat:@"%ld", iuFontSize]];
        }
        
        //set LetterSpacing
        if([self valueForCSSTag:IUCSSTagTextLetterSpacing] == NSMultipleValuesMarker){
            NSString *placeholder = [NSString stringWithValueMarker:NSMultipleValuesMarker];
            [[_letterSpacingComboBox cell] setPlaceholderString:placeholder];
            [_letterSpacingComboBox setStringValue:@""];
            
        }
        else{
            CGFloat letterSpacing = [[self valueForCSSTag:IUCSSTagTextLetterSpacing] floatValue];
            [[_letterSpacingComboBox cell] setPlaceholderString:@""];
            [_letterSpacingComboBox setStringValue:[NSString stringWithFormat:@"%.1f", letterSpacing]];
        }
        
        //set fontHeight
        if([self valueForCSSTag:IUCSSTagLineHeight] == NSMultipleValuesMarker){
            NSString *placeholder = [NSString stringWithValueMarker:NSMultipleValuesMarker];
            [[_lineHeightB cell] setPlaceholderString:placeholder];
            [_lineHeightB setStringValue:@""];
        }
        else{
            CGFloat lineheight = [[self valueForCSSTag:IUCSSTagLineHeight] floatValue];
            [[_lineHeightB cell] setPlaceholderString:@""];
            [_lineHeightB setStringValue:[NSString stringWithFormat:@"%.1f", lineheight]];
        }
        
        
        //set font weight
        if([self valueForCSSTag:IUCSSTagFontWeight] == NSMultipleValuesMarker){
            [_fontWeightMatrix selectCellAtRow:0 column:1];
        }
        else{
            NSString *fontWeight = [self valueForCSSTag:IUCSSTagFontWeight];
            if ([fontWeight isEqualToString:@"300"]) {
                [_fontWeightMatrix selectCellAtRow:0 column:0];
            }
            else if ([fontWeight isEqualToString:@"400"]) {
                [_fontWeightMatrix selectCellAtRow:0 column:1];
            }
            else if ([fontWeight isEqualToString:@"700"]) {
                [_fontWeightMatrix selectCellAtRow:0 column:2];
            }
            else{
                [_fontWeightMatrix selectCellAtRow:0 column:1];
            }
            
        }
        
        [self checkFontWeight:iuFontName];
        
        //enable font type box
        [_fontCB setEnabled:YES];
        [_fontSizeComboBox setEnabled:YES];
        [_fontSizeComboBox setEditable:YES];
        [_fontColorWell setEnabled:YES];
        [_lineHeightB setEnabled:YES];
        [_lineHeightB setEditable:YES];
        [_textAlignB setEnabled:YES];
        [_letterSpacingComboBox setEditable:YES];
        [_letterSpacingComboBox setEnabled:YES];
        [_fontWeightMatrix setEnabled:YES];


    }
    else{
        //disable font type box
        [_fontCB setEnabled:NO];
        [_fontSizeComboBox setEnabled:NO];
        [_fontSizeComboBox setEditable:NO];
        [_fontColorWell setEnabled:NO];
        [_lineHeightB setEnabled:NO];
        [_lineHeightB setEditable:NO];
        [_textAlignB setEnabled:NO];
        [_fontStyleB setEnabled:NO];
        [_letterSpacingComboBox setEditable:NO];
        [_letterSpacingComboBox setEnabled:NO];
        [_fontWeightMatrix setEnabled:NO];
    }
    isUpdateDisabled = NO;
    
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification{
    NSComboBox *currentComboBox = notification.object;
    if([currentComboBox isEqualTo:_fontCB]){
        [self updateFontName:[_fontCB objectValueOfSelectedItem]];
    }
    else if([currentComboBox isEqualTo:_fontSizeComboBox]){
        NSInteger index = [_fontSizeComboBox indexOfSelectedItem];
        NSInteger size = [[_fontDefaultSizes objectAtIndex:index] integerValue];
        [self updateFontSize:size];
    }
    else if([currentComboBox isEqualTo:_letterSpacingComboBox]){
        NSInteger index = [_letterSpacingComboBox indexOfSelectedItem];
        CGFloat spacing = [[_fontDefaultLetterSpacing objectAtIndex:index] floatValue];
        [self updateLetterSpacing:spacing];
    }
    else if([currentComboBox isEqualTo:_lineHeightB]){
        [self updateLineHeight:[[_lineHeightB objectValueOfSelectedItem] floatValue]];
    }
}

- (IBAction)selectFontWeightMatrix:(id)sender {
    [self checkFontWeight:[_fontController currentFontName]];
    
    switch ([_fontWeightMatrix selectedColumn]) {
        case 0:
            [self updateFontWeight:@"300"];
            break;
        case 1:
            [self updateFontWeight:@"400"];
            break;
        case 2:
            [self updateFontWeight:@"700"];
            break;
        default:
            break;
    }
    
}

- (void)updateFontName:(NSString *)fontName{
    [_fontController setCurrentFontName:fontName];
    [self setValue:fontName forCSSTag:IUCSSTagFontName];
    [self checkFontWeight:fontName];
}
- (void)checkFontWeight:(NSString *)fontName{
    
    BOOL hasLightWeight = [_fontController hasLight:fontName];
    
    if(hasLightWeight == NO){
        [_lightWeightButtonCell setState:NSOffState];

        if([[_fontWeightMatrix selectedCell] isEqualTo:_lightWeightButtonCell]){
            [_fontWeightMatrix selectCellAtRow:0 column:1];
            [self updateFontWeight:@"400"];
        }
    }
    
    [_lightWeightButtonCell setEnabled:hasLightWeight];
    [_lightWeightButtonCell setTransparent:!hasLightWeight];
}

- (void)updateFontWeight:(NSString *)fontWeight{
    [self setValue:fontWeight forCSSTag:IUCSSTagFontWeight];
}

- (void)updateFontSize:(NSInteger)fontSize{
    [_fontController setCurrentFontSize:fontSize];
    [self setValue:@(fontSize) forCSSTag:IUCSSTagFontSize];
}

- (void)updateLetterSpacing:(CGFloat)sapcing{
    [self setValue:@(sapcing) forCSSTag:IUCSSTagTextLetterSpacing];
}

- (void)updateLineHeight:(CGFloat)lineHeightStr{
    [self setValue:@(NO) forIUProperty:@"lineHeightAuto"];
    [self setValue:@(lineHeightStr) forCSSTag:IUCSSTagLineHeight];
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    if([control isEqualTo:_fontCB]){
        [self updateFontName:[fieldEditor string]];
    }
    else if([control isEqualTo:_fontSizeComboBox]){
        NSInteger fontSize = [[fieldEditor string] integerValue];
        if(fontSize == 0 ){
            [self updateFontSize:1];
            [_fontSizeComboBox setStringValue:@"1"];
            [JDUIUtil hudAlert:@"Font Size can't be Zero" second:2];
            return NO;
        }
        [self updateFontSize:fontSize];
    }
    else if([control isEqualTo:_letterSpacingComboBox]){
        CGFloat letterSpacing = [[fieldEditor string] floatValue];
        [self updateLetterSpacing:letterSpacing];
    }
    else if([control isEqualTo:_lineHeightB]){
        [self updateLineHeight:[[fieldEditor string] floatValue]];
    }
    return YES;
}



- (BOOL)control:(NSControl *)control didFailToFormatString:(NSString *)string errorDescription:(NSString *)error{

    if([control isEqualTo:_fontSizeComboBox] || [control isEqualTo:_letterSpacingComboBox]){
        NSString *digit = [string stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        if(digit){
            [control setStringValue:digit];
        }
    }

    return YES;
}


- (IBAction)fontDecoBPressed:(id)sender {
    
   
    NSInteger index = [sender selectedSegment];
    switch (index) {
        case 0:{
            BOOL value = [sender isSelectedForSegment:index];
            [self setValue:@(value) forCSSTag:IUCSSTagFontItalic];
            break;
        }
        case 1:{
            BOOL value = [sender isSelectedForSegment:index];
            [self setValue:@(value) forCSSTag:IUCSSTagFontDecoration];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark -
#pragma mark combobox dataSource

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox{
    if([aComboBox isEqualTo:_fontSizeComboBox]){
        return _fontDefaultSizes.count;
    }
    else if([aComboBox isEqualTo:_letterSpacingComboBox]){
        return _fontDefaultLetterSpacing.count;
    }
    
    return 0;
}
- (id)comboBox:(NSComboBox *)categoryCombo objectValueForItemAtIndex:(NSInteger)row {
    if([categoryCombo isEqualTo:_fontSizeComboBox]){
        return [_fontDefaultSizes objectAtIndex:row];
    }
    else if([categoryCombo isEqualTo:_letterSpacingComboBox]){
        return [_fontDefaultLetterSpacing objectAtIndex:row];
    }

    return nil;
}


@end
