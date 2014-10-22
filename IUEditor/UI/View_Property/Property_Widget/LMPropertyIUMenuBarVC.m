//
//  LMPropertyIUMenuBarVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 7. 31..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyIUMenuBarVC.h"

@interface LMPropertyIUMenuBarVC ()
@property (weak) IBOutlet NSTextField *countTF;
@property (weak) IBOutlet NSStepper *countStepper;
@property (weak) IBOutlet NSSegmentedControl *alignControl;

@property (weak) IBOutlet NSTextField *mobileTitleTF;
@property (weak) IBOutlet NSColorWell *mobileTitleColor;
@property (weak) IBOutlet NSColorWell *mobileIconColor;

@end

@implementation LMPropertyIUMenuBarVC

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

    [self outlet:_alignControl bind:NSSelectedIndexBinding property:@"align"];
    [self outlet:_mobileTitleTF bind:NSValueBinding property:@"mobileTitle"];
    [self outlet:_mobileTitleColor bind:NSValueBinding property:@"mobileTitleColor"];
    [self outlet:_mobileIconColor bind:NSValueBinding property:@"iconColor"];

}

@end
