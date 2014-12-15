//
//  IUSourceController.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "IUSourceManagerProtocol.h"
#import "WebCanvasView.h"


/**
 
 Bridge with IUBox and CanvasVC
 
 Manage source :
 1) Create Source
 2) Manage view port
 
 */
@class IUBox;
@class IUSheet;
@class IUCompiler;
@class IUProject;
@class IUController;

@protocol IUSourceManagerDelegate <NSObject> // = canvasVC

@required
/* get WebView. We Manage source of it */
- (WebCanvasView *)webCanvasView;

@optional
/* prepare update. for example, text editor enable/disable */
- (void)beginUpdate;
- (void)commitUpdate;

/* call javascript */
- (id)evaluateWebScript:(NSString *)script;
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;

/* remove iu - grid view */
-(void)IURemoved:(IUBox *)iu;

@end

@interface IUSourceManager : NSObject <IUSourceManagerProtocol>

/* setting
 @Note : Never call these functions twice. */
- (void)setCanvasVC:(id <IUSourceManagerDelegate>)canvasVC;
- (void)setCompiler:(IUCompiler *)compiler;


/**
 Compiler rule is NSString: show that string directly in commandVC
 */
@property NSString *compilerRule;
- (NSArray *)availableCompilerRule;

/**
 Document base path can be replaced by setting project
 */
- (void)setDocumentBasePath:(NSString*)documentBasePath;

/**
 @Note: setting project will replace document base path
 */
- (void)setProject:(IUProject*)project;

/* load a sheet */
- (void)loadSheet:(IUSheet *)sheet;
- (void)loadSheet:(IUSheet *)sheet viewport:(NSInteger)viewport;

/* called by box */
- (void)setNeedsUpdateHTML:(IUBox*)box;
- (void)setNeedsUpdateCSS:(IUBox*)box;
/* called js by box */
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;
- (id)evaluateWebScript:(NSString *)script;


/* working as transaction */
- (void)beginTransaction:(id)sender;
- (void)commitTransaction:(id)sender;


/*** DEBUG FUNCTIONS ***/
- (NSString *)source;

/* build */
- (BOOL)build:(NSError **)error;

- (NSString*)absoluteBuildPathForSheet:(IUSheet *)sheet;

@property (weak) IUController *iuController;
@end
