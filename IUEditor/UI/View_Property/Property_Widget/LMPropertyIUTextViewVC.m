//
//  LMPropertyIUTextViewVC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 5. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyIUTextViewVC.h"

@interface LMPropertyIUTextViewVC ()
@property (weak) IBOutlet NSTextField *placeholderTF;
@property (weak) IBOutlet NSTextField *valueTF;

@end

@implementation LMPropertyIUTextViewVC

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
}

- (void)performFocus:(NSNotification *)noti{
    [self.view.window makeFirstResponder:_valueTF];
}
@end
