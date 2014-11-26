//
//  IUPage.m
//  IUEditor
//
//  Created by jd on 3/18/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUPage.h"
#import "IUBackground.h"
#import "IUPageContent.h"
#import "IUImport.h"
#import "IUProject.h"

@implementation IUPage{
    IUPageContent *_pageContent;
    
    IUHeader *_header; __storage_deprecated//it should be weak at storage mode
    IUSidebar *_sidebar;  __storage_deprecated//it should be weak at storage mode
    IUFooter *_footer;  __storage_deprecated//it should be weak at storage mode
    
    IUPageLayout _layout;
}

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"ic_background"];
}



#pragma mark - Initialize

-(void)loadPresetWithLayout:(IUPageLayout)layout header:(IUHeader*)header footer:(IUFooter*)footer sidebar:(IUSidebar*)sidebar {
    _layout = layout;
    _header = header;
    _sidebar = sidebar;
    _footer = footer;
    [self loadPreset_makeCSS];
}

- (id)init{
    self = [super init];
    _pageContent = [[IUPageContent alloc] init];
    _layout = IUPageLayoutNone;
    return self;
}

- (id)initWithPreset {
    self = [super initWithPreset];
    
    _pageContent = [[IUPageContent alloc] initWithPreset];
    _layout = IUPageLayoutDefault;
    
    [self addIU:_pageContent error:nil];
    
    return self;
}

- (id)initWithPresetWithLayout:(IUPageLayout)layout header:(IUHeader *)header footer:(IUFooter *)footer sidebar:(IUSidebar *)sidebar{
    self = [super initWithPreset];
    _pageContent = [[IUPageContent alloc] initWithPreset];
    
    _layout = layout;
    _header = header;
    _sidebar = sidebar;
    _footer = footer;
    
    if (_header) {
        [self addIU:_header error:nil];
    }
    if (_sidebar) {
        [self addIU:_sidebar error:nil];
    }
    [self addIU:_pageContent error:nil];
    if (_footer) {
        [self addIU:_footer error:nil];
    }
    
    [self loadPreset_makeCSS];
    
    return self;
}


-(IUPageLayout)layout {
    return _layout;
}

-(IUHeader *)header {
    return  _header;
}

-(IUFooter *)footer {
    return _footer;
}

-(IUSidebar *)sidebar{
    return _sidebar;
}

-(IUPageContent *)pageContent{
    return _pageContent;
}

- (void)loadPreset_makeCSS{
    switch (_layout) {
        case IUPageLayoutDefault:
            _header.defaultPositionStorage.position = @(IUPositionTypeRelative);
            _pageContent.defaultPositionStorage.position = @(IUPositionTypeRelative);
            break;
        case IUPageLayoutSideBarOnly:
            
            _sidebar.type = IUSidebarTypeFull;
            [_sidebar.defaultStyleStorage setWidth:@(15) unit:@(IUFrameUnitPercent)];
            
            _pageContent.defaultPositionStorage.position = @(IUPositionTypeFloatRight);
            [_pageContent.defaultStyleStorage setWidth:@(85) unit:@(IUFrameUnitPercent)];
            [_pageContent.defaultStyleStorage setHeight:@(100) unit:@(IUFrameUnitPercent)];
            
            break;
            
        case IUPageLayoutSideBar:
            _sidebar.type = IUSidebarTypeInside;
            [_sidebar.defaultStyleStorage setWidth:@(15) unit:@(IUFrameUnitPercent)];
            
            _pageContent.defaultPositionStorage.position = @(IUPositionTypeFloatRight);
            [_pageContent.defaultStyleStorage setWidth:@(85) unit:@(IUFrameUnitPercent)];
            [_pageContent.defaultStyleStorage setHeight:@(100) unit:@(IUFrameUnitPercent)];

            _footer.defaultPositionStorage.position = @(IUPositionTypeFloatLeft);
            
            break;
        case IUPageLayoutSideBar2:
            
            _sidebar.type = IUSidebarTypeFull;
            [_sidebar.defaultStyleStorage setWidth:@(15) unit:@(IUFrameUnitPercent)];
            
            _header.defaultPositionStorage.position = @(IUPositionTypeFloatRight);
            [_header.defaultStyleStorage setWidth:@(85) unit:@(IUFrameUnitPercent)];

            _pageContent.defaultPositionStorage.position = @(IUPositionTypeFloatRight);
            [_pageContent.defaultStyleStorage setWidth:@(85) unit:@(IUFrameUnitPercent)];
            [_pageContent.defaultStyleStorage setHeight:@(100) unit:@(IUFrameUnitPercent)];

            _footer.defaultPositionStorage.position = @(IUPositionTypeFloatLeft);
            [_footer.defaultStyleStorage setWidth:@(85) unit:@(IUFrameUnitPercent)];
            
        default:
            break;
    }
    
}




#pragma mark - Storage deprecated

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_pageContent forKey:@"pageContent"];
    [aCoder encodeFromObject:self withProperties:[IUPage properties]];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        
        [aDecoder decodeToObject:self withProperties:[IUPage properties]];
        _pageContent = [aDecoder decodeObjectForKey:@"pageContent"];
        [_pageContent bind:@"delegate" toObject:self withKeyPath:@"delegate" options:nil];
        
    }
    return self;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    [super awakeAfterUsingCoder:aDecoder];
    if(self.project && IU_VERSION_V1_GREATER_THAN_V2(IU_VERSION_LAYOUT, self.project.IUProjectVersion) ){
        [self addIU:_pageContent error:nil];
    }
    //default == absolute로
    if(self.positionType == IUPositionTypeRelative){
        self.positionType = IUPositionTypeAbsolute;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    [[self undoManager] disableUndoRegistration];

    IUPage *page = [super copyWithZone:zone];
    [_canvasVC disableUpdateAll:self];
    
    page.title = [_title copy];
    page.keywords = [_keywords copy];
    page.desc = [_desc copy];
    page.metaImage = [_metaImage copy];
    page.extraCode = [_extraCode copy];
    page.googleCode = [_googleCode copy];
    
    [_canvasVC enableUpdateAll:self];
    [[self undoManager] enableUndoRegistration];
    return page;
}

- (void)connectWithEditor{
//    NSAssert(self.project, @"");
    
    [[self undoManager] disableUndoRegistration];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMQSelect:) name:IUNotificationMQSelected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMQSize:) name:IUNotificationMQAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeMQSize:) name:IUNotificationMQRemoved object:nil];
    
    for(IUBox *iu in self.children){
        [iu connectWithEditor];
    }
    [[self undoManager] enableUndoRegistration];
}

- (void)disconnectWithEditor{
    if([self isConnectedWithEditor]){
        for(IUBox *iu in self.children){
            [iu disconnectWithEditor];
        }
    }
    [super disconnectWithEditor];
}

- (BOOL)shouldCompileHeight{
    return NO;
}

- (BOOL)shouldCompileWidth{
    return NO;
}

- (BOOL)shouldCompileY{
    return NO;
}

- (BOOL)shouldCompileX{
    return NO;
}


- (void)setCanvasVC:(id<IUSourceDelegate>)canvasVC{
    [super setCanvasVC:canvasVC];
    [_pageContent setCanvasVC:canvasVC];
}

#pragma mark - property

- (void)setTitle:(NSString *)title{
    if([_title isEqualToString:title]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setTitle:_title];
    _title = title;
}

- (void)setKeywords:(NSString *)keywords{
    if([_keywords isEqualToString:keywords]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setKeywords:_keywords];
    _keywords = keywords;
}

- (void)setDesc:(NSString *)desc{
    if([_desc isEqualToString:desc]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setDesc:_desc];
    _desc = desc;
}

- (void)setMetaImage:(NSString *)metaImage{
    if([_metaImage isEqualToString:metaImage]){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setMetaImage:_metaImage];
    _metaImage = metaImage;
}


#pragma mark - shouldXXX, canXXX

- (BOOL)canCopy{
    return NO;
}


-(BOOL)canRemoveIUByUserInput{
    return NO;
}

-(BOOL)canAddIUByUserInput{
    return NO;
}


- (BOOL)canChangePositionType{
    return NO;
}

- (BOOL)canChangeOverflow{
    return NO;
}


@end