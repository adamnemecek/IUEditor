//
//  IUProject.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUResourceGroup.h"
#import "IUCompiler.h"
#import "IUSheetGroup.h"
#import "IUFileProtocol.h"
#import "IUServerInfo.h"

@class IUClass;

typedef enum _IUGitType{
    IUGitTypeNone = 0,
    IUGitTypeSource = 1,
    IUGitTypeOutput = 2
} IUGitType;

typedef enum {
    IUProjectTypeDefault,
    IUProjectTypeDjango,
    IUProjectTypeWordpress,
    IUProjectTypePresentation,
} IUProjectType;


//setting
static NSString * IUProjectKeyType = @"projectType";
static NSString * IUProjectKeyGit = @"git";
static NSString * IUProjectKeyHeroku = @"heroku";

//project.path : /~/~/abcd.iu
static NSString * IUProjectKeyIUFilePath = @"iuFilePath";

//appname : abcd
static NSString * IUProjectKeyAppName = @"appName";

static NSString * IUProjectKeyResourcePath = @"resPath";
static NSString * IUProjectKeyBuildPath = @"buildPath";
static NSString * IUProjectKeyConversion = @"conversion";

//resource groupname
static NSString *IUResourceGroupName = @"resource";
static NSString *IUJSResourceGroupName = @"js";
static NSString *IUImageResourceGroupName = @"image";
static NSString *IUVideoResourceGroupName = @"video";
static NSString *IUCSSResourceGroupName = @"css";

//iupage groupname
static NSString *IUPageGroupName = @"page";
static NSString *IUClassGroupName = @"class";


@interface IUProject : NSObject <IUFile, IUResourcePathProtocol, NSCoding, NSFileManagerDelegate>{
    IUSheetGroup *_pageGroup;
    IUSheetGroup *_classGroup;
    IUResourceGroup *_resourceGroup;
    IUServerInfo *_serverInfo;
    
    IUCompiler *_compiler;
    IUResourceManager *_resourceManager;
    IUIdentifierManager *_identifierManager;
    
    NSString  *_path;
    NSMutableArray *_mqSizes;
    
}
/**
 IUProject version control
 */
@property  NSString *IUProjectVersion;


//create project
+ (id)projectWithContentsOfPath:(NSString*)path;
+ (NSString *)stringProjectType:(IUProjectType)type;

/**
 @breif create project
 @param setting a dictionary which has IUProjectKeyAppName and IUProjectKeyDirectory
 */
-(id)initWithCreation:(NSDictionary*)options error:(NSError**)error;

/**
 @breif create project from other project (conversion)
 @param setting a dictionary which has IUProjectKeyAppName and IUProjectKeyDirectory
 */
-(id)initWithProject:(IUProject*)project options:(NSDictionary*)options error:(NSError**)error;


- (void)initializeResource;

/**
 css, js filename array
 */
- (NSArray *)defaultEditorCSSArray;
- (NSArray *)defaultOutputCSSArray;
- (NSArray *)defaultEditorJSArray;
- (NSArray *)defaultOutputJSArray;

//save project
- (BOOL)save;

//project properties
- (NSArray*)mqSizes;

/*
 @ important
 name , path are set by IUProjectDocument
 */
@property   (nonatomic) NSString *path;
@property   NSString    *name, *author, *favicon;
@property   BOOL enableMinWidth;



- (NSString*)absoluteBuildPath;
- (NSString*)absoluteBuildResourcePath;

//build
- (IUProjectType)projectType;
- (IUCompiler *)compiler;
- (BOOL)build:(NSError**)error;

//manager
- (IUIdentifierManager*)identifierManager;
- (IUResourceManager *)resourceManager;

- (NSArray*)allDocuments;
- (NSArray*)pageSheets;
- (NSArray*)classSheets;
- (IUClass *)classWithName:(NSString *)name;

/* get all IU in project */
- (NSSet*)allIUs;

- (BOOL)runnable;

// return groups
- (IUSheetGroup*)pageGroup;
- (IUSheetGroup*)classGroup;
- (IUResourceGroup *)resourceGroup;

- (void)addSheet:(IUSheet *)sheet toSheetGroup:(IUSheetGroup *)sheetGroup;
- (void)removeSheet:(IUSheet *)sheet toSheetGroup:(IUSheetGroup *)sheetGroup;

- (void)connectWithEditor;
- (void)setIsConnectedWithEditor;
- (BOOL)isConnectedWithEditor;

- (NSString*)absoluteBuildPathForSheet:(IUSheet*)sheet;

// server information
- (IUServerInfo*)serverInfo;

@property NSString *buildPath;
@property NSString *buildResourcePath;
- (void)resetBuildPath;

//undo manager
- (NSUndoManager *)undoManager;
@end