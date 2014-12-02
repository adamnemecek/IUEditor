//
//  IUProjectProtocol.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 10..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#ifndef IUEditor_IUProjectProtocol_h
#define IUEditor_IUProjectProtocol_h

@class IUIdentifierManager;
@class IUClass;
@class IUCompiler;


typedef enum {
    IUProjectTypeDefault,
    IUProjectTypeDjango,
    IUProjectTypeWordpress,
    IUProjectTypePresentation,
} IUProjectType;


@protocol IUProjectProtocol <NSObject>



@optional

/* media query view ports */
- (NSArray *)mqSizes;
- (NSInteger)maxViewPort;

/* support manager for IUBox */
- (IUIdentifierManager*)identifierManager;

- (NSString*)IUProjectVersion;
- (IUClass *)classWithName:(NSString *)name;


- (IUCompiler *)compiler __deprecated;
- (BOOL)enableMinWidth __deprecated;

- (IUProjectType)projectType;
- (NSString*)absoluteBuildPath;

- (NSString *)author;
- (NSString *)name;
- (NSString *)favicon;

- (NSArray *)defaultEditorJSArray;

- (NSArray *)defaultCopyJSArray;
- (NSArray *)defaultOutputJSArray;
- (NSArray *)defaultOutputIEJSArray;

@end

#endif
