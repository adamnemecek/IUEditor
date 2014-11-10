//
//  LMFontController.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 5. 28..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDCode.h"
#import "IUBox.h"

static NSString *LMFontName = @"name";
static NSString *LMFontCheckGoogleAPI = @"isGoogleFonts";
static NSString *LMFontGoogleAPIFamilyName = @"googleApiFamily";
static NSString *LMFontLightType = @"hasLight";
static NSString *LMFontBoldTypeTag = @"boldType";
static NSString *LMFontHeaderLink = @"link";
static NSString *LMFontFamilyName = @"font-family";
static NSString *LMFontNeedLoad = @"isLoadable";
static NSString *LMFontEditable = @"editalbe";

typedef enum{
    LMFontBoldTypeDefault,
    LMFontBoldTypeWebFont,
}LMFontBoldType;

@interface LMFontController : NSObject

#pragma mark - current font
@property NSString *currentFontName;
@property NSUInteger currentFontSize;

- (void)copyCurrentFontToIUBox:(IUBox *)iu;

#pragma mark - font list
@property NSMutableDictionary *fontDict;

+ (LMFontController *)sharedFontController;
- (void)loadFontList;
- (void)saveFontList;

- (NSString *)cssForFontName:(NSString *)fontName;
- (NSString *)fontNameForFontCSS:(NSString *)css;
- (BOOL)hasLight:(NSString *)fontName;

- (NSString *)mceFontList;

- (JDCode *)headerCodeForAllFont;
- (JDCode *)headerCodeForFont:(NSArray *)fontArray;

@end
