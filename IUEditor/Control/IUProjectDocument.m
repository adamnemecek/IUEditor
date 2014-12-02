    //
//  IUProjectDocument.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 6. 9..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUProjectDocument.h"
#import "IUProjectController.h"

#import "JDFileUtil.h"

static NSString *projectJsonData = @"projectJsonData";

//set metadata
static NSString *metaDataFileName = @"metaData.plist";
static NSString *metaDataIUVersion = @"IUVersion";


@interface IUProjectDocument ()

@property (strong) NSFileWrapper *documentFileWrapper;
@property NSMutableDictionary *metaDataDict;

@end

@implementation IUProjectDocument{
    BOOL isLoaded;
    NSFileWrapper *_imageFileWrapper;
    NSFileWrapper *_videoFileWrapper;
}

- (id)init{
    self = [super init];
    if(self){
        //allocation identifiermanager
        _identifierManager = [[IUIdentifierManager alloc] init];
        
        //allocation resource root
        _resource = [[IUResourceRootItem alloc] init];
        
        //allocation metadata
        _metaDataDict = [NSMutableDictionary dictionary];
    

    }
    return self;
}

- (void)loadCurrentMetaDictionary{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [_metaDataDict setObject:version forKey:metaDataIUVersion];
}

- (NSString *)version{
    return [self.metaDataDict objectForKey:metaDataIUVersion];
}

//open document
- (id)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError{
    return [super initWithContentsOfURL:url ofType:typeName error:outError];
}

//open autosaving document
- (id)initForURL:(NSURL *)urlOrNil withContentsOfURL:(NSURL *)contentsURL ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError{
    return [super initForURL:urlOrNil withContentsOfURL:contentsURL ofType:typeName error:outError];
}

//make new document
- (id)initWithType:(NSString *)typeName error:(NSError *__autoreleasing *)outError{
    self = [super initWithType:typeName error:outError];
    if(self){

    }
    return self;
}

- (BOOL)makeNewProjectWithOption:(NSDictionary *)option URL:(NSURL *)url{
    if ([option objectForKey:IUProjectKeyConversion]) {
        /*
         FIXME: converting
        IUProjectType projectType = [[option objectForKey:IUProjectKeyType] intValue];
        Class projectFactory = NSClassFromString([IUProject stringProjectType:projectType]);
        
        NSError *error;
        IUProject *newProject = [(IUProject*)[projectFactory alloc] initWithProject:[option objectForKey:IUProjectKeyConversion] options:option error:&error];
        if (error != nil) {
            NSAssert(0, @"");
        }
        _project = newProject;
        return YES;
         */
        return NO;
    }
    
    else {
        NSMutableDictionary *projectDict;
        IUProjectType projectType;
        if(option){
            projectDict = [option mutableCopy];
            projectType = [[option objectForKey:IUProjectKeyType] intValue];
            [projectDict removeObjectForKey:IUProjectKeyType];
        }
        else{
            projectType = IUProjectTypeDefault;
            projectDict = [NSMutableDictionary dictionary];
            [projectDict setObject:@(NO) forKey:IUProjectKeyGit];
            [projectDict setObject:@(NO) forKey:IUProjectKeyHeroku];
        }
        
        NSString *filePath = [url relativePath];
        NSString *appName = [[url lastPathComponent] stringByDeletingPathExtension];
        
        [projectDict setObject:filePath forKey:IUProjectKeyIUFilePath];
        [projectDict setObject:appName forKey:IUProjectKeyAppName];
        
        
        
        IUProject *newProject = [[NSClassFromString([IUProject stringProjectType:projectType]) alloc] initAtTemporaryDirectory];
        if(newProject){
            _project = newProject;
            [self.identifierManager registerIUs:_project.allSheets];
            
            return YES;
        }
        return NO;
    }
}

#pragma mark - menu

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    
    if(menuItem.action == @selector(duplicateDocument:)){
        return NO;
    }
    
    return [super validateMenuItem:menuItem];
}

#pragma mark -


- (LMWC *)lemonWindowController{
    if([[self windowControllers] count] > 0){
        return [[self windowControllers] objectAtIndex:0];
    }
    return nil;
}


- (void)makeWindowControllers{
    LMWC *wc = [[LMWC alloc] initWithWindowNibName:@"LMWC"];
    [self addWindowController:wc];
    
}

- (void)removeWindowController:(NSWindowController *)windowController{
    
    if([windowController isKindOfClass:[LMWC class]]){
        LMWC *wc = (LMWC *)windowController;
        [wc prepareDealloc];
    }
    [super removeWindowController:windowController];
}



- (void)showWindows{
    [super showWindows];
    [self showLemonSheet];
}

- (void)showLemonSheet{
    [self.undoManager disableUndoRegistration];
    
    if(isLoaded && [self lemonWindowController]){
        [[self lemonWindowController] reloadNavigation];
        [[self lemonWindowController] reloadCurrentDocument:self];
    }
    else if([self lemonWindowController]){
        [[self lemonWindowController] selectFirstDocument];
        isLoaded = YES;
    }
    
    [self.undoManager enableUndoRegistration];
    
}

- (NSString *)displayName{
    return [NSString stringWithFormat:@"%@ - %@.iu", NSStringFromClass([_project class]), _project.name];
}

- (void)changeProjectPath:(NSURL *)fileURL{
    NSString *filePath = [fileURL relativePath];
    NSString *appName = [[fileURL lastPathComponent] stringByDeletingPathExtension];
    
    
    if(_project && [filePath isEqualToString:_project.path] == NO){
        [self.undoManager disableUndoRegistration];
        _project.name = appName;
        _project.path = filePath;
        [_resource loadFromPath:[filePath stringByAppendingPathComponents:@[@"resource"]]];
        
        [self.undoManager enableUndoRegistration];
        
        [self showLemonSheet];
        
    }

}

- (void)setFileURL:(NSURL *)fileURL{
    if(fileURL != nil){
        [self changeProjectPath:fileURL];
        [super setFileURL:fileURL];
    }
    else{
        JDFatalLog(@"fileURL nil");
    }
}


- (void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"IUProjectDocument"];
}


- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError
{
    // If the document was not read from file or has not previously been saved,
    // it doesn't have a file wrapper, so create one.
    //
    if ([self documentFileWrapper] == nil)
    {
        NSFileWrapper *docfileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
        [self setDocumentFileWrapper:docfileWrapper];
    }
    NSDictionary *fileWrappers = [[self documentFileWrapper] fileWrappers];

    //save Project
    if( [fileWrappers objectForKey:projectJsonData] != nil){
        NSFileWrapper *projectDataWrapper = [fileWrappers objectForKey:projectJsonData];
        [[self documentFileWrapper] removeFileWrapper:projectDataWrapper];
    }
    if(_project){
        JDCoder *coder = [[JDCoder alloc] init];
        [coder encodeRootObject:_project];
        NSString *tempJsonPath = [NSString stringWithFormat:@"%@/%@_temp.iuml", NSTemporaryDirectory(), _project.name];
        [coder writeToFilePath:tempJsonPath error:nil];
        NSFileWrapper *projectWrapper = [[NSFileWrapper alloc] initWithURL:[NSURL fileURLWithPath:tempJsonPath]options:0 error:nil];
        [projectWrapper setPreferredFilename:projectJsonData];
        [[self documentFileWrapper] addFileWrapper:projectWrapper];

    }

    //save resource folders
    
    NSFileWrapper *resourceWrapper = [fileWrappers objectForKey:IUResourceGroupName];
    if (resourceWrapper== nil){
        resourceWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
        [resourceWrapper setPreferredFilename:IUResourceGroupName];
        [[self documentFileWrapper] addFileWrapper:resourceWrapper];

    }
    
    NSFileWrapper *imageWrapper = [[resourceWrapper fileWrappers] objectForKey:IUImageResourceGroupName];
    NSFileWrapper *videoWrapper = [[resourceWrapper fileWrappers] objectForKey:IUVideoResourceGroupName];


    if(imageWrapper == nil){
        imageWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
        [imageWrapper setPreferredFilename:IUImageResourceGroupName];
        [resourceWrapper addFileWrapper:imageWrapper];
        _imageFileWrapper = imageWrapper;
    }
    if(videoWrapper == nil){
        videoWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
        [videoWrapper setPreferredFilename:IUVideoResourceGroupName];
        [resourceWrapper addFileWrapper:videoWrapper];
        
        _videoFileWrapper = videoWrapper;
    }

    //save metadata
    // write the new file wrapper for our meta data
    NSFileWrapper *metaDataFileWrapper = [[[self documentFileWrapper] fileWrappers] objectForKey:metaDataFileName];
    if (metaDataFileWrapper != nil)
        [[self documentFileWrapper] removeFileWrapper:metaDataFileWrapper];

    NSError *plistError = nil;
    [self loadCurrentMetaDictionary];
    NSData *propertyListData = [NSPropertyListSerialization dataWithPropertyList:self.metaDataDict format:NSPropertyListXMLFormat_v1_0 options:0 error:&plistError];
    if (propertyListData == nil || plistError != nil)
    {
        JDErrorLog(@"Could not create metadata plist data: %@", [plistError localizedDescription]);
        return nil;
    }
    
    NSFileWrapper *newMetaDataFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:propertyListData];
    [newMetaDataFileWrapper setPreferredFilename:metaDataFileName];
    
    [[self documentFileWrapper] addFileWrapper:newMetaDataFileWrapper];
    //save
    
    return [self documentFileWrapper];
    
}


- (BOOL)removeResourceFileItemName:(NSString *)fileItemName{
    
    NSFileWrapper *oldFileWrapper = [[_imageFileWrapper fileWrappers] objectForKey:fileItemName];
    NSString *extension =  [fileItemName pathExtension];
    if([JDFileUtil isImageFileExtension:extension]){
        if(oldFileWrapper){
            [_imageFileWrapper removeFileWrapper:oldFileWrapper];
        }
        [_resource refresh:YES];
        return YES;

    }
    else if([JDFileUtil isMovieFileExtension:extension]){
        if(oldFileWrapper){
            [_videoFileWrapper removeFileWrapper:oldFileWrapper];
        }
        [_resource refresh:YES];
        return YES;
    }
    
    return NO;
    
}
- (void)addResourceFileItemPaths:(NSArray *)fileItemPaths{
    for(NSString *filePath in fileItemPaths){
        NSString *fileName = [filePath lastPathComponent];
        NSFileWrapper *resourceWrapper = [[NSFileWrapper alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:0 error:nil];
        [resourceWrapper setPreferredFilename:fileName];
//        resourceWrapper writeToURL:<#(NSURL *)#> options:<#(NSFileWrapperWritingOptions)#> originalContentsURL:<#(NSURL *)#> error:<#(NSError *__autoreleasing *)#>
        
        NSString *extension =  [fileName pathExtension];
        if([JDFileUtil isImageFileExtension:extension]){
            [_imageFileWrapper addFileWrapper:resourceWrapper];
        }
        else if([JDFileUtil isMovieFileExtension:extension]){
            [_videoFileWrapper addFileWrapper:resourceWrapper];
        }
    }
    
    [_resource refresh:YES];
}



- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError
{
    [self.undoManager disableUndoRegistration];

    BOOL readSuccess= NO;
    NSDictionary *fileWrappers = [fileWrapper fileWrappers];
    
    if([fileWrappers objectForKey:@"iuData"]){
        //alert to old version project (beta version 0.3.3.x)
        //not supported and opened
        return NO;
    }
    
    
    // load resource folder wrapper
    NSFileWrapper *resourceFileWrapper = [fileWrappers objectForKey:IUResourceGroupName];
    if(resourceFileWrapper){
        _imageFileWrapper = [[resourceFileWrapper fileWrappers] objectForKey:IUImageResourceGroupName];
        _videoFileWrapper = [[resourceFileWrapper fileWrappers] objectForKey:IUVideoResourceGroupName];
    }
    
    
    // load the metaData file from it's wrapper
    NSFileWrapper *metaDataFileWrapper = [fileWrappers objectForKey:metaDataFileName];
    if (metaDataFileWrapper != nil)
    {
        // we have meta data in this document
        //
        NSData *metaData = [metaDataFileWrapper regularFileContents];
        NSMutableDictionary *finalMetadata = [NSPropertyListSerialization propertyListWithData:metaData options:NSPropertyListImmutable format:NULL error:outError];
        self.metaDataDict = finalMetadata;
    }

    
    NSFileWrapper *projectDataWarpper = [fileWrappers objectForKey:projectJsonData];
    if(projectDataWarpper){
        NSData *jsonData = [projectDataWarpper regularFileContents];
        JDCoder *coder = [[JDCoder alloc] init];
        _project =  [coder decodeContentOfData:jsonData error:nil];
        if(_project){
            [self changeProjectPath:[self fileURL]];
            readSuccess = YES;
        }
    }

    
    [self setDocumentFileWrapper:fileWrapper];

    
    [self.undoManager enableUndoRegistration];

    return readSuccess;

}

+ (BOOL)autosavesInPlace
{
    return YES;
}


@end
