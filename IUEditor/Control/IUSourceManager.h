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
@class IUCompiler;

@protocol IUSourceManagerDelegate <NSObject> // = canvasVC

- (DOMHTMLStyleElement *)getElementbyId:(NSString*)idName;

@end

@interface IUSourceManager : NSObject

/* setting */
- (void)setCanvasVC:(id <IUSourceManagerDelegate>)canvasVC;
- (void)setCompiler:(IUCompiler *)compiler;

/* managing view port */
@property int viewPort;

/* called by box */
- (void)setNeedsUpdateHTML:(IUBox*)box;
- (void)setNeedsUpdateCSS:(IUBox*)box;
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;

/* working as transaction */
- (void)beginTransaction:(id)sender;
- (void)commitTransaction:(id)sender;

@end
