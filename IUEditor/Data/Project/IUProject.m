//
//  IUProject.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUProject.h"
#import "IUPage.h"
#import "IUResourceGroup.h"
#import "IUSheetGroup.h"
#import "IUResourceFile.h"
#import "IUResourceManager.h"
#import "JDUIUtil.h"
#import "IUBackground.h"
#import "IUClass.h"
#import "IUFooter.h"
#import "IUEventVariable.h"
#import "IUResourceManager.h"
#import "IUIdentifierManager.h"

#import "IUDjangoProject.h"
#import "IUWordpressProject.h"

@interface IUProject()

@end


@implementation IUProject{
    BOOL _isConnectedWithEditor;
}

#pragma mark - init
- (void)encodeWithCoder:(NSCoder *)encoder{
    NSAssert(_resourceGroup, @"no resource");
    [encoder encodeObject:_mqSizes forKey:@"mqSizes"];
    [encoder encodeObject:self.buildPath forKey:@"_buildPath"];
    [encoder encodeObject:self.buildResourcePath forKey:@"_buildResourcePath"];
    [encoder encodeObject:_pageGroup forKey:@"_pageGroup"];
    [encoder encodeObject:_classGroup forKey:@"_classGroup"];
    [encoder encodeObject:_resourceGroup forKey:@"_resourceGroup"];
    [encoder encodeObject:_name forKey:@"_name"];
    [encoder encodeObject:_favicon forKey:@"_favicon"];
    [encoder encodeObject:_author forKey:@"_author"];
    [encoder encodeObject:_serverInfo forKey:@"serverInfo"];
    [encoder encodeBool:_enableMinWidth forKey:@"_enableMinWidth"];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [encoder encodeObject:version forKey:@"IUProjectVersion"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        
        [self.undoManager disableUndoRegistration];
        
        /* version control code */
        //REVIEW : sync with project version
        NSString *projectVersion = [aDecoder decodeObjectForKey:@"IUProjectVersion"];
        if(projectVersion == nil || projectVersion.length ==0){
            int IUEditorVersion = [aDecoder decodeIntForKey:@"IUEditorVersion"];
            if (IUEditorVersion < 1) {
                self.buildPath = @"$IUFileDirectory/$AppName_build";
                self.buildResourcePath = @"$IUBuildPath/resource";
            }
            _IUProjectVersion = @"0.3";
        }
        else{
            //REVIEW: save 할때 현재 build버전으로 바꿈
            _IUProjectVersion = projectVersion;
        }
        
        
        _identifierManager = [[IUIdentifierManager alloc] init];
        _compiler = [[IUCompiler alloc] init];
        _compiler.webTemplateFileName = @"webTemplate";
        
        _resourceManager = [[IUResourceManager alloc] init];
        _compiler.resourceManager = _resourceManager;
        
        _mqSizes = [[aDecoder decodeObjectForKey:@"mqSizes"] mutableCopy];
        _classGroup = [aDecoder decodeObjectForKey:@"_classGroup"];
        _pageGroup = [aDecoder decodeObjectForKey:@"_pageGroup"];
        _resourceGroup = [aDecoder decodeObjectForKey:@"_resourceGroup"];
        _name = [aDecoder decodeObjectForKey:@"_name"];
        
        self.buildPath = [aDecoder decodeObjectForKey:@"_buildPath"];
        self.buildResourcePath = [aDecoder decodeObjectForKey:@"_buildResourcePath"];
        
        _favicon = [aDecoder decodeObjectForKey:@"_favicon"];
        _author = [aDecoder decodeObjectForKey:@"_author"];
        _enableMinWidth = [aDecoder decodeBoolForKey:@"_enableMinWidth"];
        
        if ([[_pageGroup.name lowercaseString] isEqualToString:@"pages"]){
            _pageGroup.name = IUPageGroupName;
        }
        if ([[_classGroup.name lowercaseString] isEqualToString:@"classes"]) {
            _classGroup.name = IUClassGroupName;
        }
        
        //TODO:  css,js 파일은 내부에서그냥카피함. 따로 나중에 추가기능을 allow할때까지는 resource group으로 관리 안함.
        //[self initializeCSSJSResource];

        [_resourceManager setResourceGroup:_resourceGroup];
        
        _serverInfo = [aDecoder decodeObjectForKey:@"serverInfo"];
        if (_serverInfo == nil) {
            //version control
            _serverInfo = [[IUServerInfo alloc] init];
        }
        
        [self.undoManager enableUndoRegistration];

      
    }
    return self;
}

-(id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    [self.undoManager disableUndoRegistration];
    [super awakeAfterUsingCoder:aDecoder];

    
    [_identifierManager registerIUs:self.allDocuments];

    
    if( IU_VERSION_V1_GREATER_THAN_V2(IU_VERSION_LAYOUT, _IUProjectVersion) ){
        [self makeDefaultClasses];
        
        IUSheetGroup *backgroundGroup = [aDecoder decodeObjectForKey:@"_backgroundGroup"];
        IUBackground *background = backgroundGroup.childrenFiles[0];
        IUBox *oldHeader = background.children[0];
        
        IUClass *headerClass = [_classGroup sheetWithHtmlID:@"header"];
        [headerClass removeAllIU];
        
        for(IUBox *child in oldHeader.children){
            IUBox *copychild = [child copy];
            [headerClass addIU:copychild error:nil];
            [_identifierManager registerIUs:@[copychild]];
        }
        [headerClass copyCSSFromIU:oldHeader];
        [headerClass.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [headerClass.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
        
        for(IUPage *page in _pageGroup.childrenFiles){
             IUHeader *header = [[IUHeader alloc] initWithProject:self options:nil];
            header.name = @"header";
            header.prototypeClass = headerClass;
            
            for(NSNumber *viewportNumber in headerClass.css.allViewports){
                int viewport = [viewportNumber intValue];
                NSDictionary *dict = [headerClass.css tagDictionaryForViewport:viewport];
                if(dict){
                    if([dict objectForKey:IUCSSTagPixelHeight]){
                        CGFloat height = [[dict objectForKey:IUCSSTagPixelHeight] floatValue];
                        [header.css setValue:@(height) forTag:IUCSSTagPixelHeight forViewport:viewport];
                        [headerClass.css setValue:@(height) forTag:IUCSSTagPixelHeight forViewport:viewport];
                    }
                }
            }
            [page insertIU:header atIndex:0 error:nil];
            page.header = header;

            
            IUFooter *footer = [[IUFooter alloc] initWithProject:self options:nil];
            footer.name = @"footer";
            IUClass *footerClass = [self classWithName:@"footer"];
            footer.prototypeClass = footerClass;
            [footer.css setValue:@(0) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
            [footerClass.css setValue:@(0) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
            
            [page addIU:footer error:nil];
            page.footer = footer;
            
            //register identifier
            [_identifierManager registerIUs:@[header, footer]];


        }

    }
    
    
    [self.undoManager enableUndoRegistration];
    return self;
}

- (id)init{
    self = [super init];
    if(self){
        _mqSizes = [NSMutableArray array];
        _compiler = [[IUCompiler alloc] init];
    }
    return self;
}

/**
 @brief
 It's for convert project
 */
-(id)initWithProject:(IUProject*)project options:(NSDictionary*)options error:(NSError**)error{
    self = [super init];
    
    [self.undoManager disableUndoRegistration];
    
    _mqSizes = [project.mqSizes mutableCopy];
    
    
    _compiler = [[IUCompiler alloc] init];
    _resourceManager = [[IUResourceManager alloc] init];
    _compiler.resourceManager = _resourceManager;
    _identifierManager = [[IUIdentifierManager alloc] init];
    
    NSAssert(options[IUProjectKeyAppName], @"appName");
    NSAssert(options[IUProjectKeyIUFilePath], @"path");
    
    self.name = [options objectForKey:IUProjectKeyAppName];
    self.path = [options objectForKey:IUProjectKeyIUFilePath];
    
    self.buildPath = [[options objectForKey:IUProjectKeyBuildPath] relativePathFrom:self.path];
    if (self.buildPath == nil) {
        self.buildPath = @"$IUFileDirectory/$AppName_build";
    }
    
    self.buildResourcePath = [[options objectForKey:IUProjectKeyResourcePath] relativePathFrom:self.path];
    if (self.buildResourcePath == nil) {
        self.buildResourcePath = @"$IUBuildPath/resource";
    }
    
    _pageGroup = [project.pageGroup copy];
    _pageGroup.project = self;
        
    _classGroup = [project.classGroup copy];
    _classGroup.project = self;


    _resourceGroup = [project.resourceGroup copy];
    _resourceGroup.parent = self;
    
    [_resourceManager setResourceGroup:_resourceGroup];
    [_identifierManager registerIUs:self.allDocuments];
    
    _serverInfo = [[IUServerInfo alloc] init];
    _serverInfo.localPath = [self path];
    
    
    _enableMinWidth = project.enableMinWidth;
    _author = [project.author copy];
    _favicon = [project.favicon copy];
    
    // create build directory
    [[NSFileManager defaultManager] createDirectoryAtPath:self.absoluteBuildPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    [self.undoManager enableUndoRegistration];

    return self;
}


-(id)initWithCreation:(NSDictionary*)options error:(NSError**)error{
    self = [super init];
    
    _mqSizes = [NSMutableArray arrayWithArray:@[@(defaultFrameWidth), @320]];
    
    
    _compiler = [[IUCompiler alloc] init];
    _resourceManager = [[IUResourceManager alloc] init];
    _compiler.resourceManager = _resourceManager;
    _identifierManager = [[IUIdentifierManager alloc] init];
    
    NSAssert(options[IUProjectKeyAppName], @"app Name");
    NSAssert(options[IUProjectKeyIUFilePath], @"path");
    
    self.name = [options objectForKey:IUProjectKeyAppName];
    self.path = [options objectForKey:IUProjectKeyIUFilePath];

    self.buildPath = [[options objectForKey:IUProjectKeyBuildPath] relativePathFrom:self.path];
    if (self.buildPath == nil) {
        self.buildPath = @"$IUFileDirectory/$AppName_build";
    }
    
    self.buildResourcePath = [[options objectForKey:IUProjectKeyResourcePath] relativePathFrom:self.path];
    if (self.buildResourcePath == nil) {
        self.buildResourcePath = @"$IUBuildPath/resource";
    }

    _pageGroup = [[IUSheetGroup alloc] init];
    _pageGroup.name = IUPageGroupName;
    _pageGroup.project = self;
    
    _classGroup = [[IUSheetGroup alloc] init];
    _classGroup.name = IUClassGroupName;
    _classGroup.project = self;
    
    [self makeDefaultClasses];
    
    IUPage *pg = [[IUPage alloc] initWithProject:self options:nil];
    pg.name = @"index";
    pg.htmlID = @"index";
    [self addSheet:pg toSheetGroup:_pageGroup];
    
    IUClass *class = [[IUClass alloc] initWithProject:self options:nil];
    class.name = @"class";
    class.htmlID = @"class";
    [self addSheet:class toSheetGroup:_classGroup];
    
    [self initializeResource];
    [_resourceManager setResourceGroup:_resourceGroup];
    [_identifierManager registerIUs:self.allDocuments];
    
    //    ReturnNilIfFalse([self save]);
    _serverInfo = [[IUServerInfo alloc] init];
    _enableMinWidth = YES;
    
    // create build directory
    [[NSFileManager defaultManager] createDirectoryAtPath:self.absoluteBuildPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    return self;
}

- (void)makeDefaultClasses{

    IUClass *header = [self classWithName:@"header"];
    if(header == nil){
        NSDictionary *headerDict = @{kClassType: IUClassHeader};
        IUClass *header = [[IUClass alloc] initWithProject:self options:headerDict];
        header.name = @"header";
        header.htmlID = @"header";
        [self addSheet:header toSheetGroup:_classGroup];
        [_identifierManager registerIUs:@[header]];
    }
    
    IUClass *footer = [self classWithName:@"footer"];
    if(footer == nil){
        NSDictionary *footerDict = @{kClassType: IUClassFooter};
        IUClass *footer = [[IUClass alloc] initWithProject:self options:footerDict];
        footer.name = @"footer";
        footer.htmlID = @"footer";
        [self addSheet:footer toSheetGroup:_classGroup];
        [_identifierManager registerIUs:@[footer]];
    }
    
    IUClass *sidebar = [self classWithName:@"sidebar"];
    if(sidebar == nil){
        NSDictionary *sidebarDict = @{kClassType: IUClassSidebar};
        IUClass *sidebar = [[IUClass alloc] initWithProject:self options:sidebarDict];
        sidebar.name = @"sidebar";
        sidebar.htmlID = @"sidebar";
        [self addSheet:sidebar toSheetGroup:_classGroup];
        [_identifierManager registerIUs:@[sidebar]];

    }
}


- (void)connectWithEditor{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMQSize:) name:IUNotificationMQAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeMQSize:) name:IUNotificationMQRemoved object:nil];
    
    IUProjectType type = [self projectType];
    IUCompileRule rule;
    switch (type) {
        case IUProjectTypeDefault:
        case IUProjectTypePresentation:
            rule = IUCompileRuleDefault;
            break;
        case IUProjectTypeDjango:
            rule = IUCompileRuleDjango;
            break;
        case IUProjectTypeWordpress:
            rule = IUCompileRuleWordpress;
            break;
        default:
            assert(0);
            break;
    }
    
    [self setCompileRule:rule];
    
    for (IUSheet *sheet in self.allDocuments) {
        [sheet connectWithEditor];
    }
    
}

- (void)setIsConnectedWithEditor{
    _isConnectedWithEditor = YES;
    for (IUSheet *sheet in self.allDocuments) {
        [sheet setIsConnectedWithEditor];
    }
}

- (BOOL)isConnectedWithEditor{
    return _isConnectedWithEditor;
}

#pragma mark - Undo Manager
- (NSUndoManager *)undoManager{
    return [[[[NSApp mainWindow] windowController] document] undoManager];
}


- (void)setPath:(NSString *)path{
    _path = path;
}


-(void)dealloc{
    if([self isConnectedWithEditor]){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IUNotificationMQAdded object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IUNotificationMQRemoved object:nil];
    }
    [JDLogUtil log:IULogDealloc string:@"IUProject"];
}

#pragma mark - mq

- (void)addMQSize:(NSNotification *)notification{
    NSInteger size = [[notification.userInfo objectForKey:IUNotificationMQSize] integerValue];
    NSAssert(_mqSizes, @"mqsize");
    [_mqSizes addObject:@(size)];
}

- (void)removeMQSize:(NSNotification *)notification{
    NSInteger size = [[notification.userInfo objectForKey:IUNotificationMQSize] integerValue];
    NSAssert(_mqSizes, @"mqsize");
    [_mqSizes removeObject:@(size)];
}

- (NSArray*)mqSizes{
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending: NO];
    return [_mqSizes sortedArrayUsingDescriptors:@[sortOrder]];
}

#pragma mark - compile
- (IUCompileRule )compileRule{
    return _compiler.rule;
}



- (void)setCompileRule:(IUCompileRule)compileRule{
    _compiler.rule = compileRule;
    NSAssert(_compiler != nil, @"");
}




// return value : project path


+ (id)projectWithContentsOfPath:(NSString*)path{
    IUProject *project = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    project.path = path;
    return project;
}


+ (NSString *)stringProjectType:(IUProjectType)type{
    NSString *projectName ;
    switch (type) {
        case IUProjectTypeDefault:
            projectName = @"IUProject";
            break;
        case IUProjectTypeDjango:
            projectName = @"IUDjangoProject";
            break;
        case IUProjectTypePresentation:
            projectName = @"IUPresentationProject";
            break;
        case IUProjectTypeWordpress:
            projectName = @"IUWordpressProject";
            break;
        default:
            assert(0);
            break;
    }
    return projectName;
}


- (IUProjectType)projectType{
    IUProjectType type;
   
    if([self isKindOfClass:[IUDjangoProject class]]){
        type = IUProjectTypeDjango;
    }
    else if([self isKindOfClass:[IUWordpressProject class]]){
        type = IUProjectTypeWordpress;
    }
    /*
    else if([self isKindOfClass:[IUPresentationProject class]){
        type = IUProjectTypePresentation;
    }
    */
    else if([self isKindOfClass:[IUProject class]]){
        type = IUProjectTypeDefault;
    }
    else{
        assert(0);
    }
    
    return type;
}


- (NSString*)absoluteBuildPath{
    NSMutableString *str = [self.buildPath mutableCopy];
    [str replaceOccurrencesOfString:@"$IUFileDirectory" withString:[[self path] stringByDeletingLastPathComponent] options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"$AppName" withString:[self name] options:0 range:NSMakeRange(0, [str length])];    
    
    NSString *returnPath = [str stringByExpandingTildeInPath];
    return returnPath;
}



- (NSString*)absoluteBuildResourcePath{
    NSMutableString *str = [self.buildResourcePath mutableCopy];
    [str replaceOccurrencesOfString:@"$IUBuildPath" withString:[self buildPath] options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"$IUFileDirectory" withString:[[self path] stringByDeletingLastPathComponent] options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"$AppName" withString:[self name] options:0 range:NSMakeRange(0, [str length])];
    
    
    NSString *returnPath = [str stringByExpandingTildeInPath];
    return returnPath;
}

- (NSString*)absoluteBuildPathForSheet:(IUSheet*)sheet{
    if (sheet == nil) {
        return self.absoluteBuildPath;
    }
    else {
        NSString *filePath = [[self.absoluteBuildPath stringByAppendingPathComponent:sheet.name ] stringByAppendingPathExtension:@"html"];
        return filePath;
    }
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath{
    if ([error code] == NSFileWriteFileExistsError) //error code for: The operation couldn’t be completed. File exists
        return YES;
    else
        return NO;
}


- (BOOL)copyCSSJSResourceToBuildPath:(NSString *)buildPath{
    NSError *error;
    
    //css
    NSString *resourceCSSPath = [buildPath stringByAppendingPathComponent:@"css"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourceCSSPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:resourceCSSPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    [[NSFileManager defaultManager] createDirectoryAtPath:resourceCSSPath withIntermediateDirectories:YES attributes:nil error:&error];
    for(NSString *filename in [self defaultOutputCSSArray]){
        [[JDFileUtil util] overwriteBundleItem:filename toDirectory:resourceCSSPath];
    }

    
    //js
    NSString *resourceJSPath = [buildPath stringByAppendingPathComponent:@"js"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourceJSPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:resourceJSPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    for(NSString *filename in [self defaultCopyJSArray]){
        [[JDFileUtil util] overwriteBundleItem:filename toDirectory:resourceJSPath];
    }
    
#if DEBUG
    [[JDFileUtil util] overwriteBundleItem:@"stressTest.js" toDirectory:resourceJSPath];

#endif
    
    //copy js for IE
    NSString *ieJSPath = [resourceJSPath stringByAppendingPathComponent:@"ie"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:ieJSPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:ieJSPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    for(NSString *filename in [self defaultOutputIEJSArray]){
        [[JDFileUtil util] overwriteBundleItem:filename toDirectory:ieJSPath];
    }
    
    
    if(error){
        return NO;
    }
    return YES;
}

- (BOOL)build:(NSError**)error{
    /*
     Note :
     Do not delete build path. Instead, overwrite files.
     If needed, remove all files (except hidden file started with '.'), due to issus of git, heroku and editer such as Coda.
     NSFileManager's (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents attributes:(NSDictionary *)attributes automatically overwrites file.
     */
    NSAssert(self.buildPath != nil, @"");
    NSString *buildDirectoryPath = [self absoluteBuildPath];
    NSString *buildResourcePath = [self absoluteBuildResourcePath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:buildDirectoryPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:buildDirectoryPath withIntermediateDirectories:YES attributes:nil error:error];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:buildResourcePath] == YES) {
        [[NSFileManager defaultManager] removeItemAtPath:buildResourcePath error:nil];
    }
    
    
    [[NSFileManager defaultManager] setDelegate:self];
    [[NSFileManager defaultManager] copyItemAtPath:_resourceGroup.absolutePath toPath:buildResourcePath error:error];
    [[NSFileManager defaultManager] setDelegate:nil];
    
    [self copyCSSJSResourceToBuildPath:buildResourcePath];
    
    NSString *resourceCSSPath = [buildResourcePath stringByAppendingPathComponent:@"css"];
    NSString *resourceJSPath = [buildResourcePath stringByAppendingPathComponent:@"js"];

    NSMutableArray *clipArtArray = [NSMutableArray array];
    
    
    for (IUSheet *sheet in self.allDocuments) {
        
        NSError *myError;

        //clipart
        [clipArtArray addObjectsFromArray:[sheet outputArrayClipArt]];
        
        //eventJS
        //todo: optimize :(event variable 없을경우에는 안들어가게)
        IUEventVariable *eventVariable = [[IUEventVariable alloc] init];
        [eventVariable makeEventDictionary:sheet];

        
        //make event javascript file
        NSString *eventFileName = [NSString stringWithFormat:@"%@-event", sheet.name];
        NSString *eventJSFilePath = [[resourceJSPath stringByAppendingPathComponent:eventFileName] stringByAppendingPathExtension:@"js"];
        [[NSFileManager defaultManager] removeItemAtPath:eventJSFilePath error:nil];
        if([eventVariable hasEvent]){
            NSString *eventJSString = [eventVariable outputEventJSSource];
            sheet.hasEvent = YES;
            if ([eventJSString writeToFile:eventJSFilePath atomically:YES encoding:NSUTF8StringEncoding error:error] == NO){
                NSAssert(0, @"write fail");
            }
        }
        else{
            sheet.hasEvent = NO;
        }
        
        //make initialize javascript file - init.js for sheet
        JDCode *initJSCode = [sheet outputInitJSCode];
        
        NSString *initializeJSPath = [[resourceJSPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-init", sheet.name]] stringByAppendingPathExtension:@"js"];
        if ([initJSCode.string writeToFile:initializeJSPath atomically:YES encoding:NSUTF8StringEncoding error:&myError] == NO){
            NSAssert(0, @"write fail");
        }

        
        //html
        NSString *outputHTML = [sheet outputHTMLSource];
        
        //if compile mode is Presentation, add button
        if (self.compiler.rule == IUCompileRulePresentation) {
            if ([sheet isKindOfClass:[IUPage class]]) {
                NSInteger indexOfSheet = [self.pageSheets indexOfObject:sheet];
                NSString *prevSheetName = [sheet.name stringByAppendingString:@".html"];
                NSString *nextSheetName = [sheet.name stringByAppendingString:@".html"];
                if (indexOfSheet > 0) {
                    prevSheetName = [[[self.pageSheets objectAtIndex:indexOfSheet-1] name] stringByAppendingString:@".html"];
                }
                if (indexOfSheet < [self.pageSheets count] -1 ) {
                    nextSheetName = [[[self.pageSheets objectAtIndex:indexOfSheet+1] name] stringByAppendingString:@".html"];
                }
                
                NSString *scriptPath = [[NSBundle mainBundle] pathForResource:@"iupresentationScript" ofType:@"txt"];
                NSString *presentStr = [[[NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:nil]  stringByReplacingOccurrencesOfString:@"IUPRESENTATION_NEXT_PAGE" withString:nextSheetName] stringByReplacingOccurrencesOfString:@"IUPRESENTATION_PREV_PAGE" withString:prevSheetName];
                outputHTML = [outputHTML stringByAppendingString:presentStr];
            }
        }
        
        NSString *htmlPath = [self absoluteBuildPathForSheet:sheet];

        //note : writeToFile: automatically overwrite
        if ([outputHTML writeToFile:htmlPath atomically:YES encoding:NSUTF8StringEncoding error:&myError] == NO){
            NSAssert(0, @"write fail");
        }
        
        //css
        if (self.compiler.rule != IUCompileRuleWordpress) {
            NSString *outputCSS = [sheet outputCSSSource];
            NSString *cssPath = [[resourceCSSPath stringByAppendingPathComponent:sheet.name] stringByAppendingPathExtension:@"css"];
            
            //note : writeToFile: automatically overwrite
            if ([outputCSS writeToFile:cssPath atomically:YES encoding:NSUTF8StringEncoding error:&myError] == NO){
                NSAssert(0, @"write fail");
            }
        }
        
        
    }
    //copy clipart to build directory
    if (clipArtArray.count != 0) {
        NSString *copyPath = [buildResourcePath stringByAppendingPathComponent:@"clipArt"];
        [[NSFileManager defaultManager] createDirectoryAtPath:copyPath withIntermediateDirectories:YES attributes:nil error:error];
        
        for(NSString *imageName in clipArtArray){
            if ([[NSFileManager defaultManager] fileExistsAtPath:[buildResourcePath stringByAppendingPathComponent:imageName] isDirectory:NO] == NO) {
                [[JDFileUtil util] copyBundleItem:[imageName lastPathComponent] toDirectory:copyPath];
            }
        }
    }
    
    
   
    
    [JDUIUtil hudAlert:@"Successfully Exported" second:2];
    return YES;
}


- (void)addImageResource:(NSImage*)image{
    NSAssert(0, @"write fail");
}

-(NSSet*)allIUs{
    NSMutableSet  *set = [NSMutableSet set];
    for (IUSheet *sheet in self.allDocuments) {
        [set addObject:sheet];
        [set addObjectsFromArray:sheet.allChildren];
    }
    return [set copy];
}

- (NSArray *)childrenFiles{
    return @[_pageGroup, _classGroup, _resourceGroup];
}

- (IUResourceGroup*)resourceNode{
    return [self.childrenFiles objectAtIndex:3];
}

- (IUCompiler*)compiler{
    return _compiler;
}


/** default css array
 */

- (NSArray *)defaultEditorCSSArray{
    return @[@"reset.css", @"iueditor.css"];
}

- (NSArray *)defaultOutputCSSArray{
    return @[@"reset.css", @"iu.css"];
}

/** default js array
 */
- (NSArray *)defaultEditorJSArray{
    return @[@"iueditor.js", @"iuframe.js", @"iugooglemap_theme.js"];
}

- (NSArray *)defaultCopyJSArray{
    return @[@"jquery.event.move.js",@"jquery.event.swipe.js", @"jquery.scrollto.js",@"iuframe.js", @"iu.js", @"iucarousel.js"];
}
- (NSArray *)defaultOutputJSArray{
    return [self defaultCopyJSArray];
}
- (NSArray *)defaultOutputIEJSArray{
    return @[@"jquery.backgroundSize.js", @"respond.min.js"];
}




//TODO:  css,js 파일은 내부에서그냥카피함. 따로 나중에 추가기능을 allow할때까지는 resource group으로 관리 안함.
//현재는 불리지 않음.
- (void)initializeCSSJSResource{
    IUResourceGroup *JSGroup = [[IUResourceGroup alloc] init];
    JSGroup.name = IUJSResourceGroupName;
    [_resourceGroup addResourceGroup:JSGroup];
    
    IUResourceGroup *CSSGroup = [[IUResourceGroup alloc] init];
    CSSGroup.name = IUCSSResourceGroupName;
    [_resourceGroup addResourceGroup:CSSGroup];
    
    //CSS resource Copy
    NSString *resetCSSPath = [[NSBundle mainBundle] pathForResource:@"reset" ofType:@"css"];
    [CSSGroup addResourceFileWithContentOfPath:resetCSSPath];
    
    NSString *iuCSSPath = [[NSBundle mainBundle] pathForResource:@"iu" ofType:@"css"];
    [CSSGroup addResourceFileWithContentOfPath:iuCSSPath];
    
    NSString *iueditorCSSPath = [[NSBundle mainBundle] pathForResource:@"iueditor" ofType:@"css"];
    [CSSGroup addResourceFileWithContentOfPath:iueditorCSSPath];

    
    //Java Script resource copy
    NSString *iuEditorJSPath = [[NSBundle mainBundle] pathForResource:@"iueditor" ofType:@"js"];
    [JSGroup addResourceFileWithContentOfPath:iuEditorJSPath];
    
    NSString *iuFrameJSPath = [[NSBundle mainBundle] pathForResource:@"iuframe" ofType:@"js"];
    [JSGroup addResourceFileWithContentOfPath:iuFrameJSPath];
    
    NSString *iuJSPath = [[NSBundle mainBundle] pathForResource:@"iu" ofType:@"js"];
    [JSGroup addResourceFileWithContentOfPath:iuJSPath];
    
    NSString *carouselJSPath = [[NSBundle mainBundle] pathForResource:@"iucarousel" ofType:@"js"];
    [JSGroup addResourceFileWithContentOfPath:carouselJSPath];
    
}

- (void)initializeResource{
    //remove resource node if exist
    JDInfoLog(@"initilizeResource");
    
    _resourceGroup = [[IUResourceGroup alloc] init];
    _resourceGroup.name = IUResourceGroupName;
    _resourceGroup.parent = self;
    
    
    IUResourceGroup *imageGroup = [[IUResourceGroup alloc] init];
    imageGroup.name = IUImageResourceGroupName;
    [_resourceGroup addResourceGroup:imageGroup];
    
    IUResourceGroup *videoGroup = [[IUResourceGroup alloc] init];
    videoGroup.name = IUVideoResourceGroupName;
    [_resourceGroup addResourceGroup:videoGroup];
    
    
    //TODO:  css,js 파일은 내부에서그냥카피함. 따로 나중에 추가기능을 allow할때까지는 resource group으로 관리 안함.
    //[self initializeCSSJSResource];
}


- (NSArray*)allDocuments{
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.pageSheets];
    [array addObjectsFromArray:self.classSheets];
    return array;
}

- (NSArray*)pageSheets{
    NSAssert(_pageGroup, @"pg");
    return _pageGroup.childrenFiles;
}
- (NSArray*)classSheets{
    return _classGroup.childrenFiles;
}
- (IUClass *)classWithName:(NSString *)name{
    return [_classGroup sheetWithHtmlID:name];
}

- (BOOL)runnable{
    return NO;
}

- (IUIdentifierManager*)identifierManager{
    return _identifierManager;
}

- (IUResourceManager *)resourceManager{
    return _resourceManager;
}

- (id)parent{
    return nil;
}

- (IUSheetGroup*)pageGroup{
    return _pageGroup;
}
- (IUSheetGroup*)classGroup{
    return _classGroup;
}
- (IUResourceGroup*)resourceGroup{
    return _resourceGroup;
}

- (void)addSheet:(IUSheet *)sheet toSheetGroup:(IUSheetGroup *)sheetGroup{
    if([sheetGroup isEqualTo:_pageGroup]){
        [self willChangeValueForKey:@"pageGroup"];
        [self willChangeValueForKey:@"pageSheets"];

    }
    else if([sheetGroup isEqualTo:_classGroup]){
        [self willChangeValueForKey:@"classGroup"];
        [self willChangeValueForKey:@"classSheets"];

    }
    
    [sheetGroup addSheet:sheet];
    
    if([sheetGroup isEqualTo:_pageGroup]){
        [self didChangeValueForKey:@"pageGroup"];
        [self didChangeValueForKey:@"pageSheets"];

    }
    else if([sheetGroup isEqualTo:_classGroup]){
        [self didChangeValueForKey:@"classGroup"];
        [self didChangeValueForKey:@"classSheets"];

    }
}

- (void)removeSheet:(IUSheet *)sheet toSheetGroup:(IUSheetGroup *)sheetGroup{
    if([sheetGroup isEqualTo:_pageGroup]){
        [self willChangeValueForKey:@"pageGroup"];
        [self willChangeValueForKey:@"pageSheets"];
        
    }
    else if([sheetGroup isEqualTo:_classGroup]){
        [self willChangeValueForKey:@"classGroup"];
        [self willChangeValueForKey:@"classSheets"];
        
    }
    [sheetGroup removeSheet:sheet];
    
    if([sheetGroup isEqualTo:_pageGroup]){
        [self didChangeValueForKey:@"pageGroup"];
        [self didChangeValueForKey:@"pageSheets"];
        
    }
    else if([sheetGroup isEqualTo:_classGroup]){
        [self didChangeValueForKey:@"classGroup"];
        [self didChangeValueForKey:@"classSheets"];
        
    }
}

- (IUServerInfo*)serverInfo{
    if (_serverInfo.localPath == nil) {
        _serverInfo.localPath = [self buildPath];
        _serverInfo.syncItem = [self.path lastPathComponent];
    }
    return _serverInfo;
}

- (void)resetBuildPath{
    self.buildPath = @"$IUFileDirectory/$AppName_build";
    self.buildResourcePath = @"$IUBuildPath/resource";
}

@end