//
//  IUSheet.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUCompiler.h"
#import "IUBox.h"
#import "IUIdentifierManager.h"
#import "IUFileItem.h"


@class IUSheetGroup;

@interface IUSheet : IUBox <IUFileItemProtocol>

@property CGFloat ghostX, ghostY, ghostOpacity;
@property NSString *ghostImageName;

/**
 It is for build option, not saved
 */
@property BOOL hasEvent;

#pragma mark editor source
-(NSString*)editorSource __deprecated;

#pragma mark output Source
- (NSString*)outputHTMLSource __deprecated;
- (NSString*)outputCSSSource __deprecated;
- (JDCode *)outputInitJSCode __deprecated;
- (NSArray *)outputArrayClipArt __deprecated;

-(NSArray*)widthWithCSS;
// Not using : commented on JD. 14.11.13
//-(IUBox *)selectableIUAtPoint:(CGPoint)point;

- (BOOL)containClass:(Class)class;
- (NSDictionary *)eventVariableDict;

@property (weak) id <IUFileItemProtocol, JDCoding> parentFileItem;

@end