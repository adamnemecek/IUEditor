//
//  BBTracingPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBTracingPropertyVC.h"

@interface BBTracingPropertyVC ()

@property (weak) IBOutlet NSComboBox *tracingImageComboBox;
@property (weak) IBOutlet NSTextField *ghostXTextField;
@property (weak) IBOutlet NSTextField *ghostYTextField;
@property (weak) IBOutlet NSSlider *ghostOpacitySlider;
@property (weak) IBOutlet NSTextField *ghostOpacityTextField;
@property (weak) IBOutlet NSButton *tracingModeButton;

@property (weak) IUSheet *currentSheet;


@end

@implementation BBTracingPropertyVC{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    //add observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sheetSelectionChange:) name:IUNotificationSheetSelectionDidChange object:self.pageController.project];
    
    
    //binding
    [_tracingImageComboBox bind:NSValueBinding toObject:self withKeyPath:@"currentSheet.ghostImageName" options:@{NSNullPlaceholderBindingOption:@"URL or Select image from library", NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];
    [_ghostXTextField bind:NSValueBinding toObject:self withKeyPath:@"currentSheet.ghostX" options:@{NSNullPlaceholderBindingOption:@"0", NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];
    [_ghostYTextField bind:NSValueBinding toObject:self withKeyPath:@"currentSheet.ghostY" options:@{NSNullPlaceholderBindingOption:@"0", NSContinuouslyUpdatesValueBindingOption: @(YES), NSRaisesForNotApplicableKeysBindingOption:@(NO)}];
    [_ghostOpacitySlider bind:NSValueBinding toObject:self withKeyPath:@"currentSheet.ghostOpacity" options:IUBindingDictNotRaisesApplicable];
    [_ghostOpacityTextField bind:NSValueBinding toObject:self withKeyPath:@"currentSheet.ghostOpacity" options:IUBindingDictNotRaisesApplicable];
    [_tracingModeButton bind:NSValueBinding toObject:[NSUserDefaults standardUserDefaults] withKeyPath:@"showGhost" options:nil];


}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    JDSectionInfoLog(IULogDealloc, @"");

}


- (void)sheetSelectionChange:(NSNotification *)notification{
    IUSheet *sheet = [notification.userInfo objectForKey:kIUNotificationSheetSelection];
    self.currentSheet = sheet;
}

#pragma mark - tracing combobox

- (void)comboBoxSelectionDidChange:(NSNotification *)notification{
    
    NSComboBox *comboBox = notification.object;
    if([comboBox isEqualTo:_tracingImageComboBox]){
        
        NSString *fileName = [_tracingImageComboBox objectValueOfSelectedItem];
        if(fileName == nil){
            [_tracingImageComboBox selectItemWithObjectValue:_currentSheet.ghostImageName];
        }
        else{
            self.currentSheet.ghostImageName = fileName;
        }
    }
}



- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    if([control isEqualTo:_tracingImageComboBox]){
        NSString *fileName = [control stringValue];
        self.currentSheet.ghostImageName = fileName;
        return YES;
    }
    
    return YES;
}



@end
