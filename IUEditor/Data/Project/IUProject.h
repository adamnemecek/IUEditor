//
//  IUProject.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUCompiler.h"
#import "IUSheetGroup.h"
#import "IUServerInfo.h"
#import "IUProjectProtocol.h"

@class IUClass;

@interface IUProject : IUFileItem <JDCoding, NSFileManagerDelegate, IUProjectProtocol> {
    IUSheetGroup *_pageGroup;
    IUSheetGroup *_classGroup;
    IUServerInfo *_serverInfo;
    
    IUCompiler *_compiler __deprecated;
    
    NSString  *_path;
    NSMutableArray *_mqSizes;
    
}

//class properties
- (NSArray *)widgetList;
- (NSArray *)compilerRules;
- (NSString *)defaultCompilerRule;


/**
 Make Project for untitled document
 */
- (id)initForUntitledDocument;
- (void)setAsStressTestMode;
+ (id)projectWithContentsOfPath:(NSString*)path;


//project properties
- (NSArray*)viewPorts;
- (NSInteger)maxViewPort;

// return groups
- (IUSheetGroup*)pageGroup;
- (IUSheetGroup*)classGroup;

#if DEBUG
//test 를 위해서 setting 가능하게 해놓음.
@property (nonatomic) id <IUSourceManagerProtocol> sourceManager;
#else
- (id <IUSourceManagerProtocol>) sourceManager;
#endif

// server information
- (IUServerInfo*)serverInfo;


/*
 @ important
 name , path are set by IUProjectDocument
 */
@property (nonatomic) NSString *path;
- (NSString *)resourceRootPath;

@property   NSString    *author, *favicon;
@property   BOOL enableMinWidth;


//followings are about build path control
- (void)resetBuildPath;

@property NSString *buildPath;
@property NSString *buildResourcePath;
- (NSString*)absoluteBuildPath;
- (NSString*)absoluteBuildResourcePath;



/**
 Used to set prefix of resource, such as css and js
 if buildResourcePrefix == nil,
 */
@property NSString *buildResourcePrefix;


- (BOOL)runnable;
- (void)connectWithEditor;
- (void)setIsConnectedWithEditor;
- (BOOL)isConnectedWithEditor;


























/////////////////////////////////////
//      Old Version                //
/////////////////////////////////////

//create project
+ (NSString *)stringProjectType:(IUProjectType)type __deprecated;


/**
 css, js filename array
 */
- (NSArray *)defaultOutputCSSArray __deprecated;
- (NSArray *)defaultEditorJSArray __deprecated;
- (NSArray *)defaultOutputJSArray __deprecated;







//build
- (IUProjectType)projectType;

//manager
- (IUIdentifierManager*)identifierManager;

- (NSArray*)allSheets;
- (NSArray*)allPages;

- (IUClass *)classWithName:(NSString *)name;

/* get all IU in project */
- (NSSet*)allIUs;


//- (IUResourceGroup *)resourceGroup;

- (void)addItem:(IUSheet *)sheet toSheetGroup:(IUSheetGroup *)sheetGroup;
- (void)removeItem:(IUSheet *)sheet toSheetGroup:(IUSheetGroup *)sheetGroup;


- (NSString*)absoluteBuildPathForSheet:(IUSheet*)sheet;

- (NSData *)lastCreatedData;
- (NSData *)createData;

@end

//setting
static NSString * const IUProjectKeyType = @"projectType";
static NSString * const IUProjectKeyGit = @"git";
static NSString * const IUProjectKeyHeroku = @"heroku";

//project.path : /~/~/abcd.iu
static NSString * const IUProjectKeyIUFilePath = @"iuFilePath";

//appname : abcd
static NSString * const IUProjectKeyAppName = @"appName";

static NSString * const IUProjectKeyResourcePath = @"resPath";
static NSString * const IUProjectKeyBuildPath = @"buildPath";
static NSString * const IUProjectKeyConversion = @"conversion";

//resource groupname
static NSString * const IUResourceGroupName = @"resource";

//iupage groupname
static NSString *const IUPageGroupName = @"page";
static NSString *const IUClassGroupName = @"class";