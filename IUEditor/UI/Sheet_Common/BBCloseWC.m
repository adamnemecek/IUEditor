//
//  BBCloseWC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBCloseWC.h"

@interface BBCloseWC ()

@property (weak) IBOutlet NSTextField *titleTF;

@end

@implementation BBCloseWC

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [_titleTF bind:NSValueBinding toObject:self withKeyPath:@"projectName" options:IUBindingDictNotRaisesApplicable];
}

- (void)setProjectName:(NSString *)projectName{
    _projectName = [NSString stringWithFormat:@"Do you want to save the change made to the project \"%@\"?", projectName];
}

- (IBAction)clickSaveButton:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (IBAction)clickDontSaveButton:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseAbort];
}

- (IBAction)clickCancelButton:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}

@end
