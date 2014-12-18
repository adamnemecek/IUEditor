//
//  BBPagePreferenceWC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBPagePreferenceWC.h"

@interface BBPagePreferenceWC ()

@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTokenField *keywordsTokenField;
@property (weak) IBOutlet NSComboBox *metaImageComboBox;
@property (weak) IBOutlet NSTextField *descriptionTextField;
@property (unsafe_unretained) IBOutlet NSTextView *googleCodeTextView;

@end

@implementation BBPagePreferenceWC


- (void)windowDidLoad {
    [super windowDidLoad];
    
    [_titleTextField bind:NSValueBinding toObject:self withKeyPath:@"currentPage.googleCode" options:IUBindingDictNotRaisesApplicable];
    //keyword
    [_metaImageComboBox bind:NSValueBinding toObject:self withKeyPath:@"currentPage.metaImage" options:IUBindingDictNotRaisesApplicable];
    [_descriptionTextField bind:NSValueBinding toObject:self withKeyPath:@"currentPage.desc" options:IUBindingDictNotRaisesApplicable];
    [_googleCodeTextView bind:NSValueBinding toObject:self withKeyPath:@"currentPage.googleCode" options:IUBindingDictNotRaisesApplicable];
    
}
#pragma mark - sheet control
- (IBAction)clickOkButton:(id)sender{
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (IBAction)clickCancelButton:(id)sender{
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}



@end
