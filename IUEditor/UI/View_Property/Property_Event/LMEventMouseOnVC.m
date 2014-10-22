//
//  LMPropertyMouseEventVC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 21..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMEventMouseOnVC.h"
#import "LMHelpPopover.h"

@interface LMEventMouseOnVC ()

//position
@property (weak) IBOutlet NSButton *changeBGImagePositionB;

@property (weak) IBOutlet NSStepper *bgXStepper;
@property (weak) IBOutlet NSStepper *bgYStepper;

@property (weak) IBOutlet NSTextField *bgXTF;
@property (weak) IBOutlet NSTextField *bgYTF;

//bgColor
@property (weak) IBOutlet NSButton *changeBGColorBtn;
@property (weak) IBOutlet NSColorWell *bgColorWell;
@property (weak) IBOutlet NSTextField *bgColorDurationTF;

//textColor
@property (weak) IBOutlet NSButton *changeTextColorBtn;
@property (weak) IBOutlet NSColorWell *textColorWell;

@end

@implementation LMEventMouseOnVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{

#pragma mark bgX,Y
    
    NSDictionary *bgEnableBindingOption = [NSDictionary
                                           dictionaryWithObjects:@[NSIsNotNilTransformerName]
                                           forKeys:@[NSValueTransformerNameBindingOption]];
    
    NSDictionary *tfBindingOption = @{NSNullPlaceholderBindingOption: @(0), NSContinuouslyUpdatesValueBindingOption: @(YES)};

    [self outlet:_changeBGImagePositionB bind:NSEnabledBinding cssTag:IUCSSTagImage options:bgEnableBindingOption];
    [self outlet:_changeBGImagePositionB bind:NSValueBinding cssTag:IUCSSTagHoverBGImagePositionEnable];

    [self outlet:_bgXTF bind:NSEnabledBinding cssTag:IUCSSTagHoverBGImagePositionEnable];
    [self outlet:_bgXTF bind:NSValueBinding cssTag:IUCSSTagHoverBGImageX options:tfBindingOption];
    
    [self outlet:_bgXStepper bind:NSEnabledBinding cssTag:IUCSSTagHoverBGImagePositionEnable];
    [self outlet:_bgXStepper bind:NSValueBinding cssTag:IUCSSTagHoverBGImageX options:tfBindingOption];
    
    [self outlet:_bgYTF bind:NSEnabledBinding cssTag:IUCSSTagHoverBGImagePositionEnable];
    [self outlet:_bgYTF bind:NSValueBinding cssTag:IUCSSTagHoverBGImageY options:tfBindingOption];

    [self outlet:_bgYStepper bind:NSEnabledBinding cssTag:IUCSSTagHoverBGImagePositionEnable];
    [self outlet:_bgYStepper bind:NSValueBinding cssTag:IUCSSTagHoverBGImageY options:tfBindingOption];

    
#pragma mark bgColor
    [self outlet:_changeBGColorBtn bind:NSValueBinding cssTag:IUCSSTagHoverBGColorEnable];
    [self outlet:_bgColorWell bind:NSValueBinding cssTag:IUCSSTagHoverBGColor];
    [self outlet:_bgColorDurationTF bind:NSValueBinding cssTag:IUCSSTagHoverBGColorDuration options:IUBindingDictNumberAndNotRaisesApplicable];

    
#pragma mark textColor
    [self outlet:_changeTextColorBtn bind:NSValueBinding cssTag:IUCSSTagHoverTextColorEnable];
    [self outlet:_textColorWell bind:NSValueBinding cssTag:IUCSSTagHoverTextColor];
}
- (IBAction)clickHelpButton:(NSButton *)sender {
    LMHelpPopover *popover = [LMHelpPopover sharedHelpPopover];
    [popover setType:LMPopoverTypeTextAndVideo];
    [popover setVideoName:@"EventMouseOn.mp4" title:@"Mouse On Event" rtfFileName:nil];
    [popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinXEdge];
}

@end
