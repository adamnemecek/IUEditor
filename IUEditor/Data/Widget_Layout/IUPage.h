//
//  IUPage.h
//  IUEditor
//
//  Created by jd on 3/18/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//


#import "IUBox.h"
#import "IUSheet.h"
#import "IUPageContent.h"
#import "IUHeader.h"
#import "IUFooter.h"
#import "IUSidebar.h"


typedef enum{
    IUPageLayoutNone, //nothing
    IUPageLayoutDefault, //header+footer
    IUPageLayoutSideBarOnly, //sidebar
    IUPageLayoutSideBar, //header+footer+sidebar
    IUPageLayoutSideBar2, //header+footer+sidebar(header위로)
    
}IUPageLayout;

static NSString *kIUPageLayout = @"layout";

@class IUPageContent;
@class IUImport;
/**
  A page class for IU Framework.
 @note IUPage has no children. Do not use 'addIU' function. Program NSAssert failure would be occured immediatly.
       If background is not set, IUPage would never return children.
 */
@interface IUPage : IUSheet



//meta tag
@property (nonatomic) NSString *title, *keywords, *desc, *metaImage;


@property NSString *extraCode;
@property NSString *googleCode;


//layout children
@property IUPageLayout layout;
@property IUHeader *header;
@property IUFooter *footer;
@property IUSidebar *sidebar;
-(IUPageContent *)pageContent;

@end