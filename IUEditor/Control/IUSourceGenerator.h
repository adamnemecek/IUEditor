//
//  IUSourceController.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUBox.h"
#import "IUCompiler.h"
#import <WebKit/WebKit.h>

/**
 
 Bridge with IUBox and CanvasVC
 
 Manage source :
 1) Create Source
 2) Manage view port
 
 */

@protocol IUSourceGeneratorDelegate <NSObject> // = canvasVC

- (DOMHTMLStyleElement *)getElementbyId:(NSString*)idName;

@end

@interface IUSourceGenerator : NSObject

@property int viewPort;
@property IUCompiler *compiler;

- (void)setCanvasVC:(id <IUSourceGeneratorDelegate>)canvasVC;
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;

- (void)setNeedsDisplayHTML:(IUBox*)box;
- (void)setNeedsDisplayCSS:(IUBox*)box;

- (void)beginTransaction:(id)sender;
- (void)commitTransaction:(id)sender;

@end
