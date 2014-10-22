//
//  PGSubmitButtonVC.m
//  IUEditor
//
//  Created by Geunmin.Moon on 2014. 6. 10..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "PGSubmitButtonVC.h"

@interface PGSubmitButtonVC ()
@property (weak) IBOutlet NSTextField *labelTF;

@end


@implementation PGSubmitButtonVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    [self outlet:_labelTF bind:NSValueBinding property:@"label"];
}

- (void)performFocus:(NSNotification *)noti{
    [self.view.window makeFirstResponder:_labelTF];
}

@end
