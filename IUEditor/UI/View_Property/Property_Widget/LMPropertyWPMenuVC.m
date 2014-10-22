//
//  LMPropertyWPMenuVC.m
//  IUEditor
//
//  Created by jd on 2014. 7. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyWPMenuVC.h"

@interface LMPropertyWPMenuVC ()

@property (weak) IBOutlet NSPopUpButton *menuCountCB;
@property (weak) IBOutlet NSSegmentedControl *alignSegmentedControl;
@property (weak) IBOutlet NSTextField *paddingTF;
@property (weak) IBOutlet NSStepper *paddingStpper;

@end

@implementation LMPropertyWPMenuVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    [self outlet:_alignSegmentedControl bind:NSSelectedIndexBinding property:@"align"];
    [self outlet:_menuCountCB bind:NSSelectedTagBinding property:@"itemCount"];
    [self outlet:_paddingTF bind:NSValueBinding property:@"leftRightPadding" options:IUBindingDictNumberAndNotRaisesApplicable];
    [self outlet:_paddingStpper bind:NSValueBinding property:@"leftRightPadding"];
}

@end
