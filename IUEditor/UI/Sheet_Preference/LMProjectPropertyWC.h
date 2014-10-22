//
//  LMProjectPropertyWC.h
//  IUEditor
//
//  Created by seungmi on 2014. 7. 16..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUProject.h"

@interface LMProjectPropertyWC : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>

- (id)initWithWindowNibName:(NSString *)windowNibName withIUProject:(IUProject *)project;

@end
