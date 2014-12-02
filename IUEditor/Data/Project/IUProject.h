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

typedef enum _IUGitType{
    IUGitTypeNone = 0,
    IUGitTypeSource = 1,
    IUGitTypeOutput = 2
} IUGitType;


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


@interface IUProject : NSObject <JDCoding, NSFileManagerDelegate, IUProjectProtocol, IUFileItemProtocol>{
    IUSheetGroup *_pageGroup;
    IUSheetGroup *_classGroup;
    IUServerInfo *_serverInfo;
    
    IUCompiler *_compiler __deprecated;
    
    NSString  *_path;
    NSMutableArray *_mqSizes;
    
}

//class properties
+ (NSArray *)widgetList;



/**
 Make Project at Temporary directory.
 Use Untitled document
 @brief create project at temporary directory
 */
- (id)initAtTemporaryDirectory;

//project properties
- (NSArray*)mqSizes;
- (NSInteger)maxViewPort;





#if DEBUG
//test 를 위해서 setting 가능하게 해놓음.
@property (nonatomic) id <IUSourceManagerProtocol> sourceManager;
@property (nonatomic) IUIdentifierManager *identifierManager;
#else
- (id <IUSourceManagerProtocol>) sourceManager;
- (IUIdentifierManager *) identifierManager;
#endif








////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//      Old Version                //
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////




//create project
+ (id)projectWithContentsOfPath:(NSString*)path __deprecated;
+ (NSString *)stringProjectType:(IUProjectType)type;



/**
 css, js filename array
 */
- (NSArray *)defaultOutputCSSArray;
- (NSArray *)defaultEditorJSArray;
- (NSArray *)defaultOutputJSArray;


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

//manager
- (IUIdentifierManager*)identifierManager;

- (NSArray*)allSheets;
- (NSArray*)pageSheets;
- (NSArray*)classSheets;
- (IUClass *)classWithName:(NSString *)name;

/* get all IU in project */
- (NSSet*)allIUs;

- (BOOL)runnable;

// return groups
- (IUSheetGroup*)pageGroup;
- (IUSheetGroup*)classGroup;
//- (IUResourceGroup *)resourceGroup;

- (void)addItem:(IUSheet *)sheet toSheetGroup:(IUSheetGroup *)sheetGroup;
- (void)removeItem:(IUSheet *)sheet toSheetGroup:(IUSheetGroup *)sheetGroup;

- (void)connectWithEditor;
- (void)setIsConnectedWithEditor;
- (BOOL)isConnectedWithEditor;

- (NSString*)absoluteBuildPathForSheet:(IUSheet*)sheet;

// server information
- (IUServerInfo*)serverInfo;

@property NSString *buildPath;
@property NSString *buildResourcePath;
- (void)resetBuildPath;


- (NSData *)lastCreatedData;
- (NSData *)createData;


@end