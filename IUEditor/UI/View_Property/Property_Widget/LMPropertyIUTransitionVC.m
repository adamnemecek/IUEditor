//
//  LMPropertyIUTransitionVC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyIUTransitionVC.h"

@interface LMPropertyIUTransitionVC ()
@property (weak) IBOutlet NSPopUpButton *eventB;
@property (weak) IBOutlet NSPopUpButton *animationB;
@property (weak) IBOutlet NSTextField *durationTF;

@property NSArray *typeArray;

@end

@implementation LMPropertyIUTransitionVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    
    [self outlet:_eventB bind:NSSelectedValueBinding property:@"eventType"];
    [self outlet:_animationB bind:NSSelectedValueBinding property:@"animation"];
    [self outlet:_durationTF bind:NSValueBinding property:@"duration" options:IUBindingDictNumberAndNotRaisesApplicable];
    
    _typeArray = [IUEvent visibleTypeArray];
    
    [_animationB bind:NSContentBinding toObject:self withKeyPath:@"typeArray" options:IUBindingDictNotRaisesApplicable];
}

@end
