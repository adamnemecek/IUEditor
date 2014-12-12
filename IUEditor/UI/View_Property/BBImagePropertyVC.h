//
//  BBImagePropertyVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBDefaultPropertyVC.h"
#import "BBJSManagerProtocol.h"

/**
 @brief BBImagePropertyVC manages image or background image
 */
@interface BBImagePropertyVC : BBDefaultPropertyVC <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) id<BBJSManagerProtocol> jsManager;

@end
