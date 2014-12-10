//
//  BBPropertyToolBarVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BBDefaultPropertyVC.h"
#import "BBJSManagerProtocol.h"

@interface BBPropertyToolBarVC : BBDefaultPropertyVC

@property (weak) id<BBJSManagerProtocol> jsManager;

@end
