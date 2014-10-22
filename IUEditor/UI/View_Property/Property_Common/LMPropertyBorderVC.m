//
//  LMPropertyApperenceVC.m
//  IUEditor
//
//  Created by jd on 4/10/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMPropertyBorderVC.h"
#import "JDTransformer.h"

@interface LMPropertyBorderVC ()

@property (weak) IBOutlet NSTextField *borderTF;
@property (weak) IBOutlet NSTextField *borderTopTF;
@property (weak) IBOutlet NSTextField *borderRightTF;
@property (weak) IBOutlet NSTextField *borderLeftTF;
@property (weak) IBOutlet NSTextField *borderBottomTF;

@property (weak) IBOutlet NSStepper *borderStepper;
@property (weak) IBOutlet NSStepper *borderTopStepper;
@property (weak) IBOutlet NSStepper *borderBottomStepper;
@property (weak) IBOutlet NSStepper *borderLeftStepper;
@property (weak) IBOutlet NSStepper *borderRightStepper;

@property (weak) IBOutlet NSColorWell *borderColorWell;
@property (weak) IBOutlet NSColorWell *borderTopColorWell;
@property (weak) IBOutlet NSColorWell *borderLeftColorWell;
@property (weak) IBOutlet NSColorWell *borderRightColorWell;
@property (weak) IBOutlet NSColorWell *borderBottomColorWell;

@property (weak) IBOutlet NSTextField *borderRadiusTF;
@property (weak) IBOutlet NSTextField *borderRadiusTopLeftTF;
@property (weak) IBOutlet NSTextField *borderRadiusTopRightTF;
@property (weak) IBOutlet NSTextField *borderRadiusBottomLeftTF;
@property (weak) IBOutlet NSTextField *borderRadiusBottomRightTF;

@property (weak) IBOutlet NSStepper *borderRadiusStepper;
@property (weak) IBOutlet NSStepper *borderRadiusTopLeftStepper;
@property (weak) IBOutlet NSStepper *borderRadiusTopRightStepper;
@property (weak) IBOutlet NSStepper *borderRadiusBottomLeftStepper;
@property (weak) IBOutlet NSStepper *borderRadiusBottomRightStepper;

@end



@implementation LMPropertyBorderVC

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
    
    NSDictionary *bindingOption = @{NSRaisesForNotApplicableKeysBindingOption: @(YES), NSValueTransformerNameBindingOption:@"JDNilToZeroTransformer", NSContinuouslyUpdatesValueBindingOption: @(YES)};
    
    [self outlet:_borderColorWell bind:NSValueBinding cssTag:IUCSSTagBorderColor];
    [self outlet:_borderTopColorWell bind:NSValueBinding cssTag:IUCSSTagBorderTopColor];
    [self outlet:_borderLeftColorWell bind:NSValueBinding cssTag:IUCSSTagBorderLeftColor];
    [self outlet:_borderRightColorWell bind:NSValueBinding cssTag:IUCSSTagBorderRightColor];
    [self outlet:_borderBottomColorWell bind:NSValueBinding cssTag:IUCSSTagBorderBottomColor];
    
    [self outlet:_borderTF bind:NSValueBinding cssTag:IUCSSTagBorderWidth options:bindingOption];
    [self outlet:_borderTopTF bind:NSValueBinding cssTag:IUCSSTagBorderTopWidth options:bindingOption];
    [self outlet:_borderBottomTF bind:NSValueBinding cssTag:IUCSSTagBorderBottomWidth options:bindingOption];
    [self outlet:_borderLeftTF bind:NSValueBinding cssTag:IUCSSTagBorderLeftWidth options:bindingOption];
    [self outlet:_borderRightTF bind:NSValueBinding cssTag:IUCSSTagBorderRightWidth options:bindingOption];

    [self outlet:_borderStepper bind:NSValueBinding cssTag:IUCSSTagBorderWidth options:bindingOption];
    [self outlet:_borderTopStepper bind:NSValueBinding cssTag:IUCSSTagBorderTopWidth options:bindingOption];
    [self outlet:_borderBottomStepper bind:NSValueBinding cssTag:IUCSSTagBorderBottomWidth options:bindingOption];
    [self outlet:_borderLeftStepper bind:NSValueBinding cssTag:IUCSSTagBorderLeftWidth options:bindingOption];
    [self outlet:_borderRightStepper bind:NSValueBinding cssTag:IUCSSTagBorderRightWidth options:bindingOption];

    [self outlet:_borderRadiusTF bind:NSValueBinding cssTag:IUCSSTagBorderRadius options:bindingOption];
    [self outlet:_borderRadiusTopLeftTF bind:NSValueBinding cssTag:IUCSSTagBorderRadiusTopLeft options:bindingOption];
    [self outlet:_borderRadiusTopRightTF bind:NSValueBinding cssTag:IUCSSTagBorderRadiusTopRight options:bindingOption];
    [self outlet:_borderRadiusBottomLeftTF bind:NSValueBinding cssTag:IUCSSTagBorderRadiusBottomLeft options:bindingOption];
    [self outlet:_borderRadiusBottomRightTF bind:NSValueBinding cssTag:IUCSSTagBorderRadiusBottomRight options:bindingOption];
    
    [self outlet:_borderRadiusStepper bind:NSValueBinding cssTag:IUCSSTagBorderRadius options:bindingOption];
    [self outlet:_borderRadiusTopLeftStepper bind:NSValueBinding cssTag:IUCSSTagBorderRadiusTopLeft options:bindingOption];
    [self outlet:_borderRadiusTopRightStepper bind:NSValueBinding cssTag:IUCSSTagBorderRadiusTopRight options:bindingOption];
    [self outlet:_borderRadiusBottomLeftStepper bind:NSValueBinding cssTag:IUCSSTagBorderRadiusBottomLeft options:bindingOption];
    [self outlet:_borderRadiusBottomRightStepper bind:NSValueBinding cssTag:IUCSSTagBorderRadiusBottomRight options:bindingOption];
    
}
- (IBAction)clickBorderColorWell:(id)sender {
    id selectedColor = [_borderColorWell color];
    
    [self setValue:selectedColor forCSSTag:IUCSSTagBorderTopColor];
    [self setValue:selectedColor forCSSTag:IUCSSTagBorderBottomColor];
    [self setValue:selectedColor forCSSTag:IUCSSTagBorderLeftColor];
    [self setValue:selectedColor forCSSTag:IUCSSTagBorderRightColor];
}

- (IBAction)clickBorderTotalSize:(id)sender {
    int selectedSize;
    if([sender isKindOfClass:[NSTextField class]]){
        selectedSize = [_borderTF intValue];
        [_borderStepper setIntValue:selectedSize];
    }
    else{
        selectedSize = [_borderStepper intValue];
        [_borderTF setIntValue:selectedSize];
    }
    [self setValue:@(selectedSize) forCSSTag:IUCSSTagBorderTopWidth];
    [self setValue:@(selectedSize) forCSSTag:IUCSSTagBorderBottomWidth];
    [self setValue:@(selectedSize) forCSSTag:IUCSSTagBorderLeftWidth];
    [self setValue:@(selectedSize) forCSSTag:IUCSSTagBorderRightWidth];

}

- (IBAction)clickBorderRadiusTotalSize:(id)sender {
    int selectedSize;
    if([sender isKindOfClass:[NSTextField class]]){
        selectedSize = [_borderRadiusTF intValue];
        [_borderRadiusStepper setIntValue:selectedSize];
    }
    else{
        selectedSize = [_borderRadiusStepper intValue];
        [_borderRadiusTF setIntValue:selectedSize];
    }
    
    [self setValue:@(selectedSize) forCSSTag:IUCSSTagBorderRadiusTopLeft];
    [self setValue:@(selectedSize) forCSSTag:IUCSSTagBorderRadiusTopRight];
    [self setValue:@(selectedSize) forCSSTag:IUCSSTagBorderRadiusBottomLeft];
    [self setValue:@(selectedSize) forCSSTag:IUCSSTagBorderRadiusBottomRight];
    
}

@end