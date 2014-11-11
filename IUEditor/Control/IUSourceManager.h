//
//  IUSourceController.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

/**
 
 Bridge with IUBox and CanvasVC
 
 Manage source :
 1) Create Source
 2) Manage view port
 
 */
@class IUBox;
@class IUSheet;
@class IUCompiler;

@protocol IUSourceManagerDelegate <NSObject> // = canvasVC

/* get WebView. We Manage source of it */
- (WebView *)webView;

/* prepare update. for example, text editor enable/disable */
- (void)beginUpdate;
- (void)commitUpdate;

/* call javascript */
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;

@end

@interface IUSourceManager : NSObject

/* setting
 @Note : Never call these functions twice. */
- (void)setCanvasVC:(id <IUSourceManagerDelegate>)canvasVC;
- (void)setCompiler:(IUCompiler *)compiler;
- (void)setDocumentBasePath:(NSString*)documentBasePath;

/* managing view port */
@property int viewPort;

/* load a sheet */
- (void)loadSheet:(IUSheet*)sheet;

/* called by box */
- (void)setNeedsUpdateHTML:(IUBox*)box;
- (void)setNeedsUpdateCSS:(IUBox*)box;
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;

/* working as transaction */
- (void)beginTransaction:(id)sender;
- (void)commitTransaction:(id)sender;


/*** DEBUG FUNCTIONS ***/
- (NSString *)source;

@end
