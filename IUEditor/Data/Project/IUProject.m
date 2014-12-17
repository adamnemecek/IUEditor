
//
//  IUProject.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUProject.h"
#import "IUPage.h"
#import "IUSheetGroup.h"
#import "JDUIUtil.h"
#import "IUBackground.h"
#import "IUClass.h"
#import "IUFooter.h"
#import "IUEventVariable.h"
#import "IUIdentifierManager.h"
#import "IUProjectController.h"

#import "IUDjangoProject.h"
#import "IUWordpressProject.h"

#import "BBWindowProtocol.h"
#import "IUDocumentProtocol.h"

@interface IUProject()

@end


@implementation IUProject{
    BOOL _isConnectedWithEditor;
    NSData *_lastCreatedData;
}

#pragma mark - class attributes
+ (NSArray *)widgetList{
    return @[
             @"IUBox", @"IUText", @"IUCenterBox", @"IUImage", @"PGSubmitButton", @"PGForm", @"IUImport",
             @"IUMovie", @"IUHTML", @"IUTweetButton", @"IUGoogleMap", @"IUWebMovie", @"IUFBLike",
             @"PGTextField", @"PGTextView", @"IUTransition", @"IUMenuBar", @"IUCarousel"
             ];
}

+ (NSArray *)compilerRules{
    return @[kIUCompileRuleHTML, kIUCompileRulePresentation];
}

+ (NSString *)defaultCompilerRule{
    return kIUCompileRuleHTML;
}


#pragma mark - 


- (BOOL)isLeaf{
    return NO;
}

- (NSArray *)childrenFileItems{
    return @[_pageGroup, _classGroup];
}

+ (id)projectWithContentsOfPath:(NSString*)path {
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


#pragma mark - init
- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder encodeObject:_mqSizes forKey:@"mqSizes"];
    [aCoder encodeObject:_buildPath forKey:@"_buildPath"];
    
    [aCoder encodeObject:self.buildResourcePath forKey:@"_buildResourcePath"];
    [aCoder encodeObject:_pageGroup forKey:@"_pageGroup"];
    [aCoder encodeObject:_classGroup forKey:@"_classGroup"];
//    [encoder encodeObject:_resourceGroup forKey:@"_resourceGroup"];
    [aCoder encodeObject:_name forKey:@"_name"];
    [aCoder encodeObject:_favicon forKey:@"_favicon"];
    [aCoder encodeObject:_author forKey:@"_author"];
    
    //Do not encode server info. instead, save at NSUserDefault
    //[encoder encodeObject:_serverInfo forKey:@"serverInfo"];
    [aCoder encodeBool:_enableMinWidth forKey:@"_enableMinWidth"];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [aCoder encodeObject:version forKey:@"IUProjectVersion"];
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super init];
    if (self) {
        
//        _compiler.webTemplateFileName = @"webTemplate";
        
        
        _mqSizes = [[aDecoder decodeObjectForKey:@"mqSizes"] mutableCopy];
        _classGroup = [aDecoder decodeObjectForKey:@"_classGroup"];
        _pageGroup = [aDecoder decodeObjectForKey:@"_pageGroup"];
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
        
        //        [_resourceManager setResourceGroup:_resourceGroup];
        
        _serverInfo = [[IUServerInfo alloc] init];
        
        
    }
    return self;
}

- (void)awakeAfterUsingJDCoder:(JDCoder *)aDecoder{
    for(IUSheet *sheet in self.allSheets){
        [[IUIdentifierManager managerForMainWindow] registerObjectRecusively:sheet withIdentifierKey:@"htmlID" childrenKey:@"children"];
    }
    _pageGroup.parentFileItem = self;
    _classGroup.parentFileItem = self;
    
}

/*
-(id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    [super awakeAfterUsingCoder:aDecoder];
    
    
    [self.identifierManager registerIUs:self.allSheets];
    
    
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
            [self.identifierManager registerIUs:@[copychild]];
        }
        [headerClass copyCSSFromIU:oldHeader];
        [headerClass.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [headerClass.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
        
        for(IUPage *page in _pageGroup.childrenFiles){
            IUHeader *header = [[IUHeader alloc] initWithPreset];
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
            //            page.header = header;
            
            
            IUFooter *footer = [[IUFooter alloc] initWithPreset];
            footer.name = @"footer";
            IUClass *footerClass = [self classWithName:@"footer"];
            footer.prototypeClass = footerClass;
            [footer.css setValue:@(0) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
            [footerClass.css setValue:@(0) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
            
            [page addIU:footer error:nil];
            //            page.footer = footer;
            
            //register identifier
            [self.identifierManager registerIUs:@[header, footer]];
            
            
        }
        
    }
    
    return self;
}
 */

/**
 @brief
 It's for convert project
 */
/*
-(id)initWithProject:(IUProject*)project options:(NSDictionary*)options error:(NSError**)error{
    self = [super init];
    
    [self.undoManager disableUndoRegistration];
    
    _mqSizes = [project.mqSizes mutableCopy];
    
    
    _compiler = [[IUCompiler alloc] init];
    _resourceManager = [[IUResourceManager alloc] init];
    _compiler.resourceManager = _resourceManager;
    
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
    [self.identifierManager registerIUs:self.allSheets];
    
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
*/
/* 그냥 initWithCreation:nil] 하면
    NSAssert에 걸리므로 임시로 이렇게 처리 */

- (id)initForUntitledDocument{    
    /* initialize at temp directory */
    [[IUIdentifierManager managerForMainWindow] reset];
    NSDictionary *documentOption = [[IUProjectController sharedDocumentController] newDocumentOption];
    self = [super init];
    _mqSizes = [NSMutableArray arrayWithArray:@[@(IUDefaultViewPort), @320]];
    _serverInfo = [[IUServerInfo alloc] init];
    _enableMinWidth = YES;
    
    self.name = [[[self.path lastPathComponent] lastPathComponent] stringByDeletingPathExtension];
    self.buildPath = @"$IUFileDirectory/$AppName_build";
    self.buildResourcePath = @"$IUBuildPath/resource";
    
    _pageGroup = [[IUSheetGroup alloc] init];
    _pageGroup.name = IUPageGroupName;
    _pageGroup.parentFileItem = self;
    
    _classGroup = [[IUSheetGroup alloc] init];
    _classGroup.name = IUClassGroupName;
    _classGroup.parentFileItem = self;
    
    
    /* alloc default pages */
    [self makeDefaultClasses];
    IUPage *pg = [[IUPage alloc] initWithPreset];
    pg.name = @"index";
    pg.htmlID = @"index";
    [self addItem:pg toSheetGroup:_pageGroup];

    IUClass *class = [[IUClass alloc] initWithPreset];
    class.name = @"class";
    class.htmlID = @"class";
    [self addItem:class toSheetGroup:_classGroup];

    /*
     FIXME : resourceManager
    
    
    // create build directory
    [[NSFileManager defaultManager] createDirectoryAtPath:self.absoluteBuildPath withIntermediateDirectories:YES attributes:nil error:nil];
    */
    if (documentOption[IUProjectModeKey] == IUProjectModeStress) {
        [self setAsStressTestMode];
    }
    return self;
}

- (void)setAsStressTestMode {
    /* Time History */
    // 2014/12/13 [test01] : set 5.3, iuframe 0.10~0.12s, movieIU 0.12s
    
    [JDLogUtil timeLogStart:@"setStressMode"];
    IUPage *pg = [[_pageGroup childrenFileItems] firstObject];
    IUPageContent *content = pg.pageContent;
    
    IUBox *firstBox;
    for (int i=0; i<500; i++) {
        IUBox *box = [[IUBox alloc] init];
        if (i==0){
            firstBox = box;
        }
        [content addIU:box error:nil];
        [box.currentPositionStorage setPosition:@(IUPositionTypeAbsolute)];
        [box.currentPositionStorage setX:@(i*3) unit:@(IUFrameUnitPixel)];
        [box.currentPositionStorage setY:@(i*3) unit:@(IUFrameUnitPixel)];
        [box.currentStyleStorage setWidth:@(100) unit:@(IUFrameUnitPixel)];
        [box.currentStyleStorage setHeight:@(100) unit:@(IUFrameUnitPixel)];
        [box.currentStyleStorage setBgColor:[NSColor randomColor]];
    }
    [JDLogUtil timeLogEnd:@"setStressMode"];
    
    for (int i=0; i<10; i++) {
        int64_t time = (i+5) * NSEC_PER_SEC;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time)), dispatch_get_main_queue(), ^{
            for (int j=0; j <10; j++){
                [firstBox.currentPositionStorage setX:@(10*j)];
            }
        });
    }
}

/*
-(id)initWithCreation:(NSDictionary*)options error:(NSError**)error{
    self = [super init];
    
    _mqSizes = [NSMutableArray arrayWithArray:@[@(defaultFrameWidth), @320]];
    
    
    _compiler = [[IUCompiler alloc] init];
    _resourceManager = [[IUResourceManager alloc] init];
    _compiler.resourceManager = _resourceManager;
    
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
    
    IUPage *pg = [[IUPage alloc] initWithPreset];
    pg.name = @"index";
    pg.htmlID = @"index";
    [self addItem:pg toSheetGroup:_pageGroup];
    
    IUClass *class = [[IUClass alloc] initWithPreset];
    class.name = @"class";
    class.htmlID = @"class";
    [self addItem:class toSheetGroup:_classGroup];
    
    [_resourceManager setResourceGroup:_resourceGroup];
    [self.identifierManager registerIUs:self.allSheets];
    
    //    ReturnNilIfFalse([self save]);
    _serverInfo = [[IUServerInfo alloc] init];
    _enableMinWidth = YES;
    
    // create build directory
    [[NSFileManager defaultManager] createDirectoryAtPath:self.absoluteBuildPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    return self;
}
*/
- (void)makeDefaultClasses{

    IUClass *header = [self classWithName:@"header"];
    if(header == nil){
        IUClass *header = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
        header.name = @"header";
        header.htmlID = @"header";
        [self addItem:header toSheetGroup:_classGroup];
    }
    
    IUClass *footer = [self classWithName:@"footer"];
    if(footer == nil){
        IUClass *footer = [[IUClass alloc] initWithPreset:IUClassPresetTypeFooter];
        footer.name = @"footer";
        footer.htmlID = @"footer";
        [self addItem:footer toSheetGroup:_classGroup];
    }
    
    IUClass *sidebar = [self classWithName:@"sidebar"];
    if(sidebar == nil){
        IUClass *sidebar = [[IUClass alloc] initWithPreset:IUClassPresetTypeSidebar];
        sidebar.name = @"sidebar";
        sidebar.htmlID = @"sidebar";
        [self addItem:sidebar toSheetGroup:_classGroup];

    }
}


- (void)connectWithEditor{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMQSize:) name:IUNotificationMQAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeMQSize:) name:IUNotificationMQRemoved object:nil];

    for (IUSheet *sheet in self.allSheets) {
        [sheet connectWithEditor];
    }
    [self setIsConnectedWithEditor];
    
}

- (void)setIsConnectedWithEditor{
    _isConnectedWithEditor = YES;
}

- (BOOL)isConnectedWithEditor{
    return _isConnectedWithEditor;
}
- (void)disconnectWithEditor{
    
    if(self.isConnectedWithEditor){
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IUNotificationMQAdded object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IUNotificationMQRemoved object:nil];
        
        for (IUSheet *sheet in self.allSheets) {
            [sheet disconnectWithEditor];
        }
        
        _isConnectedWithEditor = NO;
    }
}

-(void)dealloc{
    [self disconnectWithEditor];
    JDSectionInfoLog(IULogDealloc, @"");
}


#pragma mark - Manager
- (NSUndoManager *)undoManager{
    return [[[[NSApp mainWindow] windowController] document] undoManager];
}


#if DEBUG
- (id <IUSourceManagerProtocol>)sourceManager{
    if(self.isConnectedWithEditor == NO){
        return nil;
    }
    
    if(_sourceManager){
        return _sourceManager;
    }
    else{
        return [(id<BBWindowProtocol>)[[NSApp mainWindow] windowController] sourceManager];
    }
}

#else
- (id <IUSourceManagerProtocol>)sourceManager{
    return [(id<BBWindowProtocol>)[[NSApp mainWindow] windowController] sourceManager];
}
#endif


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

- (NSInteger)maxViewPort{
    return [[self mqSizes][0] integerValue];
}

#pragma mark - compile

- (IUCompiler*)compiler{
    return _compiler;
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

#pragma mark - build

- (void)resetBuildPath{
    self.buildPath = @"$IUFileDirectory/$AppName_build";
    self.buildResourcePath = @"$IUBuildPath/resource";
}

- (NSString*)absoluteBuildPath{
    NSMutableString *str = [self.buildPath mutableCopy];
    if ([str containsString:@"$IUFileDirectory"]) {
        [str replaceOccurrencesOfString:@"$IUFileDirectory" withString:[[self path] stringByDeletingLastPathComponent] options:0 range:NSMakeRange(0, [str length])];
    }
    if ([str containsString:@"$AppName"]){
        [str replaceOccurrencesOfString:@"$AppName" withString:[self name] options:0 range:NSMakeRange(0, [str length])];
    }
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

#pragma mark - filemanager 

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath{
    if ([error code] == NSFileWriteFileExistsError) //error code for: The operation couldn’t be completed. File exists
        return YES;
    else
        return NO;
}



/** default css array
 */

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


- (BOOL)runnable{
    return NO;
}

- (IUServerInfo*)serverInfo{
    if (_serverInfo.localPath == nil) {
        _serverInfo.localPath = [self buildPath];
        _serverInfo.syncItem = [self.path lastPathComponent];
    }
    return _serverInfo;
}

#pragma mark - ius, resource

-(NSSet*)allIUs{
    NSMutableSet  *set = [NSMutableSet set];
    for (IUSheet *sheet in self.allSheets) {
        [set addObject:sheet];
        [set addObjectsFromArray:sheet.allChildren];
    }
    return [set copy];
}

- (NSArray *)childrenFiles{
    return @[_pageGroup, _classGroup];
}

- (NSArray *)allChildrenFileItems{
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.pageGroup.allChildrenFileItems];
    [array addObjectsFromArray:self.classGroup.allChildrenFileItems];
    return [array copy];
}
- (NSArray *)allLeafChildrenFileItems{
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.pageGroup.allLeafChildrenFileItems];
    [array addObjectsFromArray:self.classGroup.allLeafChildrenFileItems];
    return [array copy];
}

- (NSArray*)allSheets{
    NSMutableArray *allSheets = [NSMutableArray array];
    [allSheets addObjectsFromArray:self.pageGroup.allChildrenFileItems];
    [allSheets addObjectsFromArray:self.classGroup.allChildrenFileItems];
    
    
    NSArray *allFileItems = [allSheets copy];
    for(id<IUFileItemProtocol> child in allFileItems){
        if(child.isLeaf == NO){
            [allSheets removeObject:child];
        }
    }
    
    return allSheets;
}

- (IUClass *)classWithName:(NSString *)name{
    return [_classGroup sheetWithHtmlID:name];
}


- (id <IUFileItemProtocol>)parentFileItem{
    return nil;
}

- (IUSheetGroup*)pageGroup{
    return _pageGroup;
}
- (IUSheetGroup*)classGroup{
    return _classGroup;
}

- (void)addItem:(IUSheet *)sheet toSheetGroup:(IUSheetGroup *)sheetGroup __deprecated{
    /*FIXME : group 구조 바꿔야함. 동작테스트를 위해서 우선 옛날 구조 사용함 */

    if([sheetGroup isEqualTo:_pageGroup]){
        [self willChangeValueForKey:@"pageGroup"];
        [self willChangeValueForKey:@"pageSheets"];

    }
    else if([sheetGroup isEqualTo:_classGroup]){
        [self willChangeValueForKey:@"classGroup"];
        [self willChangeValueForKey:@"classSheets"];

    }
    
    [sheetGroup addFileItem:sheet];
    
    if([sheetGroup isEqualTo:_pageGroup]){
        [self didChangeValueForKey:@"pageGroup"];
        [self didChangeValueForKey:@"pageSheets"];

    }
    else if([sheetGroup isEqualTo:_classGroup]){
        [self didChangeValueForKey:@"classGroup"];
        [self didChangeValueForKey:@"classSheets"];

    }
}

- (void)removeItem:(IUSheet *)sheet toSheetGroup:(IUSheetGroup *)sheetGroup{
    /*
    NSAssert(0, @"to be deleted");
     */
    /*FIXME : group 구조 바꿔야함. 동작테스트를 위해서 우선 옛날 구조 사용함 */
    if([sheetGroup isEqualTo:_pageGroup]){
        [self willChangeValueForKey:@"pageGroup"];
        [self willChangeValueForKey:@"pageSheets"];
        
    }
    else if([sheetGroup isEqualTo:_classGroup]){
        [self willChangeValueForKey:@"classGroup"];
        [self willChangeValueForKey:@"classSheets"];
        
    }
    [sheetGroup removeFileItem:sheet];
    
    if([sheetGroup isEqualTo:_pageGroup]){
        [self didChangeValueForKey:@"pageGroup"];
        [self didChangeValueForKey:@"pageSheets"];
        
    }
    else if([sheetGroup isEqualTo:_classGroup]){
        [self didChangeValueForKey:@"classGroup"];
        [self didChangeValueForKey:@"classSheets"];
        
    }
    
}

- (NSData *)lastCreatedData{
    return _lastCreatedData;
}

- (NSData *)createData{
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:self];
    _lastCreatedData = [coder data];
    return _lastCreatedData;
}

- (IUProject *)project{
    return self;
}




@end