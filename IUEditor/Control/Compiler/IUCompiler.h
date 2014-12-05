//
//  IUCompiler.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUBox.h"
#import "IUCarousel.h"
#import "JDCode.h"
#import "IUCSSCompiler.h"
#import "IUDefinition.h"

@class IUCSSCode;
@class IUSheet;
@class IUPage;
@class IUWordpressProject;

static NSString * IUCompilerTagOption = @"tag";

@protocol IUCompilerProtocol <NSObject>
- (BOOL)hasLink:(IUBox *)iu;
@end


@interface IUCompiler : NSObject <IUCompilerProtocol>

@property (nonatomic, copy) NSString    *rule;

/**
 Return whole web source of sheet;
 WebSource = HTML + CSS
 */

- (NSString *)editorSheetSource:(IUSheet *)document viewPort:(NSInteger)viewPort canvasWidth:(NSInteger)frameWidth;
- (BOOL)editorIUSource:(IUBox *)box viewPort:(NSInteger)viewPort htmlSource:(NSString **)html nonInlineCSSSource:(NSDictionary **)nonInlineCSS;
- (IUCSSCode *)editorIUCSSSource:(IUBox *)iu viewPort:(NSInteger)viewPort ;

- (BOOL)outputHTMLSource:(IUPage *)document html:(NSString **)html css:(NSString **)css;

- (NSString *)jsEventFileName:(IUPage *)document;
- (NSString *)jsEventSource:(IUPage*)document;

- (NSString *)jsInitFileName:(IUPage *)document;
- (NSString *)jsInitSource:(IUPage*)document storage:(BOOL)storage;

- (void)setJSBasePath:(NSString*)urlPath;
- (void)setCSSBasePath:(NSString*)urlPath;
- (void)setResourceBasePath:(NSString *)urlPath;

//meta source
- (JDCode *)wordpressMetaDataSource:(IUWordpressProject *)project;

//clip art source
- (NSArray *)outputClipArtArray:(IUSheet *)document;


//default function
- (NSString *)imagePathWithImageName:(NSString *)imageName target:(IUTarget)target;

@end