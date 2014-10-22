//
//  LMPropertyBGColorVC.m
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMAppearanceColorVC.h"

@interface LMAppearanceColorVC ()

@property (weak) IBOutlet NSColorWell *bgColorWell;
@property (weak) IBOutlet NSColorWell *bgGradientStartColorWell;
@property (weak) IBOutlet NSColorWell *bgGradientEndColorWell;
@property (weak) IBOutlet NSButton *enableGradientBtn;

@end

@implementation LMAppearanceColorVC

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
    
    [NSColor setIgnoresAlpha:NO];

    [self outlet:_bgColorWell bind:NSValueBinding cssTag:IUCSSTagBGColor];
    
    //gradient
    
    [self outlet:_enableGradientBtn bind:NSValueBinding cssTag:IUCSSTagBGGradient];
    [self outlet:_bgGradientStartColorWell bind:NSEnabledBinding cssTag:IUCSSTagBGGradient];
    [self outlet:_bgGradientEndColorWell bind:NSEnabledBinding cssTag:IUCSSTagBGGradient];

    [self outlet:_bgGradientStartColorWell bind:NSValueBinding cssTag:IUCSSTagBGGradientStartColor];
    [self outlet:_bgGradientEndColorWell bind:NSValueBinding cssTag:IUCSSTagBGGradientEndColor];
    
}

- (void)makeClearColor:(id)sender{
    [self setValue:[NSColor clearColor] forCSSTag:IUCSSTagBGColor];
}
- (IBAction)clickEnableGradient:(id)sender {
    if([_enableGradientBtn state]){
        id currentColor = [self valueForCSSTag:IUCSSTagBGColor];
        [self setValue:currentColor forCSSTag:IUCSSTagBGGradientStartColor];
        [self setValue:currentColor forCSSTag:IUCSSTagBGGradientEndColor];
    }
    else{
        [_bgGradientStartColorWell deactivate];
        [_bgGradientEndColorWell deactivate];
    }
}

@end
