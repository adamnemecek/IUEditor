//
//  LMPropertyVTriggerVC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 21..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMEventVariableTrigger.h"
#import "LMHelpPopover.h"

@interface LMEventVariableTrigger ()
@property (weak) IBOutlet NSTextField *variableTF;

@property (weak) IBOutlet NSTextField *initailValueTF;
@property (weak) IBOutlet NSStepper *initialValueStepper;
@property (weak) IBOutlet NSTextField *maxValueTF;
@property (weak) IBOutlet NSStepper *maxValueStepper;
@property (weak) IBOutlet NSPopUpButton *actionTypePopupButton;
@end

@implementation LMEventVariableTrigger

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    

    [self outlet:_variableTF bind:NSValueBinding eventTag:IUEventTagVariable];
    
    [self outlet:_initailValueTF bind:NSValueBinding eventTag:IUEventTagInitialValue];
    [self outlet:_initialValueStepper bind:NSValueBinding eventTag:IUEventTagInitialValue];
    
    
    [self outlet:_maxValueTF bind:NSValueBinding eventTag:IUEventTagMaxValue];
    [self outlet:_maxValueStepper bind:NSValueBinding eventTag:IUEventTagMaxValue];

    [self outlet:_actionTypePopupButton bind:NSSelectedIndexBinding eventTag:IUEventTagActionType];

}

- (IBAction)clickHelpButton:(NSButton *)sender {
    LMHelpPopover *popover = [LMHelpPopover sharedHelpPopover];
    [popover setType:LMPopoverTypeTextAndVideo];
    [popover setVideoName:@"EventVariableComplex.mp4" title:@"Variable Event" rtfFileName:nil];
    [popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinXEdge];
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    if([control isEqualTo:_variableTF]){
        NSString *currentName = [_variableTF stringValue];
        if([JavascriptReservedKeywords containsString:currentName]
           || [JqueryReservedKeywords containsString:currentName]){
            [JDUIUtil hudAlert:@"This variable is a reserved keyword, Use another word" second:2];
            return NO;
        }
    }

    
    return YES;
}


@end
