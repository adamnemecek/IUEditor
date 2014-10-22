//
//  NSMutableDictionary+IUTag.h
//  IUEditor
//
//  Created by JD on 3/19/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+IUTag.h"

#define IUCSSStringDictionary NSMutableDictionary

#define IUCSSUnit       char
#define IUCSSUnitNone    0
#define IUCSSUnitPixel   1
#define IUCSSUnitPercent 2


@interface NSMutableDictionary (IUTag)

-(void)putTag:(IUCSSTag)tag intValue:(int)intValue ignoreZero:(BOOL)ignoreZero unit:(IUCSSUnit)unit;
-(void)putTag:(IUCSSTag)tag floatValue:(float)intValue ignoreZero:(BOOL)ignoreZero unit:(IUCSSUnit)unit;
-(void)putTag:(NSString*)tag color:(NSColor*)color ignoreClearColor:(BOOL)ignoreClearColor;
-(void)putTag:(IUCSSTag)tag string:(NSString*)stringValue;

-(void)removeTag:(IUCSSTag)key;
@end

@interface NSDictionary (IUTag)
- (NSString*)hoverCSSCode;
- (NSString*)CSSCode;
@end