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


@class IUSheetGroup;

@interface IUSheet : IUBox

@property CGFloat ghostX, ghostY, ghostOpacity;
@property NSString *ghostImageName;

/**
 It is for build option, not saved
 */
@property BOOL hasEvent;

#pragma mark editor source
-(NSString*)editorSource;

#pragma mark output Source
- (NSString*)outputHTMLSource;
- (NSString*)outputCSSSource;
- (JDCode *)outputInitJSCode;
- (NSArray *)outputArrayClipArt;

-(NSArray*)widthWithCSS;
-(IUBox *)selectableIUAtPoint:(CGPoint)point;

- (BOOL)containClass:(Class)class;

@property (weak) IUSheetGroup *group;

@end