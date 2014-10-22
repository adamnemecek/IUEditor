//
//  LMConsoleLogVC.m
//  IUEditor
//
//  Created by jd on 2014. 7. 10..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMConsoleVC.h"

@interface LMConsoleVC ()
@property (unsafe_unretained) IBOutlet NSTextView *logV;

@end

@implementation LMConsoleVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil window:(NSWindow *)window
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSAssert(window, @"Should have window");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addText:) name:IUNotificationConsoleLog object:window];
    }
    return self;
}

- (void)addText:(NSNotification*)noti{
    NSString *str = noti.userInfo[@"Log"];
    if (str) {
        NSAttributedString* attr = [[NSAttributedString alloc] initWithString:str];
        
        [[_logV textStorage] appendAttributedString:attr];
        [_logV scrollRangeToVisible:NSMakeRange([[_logV string] length], 0)];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
