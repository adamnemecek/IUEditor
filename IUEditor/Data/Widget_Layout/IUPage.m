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
}

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"ic_background"];
}

#pragma mark - Initialize

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


- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        [self.css setValue:[NSColor whiteColor] forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
        
        [self.css eradicateTag:IUCSSTagPixelX];
        [self.css eradicateTag:IUCSSTagPixelY];
        [self.css eradicateTag:IUCSSTagPixelWidth];
        [self.css eradicateTag:IUCSSTagPixelHeight];

        [self.css eradicateTag:IUCSSTagPercentX];
        [self.css eradicateTag:IUCSSTagPercentY];
        [self.css eradicateTag:IUCSSTagPercentWidth];
        [self.css eradicateTag:IUCSSTagPercentHeight];

        _layout = [[options objectForKey:kIUPageLayout] intValue];
        [self makePageLayout:_layout project:project];
        
        [self.undoManager enableUndoRegistration];


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
- (void)makePageLayout:(IUPageLayout)layoutCode project:(id <IUProjectProtocol>)project{
    
    //memory allocation
    _pageContent = [[IUPageContent alloc] initWithProject:project options:nil];
    _pageContent.htmlID = @"pageContent";
    _pageContent.name = @"pageContent";
    
    if(layoutCode == IUPageLayoutSideBar || layoutCode == IUPageLayoutSideBar2
       || layoutCode == IUPageLayoutSideBarOnly){
        _sidebar = [[IUSidebar alloc] initWithProject:project options:nil];
        _sidebar.name = @"sidebar";
        _sidebar.prototypeClass = [project classWithName:@"sidebar"];

    }
    
    if(layoutCode == IUPageLayoutDefault ||
       layoutCode == IUPageLayoutSideBar ||
       layoutCode == IUPageLayoutSideBar2){
        
        _header = [[IUHeader alloc] initWithProject:project options:nil];
        _header.name = @"header";
        _header.prototypeClass = [project classWithName:@"header"];
        
        _footer = [[IUFooter alloc] initWithProject:project options:nil];
        _footer.name = @"footer";
        _footer.prototypeClass = [project classWithName:@"footer"];
    }
    
    //initialize css
    [self initializeLayoutCSS:layoutCode];
    
    //순서대로 넣어야함
    if(_header){
        [self addIU:_header error:nil];
    }
    if(_sidebar){
        [self addIU:_sidebar error:nil];
    }
    if(_pageContent){
        [self addIU:_pageContent error:nil];
    }
    if(_footer){
        [self addIU:_footer error:nil];
    }
}

- (void)initializeLayoutCSS:(IUPageLayout)layoutCode{
    
    switch (layoutCode) {
        case IUPageLayoutDefault:
            //do nothing - default css 
            break;
        case IUPageLayoutSideBarOnly:
            [_sidebar.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
            [_sidebar.css setValue:@(15) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
            _sidebar.type = IUSidebarTypeFull;
            
            _pageContent.positionType = IUPositionTypeFloatRight;
            [_pageContent.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
            [_pageContent.css setValue:@(85) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
            [_pageContent.css setValue:@(YES) forTag:IUCSSTagHeightUnitIsPercent forViewport:IUCSSDefaultViewPort];
            [_pageContent.css setValue:@(100) forTag:IUCSSTagPercentHeight forViewport:IUCSSDefaultViewPort];
            break;
        case IUPageLayoutSideBar:
            //sidebar가 header, footer 사이에
            _sidebar.type = IUSidebarTypeInside;
            [_sidebar.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
            [_sidebar.css setValue:@(15) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
            
            _pageContent.positionType = IUPositionTypeFloatRight;
            [_pageContent.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
            [_pageContent.css setValue:@(85) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
            [_pageContent.css setValue:@(YES) forTag:IUCSSTagHeightUnitIsPercent forViewport:IUCSSDefaultViewPort];
            [_pageContent.css setValue:@(100) forTag:IUCSSTagPercentHeight forViewport:IUCSSDefaultViewPort];
            _footer.positionType = IUPositionTypeFloatLeft;
            
            break;
        case IUPageLayoutSideBar2:
            //sidebar가 header, footer 왼쪽에
            _sidebar.type = IUSidebarTypeFull;
            [_sidebar.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
            [_sidebar.css setValue:@(15) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];

            _header.positionType = IUPositionTypeFloatRight;
            [_header.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
            [_header.css setValue:@(85) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];

            
            _pageContent.positionType = IUPositionTypeFloatRight;
            [_pageContent.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
            [_pageContent.css setValue:@(85) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
            [_pageContent.css setValue:@(YES) forTag:IUCSSTagHeightUnitIsPercent forViewport:IUCSSDefaultViewPort];
            [_pageContent.css setValue:@(100) forTag:IUCSSTagPercentHeight forViewport:IUCSSDefaultViewPort];
            
            _footer.positionType = IUPositionTypeFloatRight;
            [_footer.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
            [_footer.css setValue:@(85) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];

        default:
            break;
    }
    
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
    NSAssert(self.project, @"");
    
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


-(IUPageContent *)pageContent{
    return _pageContent;
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


- (BOOL)floatRightChangeable{
    return NO;
}

- (BOOL)canChangePositionType{
    return NO;
}

- (BOOL)canChangeOverflow{
    return NO;
}



@end