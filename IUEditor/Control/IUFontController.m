//
//  IUFontController.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 5. 28..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUFontController.h"

static IUFontController *gFontController = nil;


@implementation IUFontController

+ (IUFontController *)sharedFontController{
    if(gFontController == nil){
        gFontController = [[IUFontController alloc] init];
        [gFontController loadFontList];
    }
    return gFontController;
}
- (id)init{
    self = [super init];
    if(self){
        _lastUsedFontName = @"Helvetica";
        _lastUsedFontSize = 12;
    }
    return self;
}
#pragma mark - default setting for font
- (NSArray *)fontSizeArray{
    return  @[@(6), @(8), @(9), @(10), @(11), @(12),
              @(14), @(18), @(21), @(24), @(30), @(36), @(48), @(60), @(72)];
}
- (NSArray *)fontLetterSpacingArray{
    return @[@(0), @(-2.0), @(-1.0), @(0.5), @(1.0), @(2.0)];
}

- (NSArray *)fontLineHeightArray{
    return @[@(1.0), @(2.0)];
}


#pragma mark - current font

- (void)setLastUsedFontToIUBox:(IUBox *)iu{
    
    NSString *fontName = iu.cascadingStyleStorage.fontName;
    if(fontName == nil){
        iu.currentStyleStorage.fontName = _lastUsedFontName;
    }
    
    NSNumber *fontSize = iu.cascadingStyleStorage.fontSize;
    if(fontSize == nil){
        iu.currentStyleStorage.fontSize = @(_lastUsedFontSize);
    }    
}



#pragma mark - font list

- (void)initializeFontList{

    NSString *fontListPath = [[NSBundle mainBundle] pathForResource:@"defaultFont" ofType:@"plist"];
    NSDictionary *defaultFontList = [NSDictionary dictionaryWithContentsOfFile:fontListPath];
    _fontDict = [defaultFontList mutableCopy];
}

- (void)loadFontList{
    //TODO: 나중에 정리
    [self initializeFontList];
//    NSDictionary *userFontDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"fontList"];
    NSDictionary *userFontDict = nil;
    if(userFontDict == nil || userFontDict.count == 0){
        [self initializeFontList];
    }
    else{
        [_fontDict addEntriesFromDictionary:[userFontDict mutableCopy]];
    }
}

- (void)saveFontList{
    
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    [userData setObject:_fontDict forKey:@"fontList"];
    
}

- (NSString *)cssForFontName:(NSString *)fontName{
    return [_fontDict objectForKey:fontName][LMFontFamilyName];
}
- (NSString *)fontNameForFontCSS:(NSString *)css{
    for(NSString *key in _fontDict){
        NSString *keyCSS = [[_fontDict objectForKey:key][LMFontFamilyName] stringByReplacingOccurrencesOfString:@"'" withString:@""];
        keyCSS = [keyCSS stringByTrim];
        if([keyCSS isEqualToString:[css stringByTrim]]){
            return key;
        }
    }
    return nil;
}
- (NSString *)linkForFontName:(NSString *)fontName{
    return [_fontDict objectForKey:fontName][LMFontHeaderLink];
}
- (BOOL)isNeedHeader:(NSString *)fontName{
    
    if([_fontDict objectForKey:fontName]){
        return [[_fontDict objectForKey:fontName][LMFontNeedLoad] boolValue];
    }
    return NO;
}
- (BOOL)isGoogleWebFontApi:(NSString *)fontName{
    if([_fontDict objectForKey:fontName]){
        return [[_fontDict objectForKey:fontName][LMFontCheckGoogleAPI] boolValue];
    }
    return NO;
}

- (BOOL)hasLight:(NSString *)fontName{
    if([_fontDict objectForKey:fontName]){
        return [[_fontDict objectForKey:fontName][LMFontLightType] boolValue];
    }
    return NO;
}

- (NSString *)googleWebFontApiName:(NSString *)fontName{
    if([_fontDict objectForKey:fontName]){
        return [_fontDict objectForKey:fontName][LMFontGoogleAPIFamilyName];
    }
    return nil;
}

- (LMFontBoldType)boldtype:(NSString *)fontName{
    if([_fontDict objectForKey:fontName]){
        return [[_fontDict objectForKey:fontName][LMFontBoldTypeTag] intValue];
    }
    return LMFontBoldTypeDefault;
}

- (JDCode *)headerCodeForAllFont{
    NSMutableArray *allFonts = [NSMutableArray array];
    
    for(NSString *fontName in _fontDict){
        if([self hasLight:fontName]){
            [allFonts addObject:@{IUCSSTagFontName:fontName, IUCSSTagFontWeight:@"300"}];
        }
        [allFonts addObject:@{IUCSSTagFontName:fontName, IUCSSTagFontWeight:@"400"}];
        [allFonts addObject:@{IUCSSTagFontName:fontName, IUCSSTagFontWeight:@"700"}];
    }
    
    return [self headerCodeForFont:allFonts];
}


- (JDCode *)headerCodeForFont:(NSArray *)fontArray{
    NSMutableDictionary *googleFontFamily = [NSMutableDictionary dictionary];
    NSMutableDictionary *linkDict = [NSMutableDictionary dictionary];
    
    //find imported font
    for(NSDictionary *fontDict in fontArray){
        if([self isNeedHeader:fontDict[IUCSSTagFontName]]){
            NSString *fontName =  fontDict[IUCSSTagFontName];
            if([self isGoogleWebFontApi:fontName]){
                NSString *fontWeight = fontDict[IUCSSTagFontWeight];
                if(fontWeight == nil){
                    fontWeight = @"400";
                }
                NSString *currentfontWeight = googleFontFamily[fontName];
                if(currentfontWeight == nil){
                    googleFontFamily[fontName] = fontWeight;
                }
                else{
                    if([currentfontWeight containsString:fontWeight] == NO){
                        if([fontWeight isEqualToString:@"700"]  && [self boldtype:fontName] == LMFontBoldTypeWebFont){
                            googleFontFamily[fontName] = [currentfontWeight stringByAppendingFormat:@",%@", fontWeight];
                        }
                        else if([fontWeight isEqualToString:@"700"] == NO){
                            googleFontFamily[fontName] = [currentfontWeight stringByAppendingFormat:@",%@", fontWeight];
                        }
                    }
                }
                
            }
            else{
                //add pure link
                //e.g.) Hanna font, earlyaccess link
                if([linkDict objectForKey:fontName] == nil){
                    [linkDict setObject:[self linkForFontName:fontName] forKey:fontName];
                }
            }
            
        }
    }
    
    //googlefont
    NSMutableString *googleFont = [NSMutableString string];
    int index=0;
    for(NSString *fontName in googleFontFamily){
        NSString *apiFamily = [self googleWebFontApiName:fontName];
        [googleFont appendString:apiFamily];
        [googleFont appendString:@":"];
        [googleFont appendString:googleFontFamily[fontName]];
        
        index++;
        if(index < googleFontFamily.count){
            [googleFont appendString:@"|"];
        }
    }
    
    JDCode *code = [[JDCode alloc] init];
    if(googleFont.length > 0){
        [code addCodeWithFormat:@"<link href='http://fonts.googleapis.com/css?family=%@' rel='stylesheet' type='text/css'>", googleFont];
    }
    for(NSString *link in linkDict.allValues){
        [code addCodeLine:link];
    }
    
    
    return code;
}

- (NSString *)mceFontList{
    NSMutableString *fontList = [NSMutableString string];
    [fontList appendString:@"\""];
    
    for(NSString *fontName in _fontDict){
        NSString *cssString = [self cssForFontName:fontName];
        [fontList appendFormat:@"%@=%@;", fontName, cssString];
    }
    
    [fontList appendString:@"\""];
    return fontList;
}

@end