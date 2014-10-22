//
//  LMPropertyIUPage.m
//  IUEditor
//
//  Created by seungmi on 2014. 9. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyIUSection.h"

@interface LMPropertyIUSection ()

@property (weak) IBOutlet NSButton *fullsizeBtn;

@end

@implementation LMPropertyIUSection

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    [self outlet:_fullsizeBtn bind:NSValueBinding property:@"enableFullSize"];
}


@end
