//
//  LMPropertyOverflowVC.m
//  IUEditor
//
//  Created by G on 2014. 6. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyDisplayVC.h"
#import "IUBox.h"
#import "IUCSS.h"

@interface LMPropertyDisplayVC ()
@property (weak) IBOutlet NSPopUpButton *overflowPopupBtn;
@property (weak) IBOutlet NSButton *displayHideBtn;
@property (weak) IBOutlet NSSlider *opacitySlider;
@property (weak) IBOutlet NSTextField *opacityTF;

@end

@implementation LMPropertyDisplayVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadView];
    }
    return self;
}

- (void)setController:(IUController *)controller{
    [super setController:controller];

    [self outlet:_overflowPopupBtn bind:NSSelectedIndexBinding property:@"overflowType"];
    [self outlet:_overflowPopupBtn bind:NSEnabledBinding property:@"canChangeOverflow"];
    
    [self outlet:_displayHideBtn bind:NSValueBinding cssTag:IUCSSTagDisplayIsHidden];
    
    
    NSDictionary *numberBinding =  @{NSContinuouslyUpdatesValueBindingOption:@(YES),NSRaisesForNotApplicableKeysBindingOption:@(NO),NSValueTransformerNameBindingOption:@"JDNilToHundredTransformer"};
    [self outlet:_opacityTF bind:NSValueBinding cssTag:IUCSSTagOpacity options:numberBinding];
    [self outlet:_opacitySlider bind:NSValueBinding cssTag:IUCSSTagOpacity options:numberBinding];
    
}



@end
