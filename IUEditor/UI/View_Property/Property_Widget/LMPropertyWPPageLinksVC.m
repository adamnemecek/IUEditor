//
//  LMPropertyWPPageLinksVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 8. 27..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyWPPageLinksVC.h"

@interface LMPropertyWPPageLinksVC ()

@property (weak) IBOutlet NSSegmentedControl *alignSegementedControl;
@property (weak) IBOutlet NSTextField *paddingTF;
@property (weak) IBOutlet NSStepper *paddingStepper;

@end

@implementation LMPropertyWPPageLinksVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    [self outlet:_alignSegementedControl bind:NSSelectedIndexBinding property:@"align"];
    [self outlet:_paddingTF bind:NSValueBinding property:@"leftRightPadding" options:IUBindingDictNumberAndNotRaisesApplicable];
    [self outlet:_paddingStepper bind:NSValueBinding property:@"leftRightPadding"];

}

@end
