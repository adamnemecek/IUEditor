//
//  BBWidgetLibraryVC.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 12. 1..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUBox.h"
#import "IUDefinition.h"
/**
 @brief BBWidgetLibraryVC is responsible for widget selection in IUEditor

 When user want to insert new IU, she will interact with view.
 After user interaction, MainWindow calls notification, IUNoti_widgetSelectionChanged. Notification's user info has selected widget name as nsstring, with key IUNotiKey_selectedWidget. IUNotiKey_selectedWidget can be nil if user does not select any object


 */
@interface BBWidgetLibraryVC : NSViewController

/**
 set widgets in vc
 @param widgets: NSArray which contains NSDictionary which contains {@"name": group name, @"image": a group image, @"widgets": an array of nsstrings, which are widget-names}
 */
- (void)setWidgets:(NSArray *)widgets;


//////////////////////////////////////////////////
// for unit test only

@property (weak) IBOutlet NSPopUpButton *groupSelectPopupBtn;
@property (nonatomic) NSInteger selectedGroupIndex; // selected popup index
//////////////////////////////////////////////////

@end