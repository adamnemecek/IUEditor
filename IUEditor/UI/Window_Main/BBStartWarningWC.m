//
//  BBStartWarningWC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBStartWarningWC.h"

@interface BBStartWarningWC ()

@end

@implementation BBStartWarningWC

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)clickRunButton:(id)sender {
    [self.window close];
}
- (IBAction)clickCloseButton:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}


@end
