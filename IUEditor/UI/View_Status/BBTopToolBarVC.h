//
//  BBTopToolBarVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BBTopToolBarVC : NSViewController


/**
 @brief connection between BBWC's sourceManager & BBTopToolBarVC's children VCs
 */
- (void)setSourceManager:(id)sourceManager;

@end
