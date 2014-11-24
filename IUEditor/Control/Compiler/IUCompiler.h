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
- (NSString *)outputHTMLSource:(IUSheet*)document;
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
- (NSString *)imagePathWithImageName:(NSString *)imageName target:(IUTarget)target forFilePath:(IUFilePath)filePath;

/////////////////////////////////////////
//
//  storage mode
//

/**
 Return whole web source of sheet;
 @note: this function does not accept viewPort: always return as IUDefaultViewPort
 */
- (NSString *)webSource:(IUSheet *)document target:(IUTarget)target;

/* if IUTarget == IUTargetOutput, viewPort will be ignored */
- (IUCSSCode *)cssSource:(IUBox *)box target:(IUTarget)target viewPort:(int)viewPort;

/* if IUTarget == IUTargetOutput, viewPort will be ignored */
- (NSString* )htmlSource:(IUBox *)box target:(IUTarget)target viewPort:(int)viewPort;

@end