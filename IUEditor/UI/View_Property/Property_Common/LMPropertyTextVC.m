//
//  LMPropertyTextVC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 6. 20..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyTextVC.h"

@interface LMPropertyTextVC ()

@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSMatrix *textTypeMatrix;


@end

@implementation LMPropertyTextVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    [self outlet:_textView bind:NSValueBinding property:@"text"];
    [self outlet:_textTypeMatrix bind:NSSelectedIndexBinding property:@"textType"];
}


- (void)performFocus:(NSNotification *)noti{
    [self.view.window makeFirstResponder:_textView];
}

@end
