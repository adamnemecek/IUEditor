//
//  IUCompiler.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUBox.h"
#import "JDCode.h"

@class IUCSSCode;
@class IUSheet;
@class IUPage;
@class IUWordpressProject;

static NSString * const IUCompilerTagOption = @"tag";

@protocol IUCompilerProtocol <NSObject>
- (BOOL)hasLink:(IUBox *)iu;
@end


@interface IUCompiler : NSObject <IUCompilerProtocol>

@property (nonatomic, copy) NSString    *rule;

/**
 Return whole web source of sheet;
 WebSource = HTML + CSS
 */
- (NSString *)editorSource:(IUBox *)box viewPort:(NSInteger)viewPort canvasWidth:(NSInteger)frameWidth;

- (IUCSSCode *)editorIUCSSSource:(IUBox *)iu viewPort:(NSInteger)viewPort ;
- (BOOL)editorIUSource:(IUBox *)box htmlIDPrefix:(NSString *)htmlIDPrefix viewPort:(NSInteger)viewPort htmlSource:(NSString **)html nonInlineCSSSource:(NSDictionary **)nonInlineCSS;

- (BOOL)outputHTMLSource:(IUPage *)document resourcePrefix:(NSString *)resourcePrefix html:(NSString **)html css:(NSString **)css;

- (NSString *)jsEventFileName:(IUPage *)document;
- (NSString *)jsEventSource:(IUPage*)document;

- (NSString *)jsInitFileName:(IUPage *)document;
- (NSString *)jsInitSource:(IUPage*)document storage:(BOOL)storage;

- (void)setJSBasePath:(NSString*)urlPath;
- (void)setCSSBasePath:(NSString*)urlPath;
- (void)setResourceBasePath:(NSString *)urlPath;

//meta source
- (JDCode *)wordpressMetaDataSource:(IUWordpressProject *)project;

@end