//
//  LMPropertyVRFrameVC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 21..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMEventVariableReceiverFrameVC.h"
#import "LMHelpPopover.h"

@interface LMEventVariableReceiverFrameVC ()
@property (weak) IBOutlet NSTextField *equationTF;
@property (weak) IBOutlet NSTextField *durationTF;
@property (weak) IBOutlet NSStepper *durationStepper;
@property (weak) IBOutlet NSTextField *widthTF;
@property (weak) IBOutlet NSTextField *heightTF;

@end

@implementation LMEventVariableReceiverFrameVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib{

    NSDictionary *numberBindingOption = @{NSRaisesForNotApplicableKeysBindingOption:@(NO),NSValueTransformerNameBindingOption:@"JDNilToZeroTransformer", NSContinuouslyUpdatesValueBindingOption : @(YES)};
    
    [self outlet:_equationTF bind:NSValueBinding eventTag:IUEventTagFrameEquation];
    [self outlet:_durationTF bind:NSValueBinding eventTag:IUEventTagFrameDuration options:numberBindingOption];
    [self outlet:_durationStepper bind:NSValueBinding eventTag:IUEventTagFrameDuration options:numberBindingOption];

    [self outlet:_widthTF bind:NSValueBinding eventTag:IUEventTagFrameWidth options:numberBindingOption];
    [self outlet:_heightTF bind:NSValueBinding eventTag:IUEventTagFrameHeight options:numberBindingOption];
    
}

- (IBAction)clickHelpButton:(NSButton *)sender {
    LMHelpPopover *popover = [LMHelpPopover sharedHelpPopover];
    [popover setType:LMPopoverTypeTextAndVideo];
    [popover setVideoName:@"EventVariableComplex.mp4" title:@"Variable Event" rtfFileName:nil];
    [popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinXEdge];
}


@end
