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
#define defaultFrameWidth 960
//for media-query default size(== maximum size는 default collection으로 분료)
#define IUCSSDefaultViewPort 9999

#define IUTabletSize 770
#define IUMobileSize 650


//for dragging (pasteboard)
static NSString * kUTTypeIUType  =  @"kUTTypeIUType";
static NSString * kUTTypeIUImageResource = @"kUTTypeIUImageResource";



#define definedPrefixIdentifiers @[@"IU",@"mce",@"mceu"]
#define definedIdentifers  @[@"id",@"ifdef",@"default"]


#endif
