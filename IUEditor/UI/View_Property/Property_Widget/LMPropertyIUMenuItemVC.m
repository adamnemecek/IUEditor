//
//  LMPropertyIUMenuItemVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 7. 31..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyIUMenuItemVC.h"

@interface LMPropertyIUMenuItemVC ()
@property (weak) IBOutlet NSTextField *countTF;
@property (weak) IBOutlet NSStepper *countStepper;
@property (weak) IBOutlet NSColorWell *bgColor;
@property (weak) IBOutlet NSColorWell *fontColor;

@property (weak) IBOutlet NSTextField *titleTF;

@end

@implementation LMPropertyIUMenuItemVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    
    [self outlet:_countStepper bind:NSValueBinding property:@"count" options:IUBindingDictNumberAndNotRaisesApplicable];
    [self outlet:_countTF bind:NSValueBinding property:@"count" options:IUBindingDictNumberAndNotRaisesApplicable];

    [self outlet:_countStepper bind:NSEnabledBinding property:@"hasItemChildren"];
    [self outlet:_countTF bind:NSEnabledBinding property:@"hasItemChildren"];
    [self outlet:_countTF bind:NSEditableBinding property:@"hasItemChildren"];

    [self outlet:_bgColor bind:NSValueBinding property:@"bgActive"];
    [self outlet:_fontColor bind:NSValueBinding property:@"fontActive"];
    
    [self outlet:_titleTF bind:NSValueBinding property:@"text"];

}

- (void)performFocus:(NSNotification *)noti{
    [self.view.window makeFirstResponder:_titleTF];
}


@end
