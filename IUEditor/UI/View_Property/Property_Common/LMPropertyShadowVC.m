//
//  LMPropertyShadowVC.m
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyShadowVC.h"

@interface LMPropertyShadowVC ()
@property (weak) IBOutlet NSColorWell *shadowColor;
@property (weak) IBOutlet NSSlider *shadowV;
@property (weak) IBOutlet NSSlider *shadowH;
@property (weak) IBOutlet NSSlider *shadowSprd;
@property (weak) IBOutlet NSSlider *shadowBlr;

@property (weak) IBOutlet NSTextField *shadowVText;
@property (weak) IBOutlet NSTextField *shadowHText;
@property (weak) IBOutlet NSTextField *shadowSpreadText;
@property (weak) IBOutlet NSTextField *shadowBlurText;


@end

@implementation LMPropertyShadowVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void)awakeFromNib{
    
    [self outlet:_shadowColor bind:NSValueBinding cssTag:IUCSSTagShadowColor];
    [self outlet:_shadowV bind:NSValueBinding cssTag:IUCSSTagShadowVertical];
    [self outlet:_shadowH bind:NSValueBinding cssTag:IUCSSTagShadowHorizontal];
    [self outlet:_shadowSprd bind:NSValueBinding cssTag:IUCSSTagShadowSpread];
    [self outlet:_shadowBlr bind:NSValueBinding cssTag:IUCSSTagShadowBlur];

    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundDown];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:0];
    [_shadowVText setFormatter:formatter];
    [_shadowHText setFormatter:formatter];
    [_shadowSpreadText setFormatter:formatter];
    [_shadowBlurText setFormatter:formatter];
    
    NSDictionary *nullBindingOption = @{NSNullPlaceholderBindingOption: @(0), NSContinuouslyUpdatesValueBindingOption: @(YES)};
    
    [self outlet:_shadowVText bind:NSValueBinding cssTag:IUCSSTagShadowVertical options:nullBindingOption];
    [self outlet:_shadowHText bind:NSValueBinding cssTag:IUCSSTagShadowHorizontal options:nullBindingOption];
    [self outlet:_shadowSpreadText bind:NSValueBinding cssTag:IUCSSTagShadowSpread options:nullBindingOption];
    [self outlet:_shadowBlurText bind:NSValueBinding cssTag:IUCSSTagShadowBlur options:nullBindingOption];

}
@end