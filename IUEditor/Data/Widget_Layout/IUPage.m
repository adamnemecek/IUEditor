//
//  IUPage.m
//  IUEditor
//
//  Created by jd on 3/18/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUPage.h"
#import "IUClass.h"
#import "IUBackground.h"
#import "IUPageContent.h"
#import "IUImport.h"
#import "IUProject.h"

@implementation IUPage{
    
    //page has only 4 children as below
    IUPageContent *_pageContent;
    IUHeader *_header;
    IUSidebar *_sidebar;
    IUFooter *_footer;
    
    //page layout
    IUPageLayout _layout;
}

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"ic_page"];
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

- (NSArray *)children{
    NSMutableArray *childrenArray = [ NSMutableArray array];
    [childrenArray addObject:_pageContent];
    if(_header){
        [childrenArray addObject:_header];
    }
    if(_footer){
        [childrenArray addObject:_footer];
    }
    if(_sidebar){
        [childrenArray addObject:_sidebar];
    }
    
    return [childrenArray copy];
}

- (void)loadPreset_makeCSS{
    switch (_layout) {
        case IUPageLayoutDefault:
            _header.defaultPositionStorage.firstPosition = @(IUFirstPositionTypeRelative);
            _pageContent.defaultPositionStorage.firstPosition = @(IUFirstPositionTypeRelative);
            break;
        case IUPageLayoutSideBarOnly:
            
            _sidebar.type = IUSidebarTypeFull;
            [_sidebar.defaultStyleStorage setWidth:@(15) unit:@(IUFrameUnitPercent)];
            
            _pageContent.defaultPositionStorage.firstPosition = @(IUFirstPositionTypeRelative);
            _pageContent.defaultPositionStorage.secondPosition = @(IUSecondPositionTypeFloatRight);
            [_pageContent.defaultStyleStorage setWidth:@(85) unit:@(IUFrameUnitPercent)];
            [_pageContent.defaultStyleStorage setHeight:@(100) unit:@(IUFrameUnitPercent)];
            
            break;
            
        case IUPageLayoutSideBar:
            _sidebar.type = IUSidebarTypeInside;
            [_sidebar.defaultStyleStorage setWidth:@(15) unit:@(IUFrameUnitPercent)];
            
            _pageContent.defaultPositionStorage.firstPosition = @(IUFirstPositionTypeRelative);
            _pageContent.defaultPositionStorage.secondPosition = @(IUSecondPositionTypeFloatRight);
            [_pageContent.defaultStyleStorage setWidth:@(85) unit:@(IUFrameUnitPercent)];
            [_pageContent.defaultStyleStorage setHeight:@(100) unit:@(IUFrameUnitPercent)];

            
            _footer.defaultPositionStorage.firstPosition = @(IUFirstPositionTypeRelative);
            _footer.defaultPositionStorage.secondPosition = @(IUSecondPositionTypeFloatLeft);
            
            break;
        case IUPageLayoutSideBar2:
            
            _sidebar.type = IUSidebarTypeFull;
            [_sidebar.defaultStyleStorage setWidth:@(15) unit:@(IUFrameUnitPercent)];
            
            _header.defaultPositionStorage.firstPosition = @(IUFirstPositionTypeRelative);
            _header.defaultPositionStorage.secondPosition = @(IUSecondPositionTypeFloatRight);
            [_header.defaultStyleStorage setWidth:@(85) unit:@(IUFrameUnitPercent)];

            _pageContent.defaultPositionStorage.firstPosition = @(IUFirstPositionTypeRelative);
            _pageContent.defaultPositionStorage.secondPosition = @(IUSecondPositionTypeFloatRight);

            [_pageContent.defaultStyleStorage setWidth:@(85) unit:@(IUFrameUnitPercent)];
            [_pageContent.defaultStyleStorage setHeight:@(100) unit:@(IUFrameUnitPercent)];

            _footer.defaultPositionStorage.firstPosition = @(IUFirstPositionTypeRelative);
            _footer.defaultPositionStorage.secondPosition = @(IUSecondPositionTypeFloatLeft);

            [_footer.defaultStyleStorage setWidth:@(85) unit:@(IUFrameUnitPercent)];
            
        default:
            break;
    }
    
}




#pragma mark - Storage deprecated
- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    
    [aCoder encodeObject:_pageContent forKey:@"pageContent"];
    [aCoder encodeObject:_header forKey:@"header"];
    [aCoder encodeObject:_footer forKey:@"footer"];
    [aCoder encodeObject:_sidebar forKey:@"sidebar"];
    [aCoder encodeInteger:_layout forKey:@"layout"];
    
    [aCoder encodeFromObject:self withProperties:[IUPage properties]];

}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [aDecoder decodeToObject:self withProperties:[IUPage properties]];
        _pageContent = [aDecoder decodeObjectForKey:@"pageContent"];
        _header = [aDecoder decodeObjectForKey:@"header"];
        _footer = [aDecoder decodeObjectForKey:@"footer"];
        _sidebar = [aDecoder decodeObjectForKey:@"sidebar"];
        _layout = (IUPageLayout)[aDecoder decodeIntegerForKey:@"layout"];

    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    [[self undoManager] disableUndoRegistration];

    IUPage *page = [super copyWithZone:zone];
    
    page.title = [_title copy];
    page.keywords = [_keywords copy];
    page.desc = [_desc copy];
    page.metaImage = [_metaImage copy];
    page.extraCode = [_extraCode copy];
    page.googleCode = [_googleCode copy];
    
    [[self undoManager] enableUndoRegistration];
    return page;
}

-(NSSet *)includedClass {
    NSSet *set = [NSSet setWithArray:[[self allChildren] filteredArrayWithClass:[IUClass class]]];
    return set;
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