//
//  IUDefinition.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 28..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#ifndef IUCanvas_IUDefinition_h
#define IUCanvas_IUDefinition_h

//for makeing default size view size (initialize)
#define IUDefaultViewPort 960


#define IUTabletSize 770
#define IUMobileSize 650


//for dragging (pasteboard)
static NSString * kUTTypeIUType  =  @"kUTTypeIUType";
static NSString * kUTTypeIUImageResource = @"kUTTypeIUImageResource";


#define definedPrefixIdentifiers @[@"IU",@"mce",@"mceu"]
#define definedIdentifers  @[@"id",@"ifdef",@"default"]

//text editor mode
//editable class can change attributes
//addible class only can add or remove text
#define IUTextEditableClass @"editable"
#define IUTextAddibleClass @"addible"


typedef enum _IUTarget{
    IUTargetEditor = 1,
    IUTargetOutput = 2,
    IUTargetBoth = 3,
} IUTarget;


typedef enum _IUUnit{
    IUUnitNone,
    IUUnitPixel,
    IUUnitPercent,
} IUUnit;

/******************************
 
 Notification definition
 
 *******************************/
extern NSString *const IUWidgetLibrarySelectionDidChangeNotification;  // called at widget library
extern NSString *const IUWidgetLibraryKey;
extern NSString *const IUWidgetLibrarySender;
extern NSString *const IUKey;
extern NSString *const IUValue;

extern NSString *const IUCompileRuleHTML;
extern NSString *const IUCompileRuleDjango;
extern NSString *const IUCompileRulePresentation;
extern NSString *const IUCompileRuleWordpress;

extern NSString *const IUProjectModeKey;
extern NSString *const IUProjectModeStress;
extern NSString *const IUProjectModeNormal;

extern NSString *const kIUNotificationSheetSelection;



/******************************
 
 Code decorator
 
 *******************************/

 
#define _binding_
#define _observing_

#endif