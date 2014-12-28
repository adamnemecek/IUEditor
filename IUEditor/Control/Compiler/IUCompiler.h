//
//  IUCompiler.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUBox.h"
#import "IUProject.h"
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
- (NSString *)editorSource:(IUBox *)box viewPort:(NSInteger)viewPort;

- (IUCSSCode *)editorIUCSSSource:(IUBox *)iu viewPort:(NSInteger)viewPort ;
- (BOOL)editorIUSource:(IUBox *)box htmlIDPrefix:(NSString *)htmlIDPrefix viewPort:(NSInteger)viewPort htmlSource:(NSString **)html nonInlineCSSSource:(NSDictionary **)nonInlineCSS;


/**
 Build Structure Concept:
 
 @brief Build IU Project
 @note Only build page file
 @code
    group1/index.html
    group2/group3/index.html
    group2/group3/loremipsum.html
 
    !'res', 'common', 'css', 'js', 'clipart' is pre-defined
    res/common/iu.js
    res/common/iu-frame.js ...
    res/common/iu.css
    
    res/css/group1/index.css
    res/css/component/header.css
 
    res/js/group1/index.js
    res/js/component/header.js
 
    res/clipart/a.jpg
 
    res/res_group1/image1.jpg
    res/res_group1/image1.png
 */
- (BOOL)build:(IUProject *)project rule:(NSString *)rule error:(NSError **)error;

- (void)setEditorResourceBasePath:(NSString *)path;

@property NSString *outputJSPathPrefix;
@property NSString *outputIEJSPathPrefix;
@property NSString *outputCSSPathPrefix;


//meta source
- (JDCode *)wordpressMetaDataSource:(IUWordpressProject *)project;

@end