//
//  IUWordpressProject.m
//  IUEditor
//
//  Created by jd on 2014. 7. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUWordpressProject.h"
#import "IUEventVariable.h"
#import "JDShellUtil.h"


#import "IUPage.h"
#import "IUBackground+WP.h"
#import "IUPage+WP.h"
#import "IUClass.h"

#import "WPSidebar.h"

@implementation IUWordpressProject

#pragma mark - class attributes

+ (NSArray *)widgetList{
    NSMutableArray *defaultList = [[super widgetList] mutableCopy];
    [defaultList addObjectsFromArray:@[@"WPSiteTitle", @"WPSiteDescription", @"WPMenu",
                                       @"WPArticleList", @"WPPageLinks", @"WPSidebar",
                                       ]];
    return defaultList;
}

#pragma mark - init


- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    _port = [aDecoder decodeIntForKey:@"_port"];
    _documentRoot = [aDecoder decodeObjectForKey:@"_documentRoot"];
    
    //theme meta property
    _uri = [aDecoder decodeObjectForKey:@"_uri"];
    _tags = [aDecoder decodeObjectForKey:@"_tags"];
    _version = [aDecoder decodeObjectForKey:@"_version"];
    _themeDescription = [aDecoder decodeObjectForKey:@"_themeDescription"];
    
    _compiler.webTemplateFileName = @"wpWebTemplate";
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder{
    [super encodeWithCoder:encoder];
    [encoder encodeInteger:_port forKey:@"_port"];
    [encoder encodeObject:_documentRoot forKey:@"_documentRoot"];
    
    [encoder encodeObject:_uri forKey:@"_uri"];
    [encoder encodeObject:_tags forKey:@"_tags"];
    [encoder encodeObject:_version forKey:@"_version"];
    [encoder encodeObject:_themeDescription forKey:@"_themeDescription"];

}

- (BOOL)runnable{
    return YES;
}

- (id)initWithCreation:(NSDictionary *)options error:(NSError *__autoreleasing *)error{
    
    _port = 0;
    _documentRoot = [NSString stringWithFormat:@"~%@/wordpress", NSUserName()];
    _mqSizes = [NSMutableArray arrayWithArray:@[@(defaultFrameWidth), @320]];
    
    _compiler = [[IUCompiler alloc] init];
    _compiler.webTemplateFileName = @"wpWebTemplate";
    
    _resourceManager = [[IUResourceManager alloc] init];
    _compiler.resourceManager = _resourceManager;
    _identifierManager = [[IUIdentifierManager alloc] init];
    
    NSAssert(options[IUProjectKeyAppName], @"app Name");
    NSAssert(options[IUProjectKeyIUFilePath], @"path");
    
    self.name = [options objectForKey:IUProjectKeyAppName];
    self.path = [options objectForKey:IUProjectKeyIUFilePath];
    
    self.buildPath = @"$IUFileDirectory/$AppName";
    self.buildResourcePath = @"$IUBuildPath/resource";

    _pageGroup = [[IUSheetGroup alloc] init];
    _pageGroup.name = IUPageGroupName;
    _pageGroup.project = self;
    
    
    _classGroup = [[IUSheetGroup alloc] init];
    _classGroup.name = IUClassGroupName;
    _classGroup.project = self;
    
    
    IUPage *home = [[IUPage alloc] initWithProject:self options:nil];
    [home WPInitializeAsHome];
    home.name = @"home";
    home.htmlID = @"home";
    [self addSheet:home toSheetGroup:_pageGroup];
    
    IUPage *index = [[IUPage alloc] initWithProject:self options:nil];
    [index WPInitializeAsIndex];
    index.name = @"index";
    index.htmlID = @"index";
    [self addSheet:index toSheetGroup:_pageGroup];


    IUPage *_404 = [[IUPage alloc] initWithProject:self options:nil];
    [_404 WPInitializeAs404];
    _404.name = @"_404";
    _404.htmlID = @"_404";
    [self addSheet:_404 toSheetGroup:_pageGroup];

    IUClass *commentWrapper = [[IUClass alloc] initWithProject:self options:nil];
    commentWrapper.name = @"commentWrapper";
    commentWrapper.htmlID = @"commentWrapper";
    [self addSheet:commentWrapper toSheetGroup:_classGroup];


    IUClass *class = [[IUClass alloc] initWithProject:self options:nil];
    class.name = @"class";
    class.htmlID = @"class";
    [self addSheet:class toSheetGroup:_classGroup];
    
    [self initializeResource];
    [_resourceManager setResourceGroup:_resourceGroup];
    [_identifierManager registerIUs:self.allDocuments];
    
    //    ReturnNilIfFalse([self save]);
    _serverInfo = [[IUServerInfo alloc] init];
    _serverInfo.localPath = [self path];
    return self;
}


- (NSString*)absoluteBuildPathForSheet:(IUSheet *)sheet{
    NSString *extension = (self.compiler.rule == IUCompileRuleWordpress) ? @"php" : @"html";
    NSString *filePath = [[self.absoluteBuildPath stringByAppendingPathComponent:sheet.name ] stringByAppendingPathExtension:extension];
    return filePath;
}

- (BOOL)build:(NSError *__autoreleasing *)error{
    BOOL result = [super build:error];
    if (result) {
        NSString *path = [self absoluteBuildPath];

        /* style.css : metainfo */
        JDCode *metaCode = [self.compiler wordpressMetaDataSource:self];
        NSString *stylePath = [[path stringByAppendingPathComponent:@"style"] stringByAppendingPathExtension:@"css"];
        [[NSFileManager defaultManager] removeItemAtPath:stylePath error:nil];
        if ([metaCode.string writeToFile:stylePath atomically:YES encoding:NSUTF8StringEncoding error:error] == NO){
            NSAssert(0, @"write fail");
        }
        
        /* build functions.php */
        NSString *functionPath = [[NSBundle mainBundle] pathForResource:@"functions" ofType:@"php"];
        NSMutableString *functionCode = [NSMutableString stringWithContentsOfFile:functionPath encoding:NSUTF8StringEncoding error:nil];
        
        NSArray *allIUs = [self.allIUs allObjects];
        NSArray *wpMenus = [allIUs filteredArrayWithClass:[WPSidebar class]];
        NSArray *wpNames = [wpMenus valueForKey:@"wordpressName"];
        if ([wpNames count]) {
            NSArray *wpNamesD = [[NSSet setWithArray:wpNames] allObjects];
            NSMutableString *wpNameString = [NSMutableString string];
            for (NSString *wpname in wpNamesD) {
                [wpNameString appendString:[NSString stringWithFormat:@"'%@',", wpname]];
            }
            [functionCode replaceOccurrencesOfString:@"/*WIDGET_DISABLE_COMMENT" withString:@"" options:0 range:[functionCode fullRange]];
            [functionCode replaceOccurrencesOfString:@"WIDGET_DISABLE_COMMENT*/" withString:@"" options:0 range:[functionCode fullRange]];
            [functionCode replaceOccurrencesOfString:@"_IU_WIDGET_NAMES_" withString:wpNameString options:0 range:[functionCode fullRange]];
        }
        
        NSString *functionCodeFilePath = [self.absoluteBuildPath stringByAppendingPathComponent:@"functions.php"];
        
        NSError *err;
        [functionCode writeToFile:functionCodeFilePath atomically:YES encoding:NSUTF8StringEncoding error:&err];
        if (err) {
            [JDLogUtil alert:err.description];
        }
    }
    return result;
}

- (void)resetBuildPath{
    self.buildPath = @"$IUFileDirectory/$AppName";
    self.buildResourcePath = @"$IUBuildPath/resource";
}
@end
