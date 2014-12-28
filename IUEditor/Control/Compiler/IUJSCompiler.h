//
//  IUJSCompiler.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDCode.h"

@class IUCompiler;
@class IUSheet;
@class IUPage;

@interface IUJSCompiler : NSObject
@property IUCompiler *compiler;

- (JDCode *)JSCodeForSheet:(IUSheet *)sheet rule:(NSString*)rule;

/*

- (NSArray*)cssCodesForIUWithChildren:(IUBox*)iu rule:(NSString*)rule target:(IUTarget)target viewPort:(NSInteger)viewPort option:(NSDictionary *)option;

- (NSDictionary*)cssCodeDictionaryForIUWithChildren:(IUBox*)iu rule:(NSString*)rule target:(IUTarget)target viewPort:(NSInteger)viewPort option:(NSDictionary *)option;



- (

- (NSString *)jsInitSource:(IUSheet *)sheet storage:(BOOL)storage;
- (NSString *)jsInitFileName:(IUPage *)page;

- (NSString *)jsEventFileName:(IUPage *)page;
- (NSString *)jsEventSource:(IUPage*)document;

 */
@end
