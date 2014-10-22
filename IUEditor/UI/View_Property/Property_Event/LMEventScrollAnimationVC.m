//
//  LMPropertyScrollVC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 6. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMEventScrollAnimationVC.h"
#import "LMHelpPopover.h"
#import "IUBox.h"

@interface LMEventScrollAnimationVC ()

@property (weak) IBOutlet NSTextField *opacityMoveTF;
@property (weak) IBOutlet NSTextField *xPosMoveTF;


@end

@implementation LMEventScrollAnimationVC{
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    
    NSDictionary *numberBindingOption = @{NSContinuouslyUpdatesValueBindingOption: @(YES),
                           NSRaisesForNotApplicableKeysBindingOption:@(NO),
                           NSValueTransformerNameBindingOption:@"JDNilToZeroTransformer"};

    [self outlet:_opacityMoveTF bind:NSValueBinding property:@"opacityMove" options:numberBindingOption];
    [self outlet:_xPosMoveTF bind:NSValueBinding property:@"xPosMove" options:numberBindingOption];
    
    [self addObserverForProperty:@"opacityMove" options:0 context:nil];
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:[self pathForProperty:@"opacityMove"]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if([[keyPath pathExtension] isEqualToString:@"opacityMove"]){
        id opacityMove = [self valueForProperty:@"opacityMovie"];
        
        NSArray *selectedObj = [self.controller selectedObjects ];
        if ([opacityMove isKindOfClass:[NSNumber class]]) {
            if ([opacityMove floatValue] > 1) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    for (IUBox *iu in selectedObj) {
                        iu.opacityMove = 1;
                    }
                });
            }
        }
    }
}


- (IBAction)clickHelpButton:(NSButton *)sender {
    LMHelpPopover *popover = [LMHelpPopover sharedHelpPopover];
    [popover setType:LMPopoverTypeTextAndVideo];
    [popover setVideoName:@"EventScrollAnimation.mp4" title:@"Scroll Event" rtfFileName:nil];
    [popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinXEdge];
}
@end
