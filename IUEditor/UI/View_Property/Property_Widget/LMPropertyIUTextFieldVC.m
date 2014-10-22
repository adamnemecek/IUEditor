//
//  LMPropertyIUTextFieldVC.m
//  IUEditor
//
//  Created by jd on 4/25/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMPropertyIUTextFieldVC.h"

@interface LMPropertyIUTextFieldVC ()
@property (weak) IBOutlet NSTextField *placeholderTF;
@property (weak) IBOutlet NSTextField *valueTF;
@property (weak) IBOutlet NSMatrix *typeMatrix;


@end

@implementation LMPropertyIUTextFieldVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    [self outlet:_placeholderTF bind:NSValueBinding property:@"placeholder"];
    [self outlet:_valueTF bind:NSValueBinding property:@"inputValue"];
    [self outlet:_typeMatrix bind:NSSelectedIndexBinding property:@"type"];    
}

- (void)performFocus:(NSNotification *)noti{
    [self.view.window makeFirstResponder:_valueTF];
}

@end
