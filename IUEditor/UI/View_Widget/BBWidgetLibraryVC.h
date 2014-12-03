//
//  BBWidgetLibraryVC.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 12. 1..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUBox.h"

@interface BBWidgetLibraryVC : NSViewController

- (void)setWidgets:(NSArray *)widgets;


/* for unit test only */
@property (weak) IBOutlet NSPopUpButton *groupSelectPopupBtn;
- (NSArray *)widgetInfosInCurrentSelectedGroup;

@end

/**
 Following part should be used in unittest only
 */
@interface BBWidgetLibraryVC(UnitTest)


@end