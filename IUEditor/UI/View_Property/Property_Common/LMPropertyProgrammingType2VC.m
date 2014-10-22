//
//  LMPropertyProgrammingType2VC.m
//  IUEditor
//
//  Created by jd on 6/13/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMPropertyProgrammingType2VC.h"

@interface LMPropertyProgrammingType2VC ()
@property (weak) IBOutlet NSTextField *contentTF;

@property (weak) IBOutlet NSTextField *ellipsisTF;
@property (weak) IBOutlet NSStepper *ellipsisStepper;
@property (weak) IBOutlet NSTextField *visibleTF;

@end

@implementation LMPropertyProgrammingType2VC{
    IUProject *_project;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadView];
    }
    return self;
}


- (void)setController:(IUController *)controller{
    [super setController:controller];

    
    [self outlet:_visibleTF bind:NSValueBinding property:@"pgVisibleConditionVariable"];
    [self outlet:_contentTF bind:NSValueBinding property:@"pgContentVariable"];

//    NSDictionary *enableBinding @{NSRaisesForNotApplicableKeysBindingOption:@(NO),NSValueTransformerNameBindingOption:@"JDNilToZeroTransformer"};
//    [self outlet:_ellipsisTF bind:NSEnabledBinding property:@"pgContentVariable"];

//    [self outlet:_ellipsisStepper bind:NSEnabledBinding property:@"pgContentVariable"];
    
    [self outlet:_ellipsisTF bind:NSValueBinding cssTag:IUCSSTagEllipsis];
    [self outlet:_ellipsisStepper bind:NSValueBinding cssTag:IUCSSTagEllipsis];
    

}

@end
