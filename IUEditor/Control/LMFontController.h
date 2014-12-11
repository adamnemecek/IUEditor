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

static NSString *const LMFontName = @"name";
static NSString *const LMFontCheckGoogleAPI = @"isGoogleFonts";
static NSString *const LMFontGoogleAPIFamilyName = @"googleApiFamily";
static NSString *const LMFontLightType = @"hasLight";
static NSString *const LMFontBoldTypeTag = @"boldType";
static NSString *const LMFontHeaderLink = @"link";
static NSString *const LMFontFamilyName = @"font-family";
static NSString *const LMFontNeedLoad = @"isLoadable";
static NSString *const LMFontEditable = @"editalbe";

typedef enum{
    LMFontBoldTypeDefault,
    LMFontBoldTypeWebFont,
}LMFontBoldType;


@interface LMFontController : NSObject
#pragma mark - default font setting

+ (LMFontController *)sharedFontController;


- (NSArray *)fontSizeArray;
- (NSArray *)fontLetterSpacingArray;

#pragma mark - current font
@property NSString *currentFontName;
@property NSUInteger currentFontSize;

- (void)setCurrentFontToIUBox:(IUBox *)iu;

#pragma mark - font list
/**
 key : font name
 value : css
 */
@property (readonly) NSMutableDictionary *fontDict;


- (void)loadFontList;
- (void)saveFontList;

- (NSString *)cssForFontName:(NSString *)fontName;
- (NSString *)fontNameForFontCSS:(NSString *)css;
- (BOOL)hasLight:(NSString *)fontName;

/**
 used for tiny mce
 */
- (NSString *)mceFontList;

- (JDCode *)headerCodeForAllFont;
- (JDCode *)headerCodeForFont:(NSArray *)fontArray;

@end