//
//  IUTestWC.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUTestWC.h"

@interface IUTestWC ()

@end

@implementation IUTestWC

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)pressFail:(id)sender {
    return [self.delegate testWCReturned:NO];
}

- (IBAction)pressSuccess:(id)sender {
    return [self.delegate testWCReturned:YES];
}


@end
