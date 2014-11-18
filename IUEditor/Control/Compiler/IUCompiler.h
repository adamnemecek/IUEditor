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
#import "IUResourceManager.h"
#import "IUCSSCompiler.h"
#import "IUDefinition.h"

@class IUCSSCode;
@class IUSheet;
@class IUPage;
@class IUResourceManager;
@class IUWordpressProject;

static NSString * IUCompilerTagOption = @"tag";

typedef enum _IUCompileRule{
    IUCompileRuleDefault,
    IUCompileRuleDjango,
    IUCompileRuleWordpress,
    IUCompileRulePresentation,
}IUCompileRule;

@protocol IUCompilerProtocol <NSObject>
- (BOOL)hasLink:(IUBox *)iu;

@end




@interface IUCompiler : NSObject <IUCompilerProtocol>

@property (weak, nonatomic) IUResourceManager *resourceManager;
@property (nonatomic) IUCompileRule    rule;
@property NSString *webTemplateFileName;


//html source
- (JDCode *)htmlCode:(IUBox *)iu target:(IUTarget)target;
- (NSString *)editorSource:(IUSheet*)document mqSizeArray:(NSArray *)mqSizeArray;

//css code
- (NSString *)outputCSSSource:(IUSheet*)document mqSizeArray:(NSArray *)mqSizeArray;
- (IUCSSCode*)cssCodeForIU:(IUBox*)iu;


//meta source
- (JDCode *)wordpressMetaDataSource:(IUWordpressProject *)project;

//js source
- (JDCode *)outputJSInitializeSource:(IUSheet *)document;

//clip art source
- (NSArray *)outputClipArtArray:(IUSheet *)document;


//default function
- (NSString *)imagePathWithImageName:(NSString *)imageName target:(IUTarget)target;

/////////////////////////////////////////
//
//  storage mode
//

/**
 Return whole web source of sheet;
 WebSource = HTML + CSS
 */

- (NSString *)editorWebSource:(IUSheet *)document viewPort:(NSInteger)viewPort frameWidth:(NSInteger)frameWidth;


/* Will be saved as page file */
- (NSString *)outputHTMLSource:(IUPage *)document;

/* Will be saved as CSS file */
- (NSString *)outputCSSSource_storage:(IUPage *)page;

- (IUCSSCode *)editorCSSCode:(IUBox *)box viewPort:(NSInteger)viewPort;

/* if IUTarget == IUTargetOutput, viewPort will be ignored */
- (IUCSSCode *)cssCode:(IUBox *)box target:(IUTarget)target viewPort:(NSInteger)viewPort;

/* if IUTarget == IUTargetOutput, viewPort will be ignored */
- (NSString* )editorHTMLString:(IUBox *)box viewPort:(NSInteger)viewPort;

- (NSString *)jsEventFileName:(IUPage *)document;
- (NSString *)jsEventSource:(IUPage*)document;

- (NSString *)jsInitFileName:(IUPage *)document;
- (NSString *)jsInitSource:(IUPage*)document;

- (void)setJSBasePath:(NSString*)urlPath;
- (void)setCSSBasePath:(NSString*)urlPath;
- (void)setResourceBasePath:(NSString *)urlPath;

@end