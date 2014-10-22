//
//  LMAppWarningWC.m
//  IUEditor
//
//  Created by seungmi on 2014. 8. 25..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMAppWarningWC.h"

@interface LMAppWarningWC ()

@end

@implementation LMAppWarningWC

- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)closeIUEditor:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

- (IBAction)runWithoutInternet:(id)sender {
    [self.window close];
}

@end
