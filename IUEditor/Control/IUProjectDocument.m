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
    BOOL _isLoaded;
    NSFileWrapper *_resourceFileWrapper;
}

- (id)init{
    self = [super init];
    if(self){
        //allocation identifiermanager
        _identifierManager = [[IUIdentifierManager alloc] init];
        
        //allocation resource root
        _resourceRootItem = [[IUResourceRootItem alloc] init];
        _resourceFileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
        [_resourceFileWrapper setPreferredFilename:IUResourceGroupName];
        
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
    
    NSString *resourceTempPath = [self resourceTemporaryPath];
    [[NSFileManager defaultManager] createDirectoryAtPath:resourceTempPath withIntermediateDirectories:YES attributes:nil error:nil];
    [_resourceRootItem loadFromPath:resourceTempPath];
    
    return [super initForURL:urlOrNil withContentsOfURL:contentsURL ofType:typeName error:outError];
}

//make new document
- (id)initWithType:(NSString *)typeName error:(NSError *__autoreleasing *)outError{
    self = [super initWithType:typeName error:outError];
    if(self){

        
        //FIXME:
        //projectType은 nsuserdefault로 넘겨받아야함.
        
        IUProject *newProject = [[NSClassFromString(@"IUProject") alloc] initForUntitledDocument];
        if(newProject){
            
            _project = newProject;
            
            //re-check htmlID (IUBox can not access to identifier manager while initializing
            for(IUSheet *sheet in _project.allSheets){
                for(IUBox *iu in sheet.allChildren){
                    iu.htmlID = [self.identifierManager createAndRegisterIdentifierWithObject:iu];
                    iu.name = iu.htmlID;
                    
                }
                
                [self.identifierManager registerIdentifier:sheet.htmlID withObject:sheet];
                sheet.name = sheet.htmlID;
            }
            
        }
        //get document path:NSString *dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *resourceTempPath = [self resourceTemporaryPath];
        [[NSFileManager defaultManager] createDirectoryAtPath:resourceTempPath withIntermediateDirectories:YES attributes:nil error:nil];
        [_resourceRootItem loadFromPath:resourceTempPath];
    }
    return self;
}

- (NSString *)resourceTemporaryPath{
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_resource", self.className]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
        int i = 0;
        while (1) {
            tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d_resource", self.className, i]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath] == NO) {
                break;
            }
            i++;
        }
    }
    return tempPath;
}

- (BOOL)makeNewProjectWithOption:(NSDictionary *)option URL:(NSURL *)url __deprecated{
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
        
        NSString *dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        IUProject *newProject = [[NSClassFromString([IUProject stringProjectType:projectType]) alloc] initForUntitledDocument];
        if(newProject){

            _project = newProject;
            
            //re-check htmlID (IUBox can not access to identifier manager while initializing
            for(IUSheet *sheet in _project.allSheets){
                for(IUBox *iu in sheet.allChildren){
                    iu.htmlID = [self.identifierManager createAndRegisterIdentifierWithObject:iu];
                    iu.name = iu.htmlID;
                    
                }
                
                [self.identifierManager registerIdentifier:sheet.htmlID withObject:sheet];
                sheet.name = sheet.htmlID;
            }
            
            
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

- (BBWC *)butterflyWindowController{
    if([[self windowControllers] count] > 0){
        return [[self windowControllers] objectAtIndex:0];
    }
    return nil;
}




- (void)makeWindowControllers{
    BBWC *wc = [[BBWC alloc] initWithWindowNibName:@"BBWC"];
    [self addWindowController:wc];
    
}

- (void)removeWindowController:(NSWindowController *)windowController{
    
    if([windowController isKindOfClass:[BBWC class]]){
        BBWC *wc = (BBWC *)windowController;
//        [wc prepareDealloc];
    }
    [super removeWindowController:windowController];
}



- (void)showWindows{
    [super showWindows];
    [self showButterflyWindow];
}

- (void)showButterflyWindow{
    [self.undoManager disableUndoRegistration];
    
    if(_isLoaded && [self butterflyWindowController]){
        
    }
    else if([self butterflyWindowController]){
//        [[self butterflyWindowController] selectFirstPage];
        _isLoaded = YES;
    }
    
    [self.undoManager enableUndoRegistration];
}

- (void)showLemonSheet __deprecated{
    [self.undoManager disableUndoRegistration];
    
    if(_isLoaded && [self butterflyWindowController]){
//        [[self butterflyWindowController] reloadNavigation];
//        [[self butterflyWindowController] reloadCurrentDocument:self];
    }
    else if([self butterflyWindowController]){
//        [[self butterflyWindowController] selectFirstDocument];
        _isLoaded = YES;
    }
    
    [self.undoManager enableUndoRegistration];
    
}

- (NSString *)displayName{
    if([self fileURL]){
        return [NSString stringWithFormat:@"%@ - %@.iu", NSStringFromClass([_project class]), _project.name];
    }
    else{
        return  [NSString stringWithFormat:@"%@ - %@", NSStringFromClass([_project class]), [self defaultDraftName]];
    }
}

- (void)changeProjectPath:(NSURL *)fileURL{
    NSString *filePath = [fileURL relativePath];
    NSString *appName = [[fileURL lastPathComponent] stringByDeletingPathExtension];
    
    
    if(_project && [filePath isEqualToString:_project.path] == NO){
        [self.undoManager disableUndoRegistration];
        _project.name = appName;
        _project.path = filePath;
        [_resourceRootItem loadFromPath:[filePath stringByAppendingPathComponents:@[@"resource"]]];
        
        [self.undoManager enableUndoRegistration];
        
        [self showButterflyWindow];
        
    }

}

- (void)setFileURL:(NSURL *)fileURL{
    if(fileURL != nil){
        [self changeProjectPath:fileURL];
    }
    else{
        JDTraceLog(@"untitled document opened");
    }
    [super setFileURL:fileURL];

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
    
    
    //save resource
    NSFileWrapper *resourceWrapper = [fileWrappers objectForKey:IUResourceGroupName];
    if (resourceWrapper== nil){
        [[self documentFileWrapper] addFileWrapper:_resourceFileWrapper];
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


- (BOOL)removeResourceFileItem:(IUResourceFileItem *)fileItem{
    
    NSArray *component = [fileItem.relativePath componentsSeparatedByString:@"/"];
    
    NSFileWrapper *parentFileWrapper = _resourceFileWrapper;
    NSFileWrapper *currentFileWrapper = _resourceFileWrapper;
    NSDictionary *childFileWrappers =  [_resourceFileWrapper fileWrappers];
    for(NSString *name in component){
        if(name.length ==0 ){
            continue;
        }
        parentFileWrapper = currentFileWrapper;
        currentFileWrapper = [childFileWrappers objectForKey:name];
        if([currentFileWrapper isDirectory]){
            childFileWrappers = [currentFileWrapper fileWrappers];
        }
        else{
            break;
        }
    }
    
    if([parentFileWrapper isNotEqualTo:currentFileWrapper]){
        [parentFileWrapper removeFileWrapper:currentFileWrapper];
        
        NSURL *resourceURL = [NSURL fileURLWithPath:[fileItem.absolutePath stringByDeletingLastPathComponent]];
        NSError *saveError;
        [parentFileWrapper writeToURL:resourceURL options:NSFileWrapperWritingAtomic originalContentsURL:nil error:&saveError];

        [_resourceRootItem refresh:YES];
        return YES;
    }
    
    return NO;
    
}
- (void)addResourceFileItemPaths:(NSArray *)fileItemPaths{
    for(NSString *filePath in fileItemPaths){
        NSString *fileName = [filePath lastPathComponent];
        NSFileWrapper *newResourceWrapper = [self makeNewResourceFileWrapperAtPath:filePath];
        
        NSURL *resourceURL = [NSURL fileURLWithPath:[[_resourceRootItem absolutePath] stringByAppendingPathComponent:fileName]];
        NSError *saveError;
        [newResourceWrapper writeToURL:resourceURL options:NSFileWrapperWritingAtomic originalContentsURL:nil error:&saveError];
        [_resourceFileWrapper addFileWrapper:newResourceWrapper];

    }
    
    [_resourceRootItem refresh:YES];
}

- (NSFileWrapper *)makeNewResourceFileWrapperAtPath:(NSString *)filePath{
    
    
    
    //check directory
    NSNumber *isDirectory;
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    BOOL success = [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
    if (success && [isDirectory boolValue]) {
        
        NSFileWrapper *resourceWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
        NSString *fileName = [filePath lastPathComponent];
        [resourceWrapper setPreferredFilename:fileName];

        
        
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:filePath]
                                                       includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                            error:nil];
        [files enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
            //directory
            NSString *extension = [url pathExtension];
            if([JDFileUtil isImageFileExtension:extension] || [JDFileUtil isMovieFileExtension:extension]){
                NSFileWrapper *childWrapper = [self makeNewResourceFileWrapperAtPath:[url path]];
                [resourceWrapper addFileWrapper:childWrapper];
            }
            
        }];
        
        return resourceWrapper;
    }
    else{
        NSFileWrapper *resourceWrapper = [[NSFileWrapper alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:0 error:nil];
        NSString *fileName = [filePath lastPathComponent];
        [resourceWrapper setPreferredFilename:fileName];
        return resourceWrapper;
    }

   
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
        _resourceFileWrapper = resourceFileWrapper;
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
        if(_project && [self fileURL]){
            [self changeProjectPath:[self fileURL]];
            [self.resourceRootItem loadFromPath:[_project.path stringByAppendingPathComponent:@"resource"]];

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
