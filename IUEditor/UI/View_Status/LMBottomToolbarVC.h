//
//  LMToolbarVC.h
//  IUEditor
//
//  Created by jd on 3/31/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUSheet.h"

@interface LMBottomToolbarVC : NSViewController <NSComboBoxDelegate>

@property (nonatomic, weak) IUSheet    *sheet;

- (void)setConsoleViewEnable:(BOOL)enable;

- (IBAction)clickBorderBtn:(id)sender;

@end
