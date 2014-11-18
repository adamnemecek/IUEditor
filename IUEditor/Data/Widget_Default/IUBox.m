//
//  IUBox.m
//  IUEditor
//
//  Created by JD on 3/18/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUIdentifierManager.h"
#import "IUSourceManager.h"
#import "LMWC.h"

#import "IUBox.h"
#import "NSObject+JDExtension.h"
#import "NSCoder+JDExtension.h"
#import "IUCSSCompiler.h"

#import "IUCompiler.h"

#import "IUSheet.h"
#import "IUBox.h"
#import "IUClass.h"
#import "IUProject.h"
#import "IUItem.h"
#import "IUImport.h"
#import "IUPage.h"

@interface IUBox()
@end

@implementation IUBox{
    NSMutableSet *changedCSSWidths;
    
    //for cssManager tuple dictionary
    NSMutableDictionary *cssManagersDict;
    
    //for undo
    NSMutableDictionary *undoFrameDict;
    
    //for draggin precisely
    NSPoint originalPoint, originalPercentPoint;
    NSSize originalSize, originalPercentSize;
    
    __weak IUProject *_tempProject;
    BOOL    _isConnectedWithEditor;
    BOOL _isEnabledFrameUndo;
}
#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_view"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_view"];
}

+ (NSString *)shortDescription{
    NSString *key = [NSString stringWithFormat:@"%@_short_description", [self className]];
    return NSLocalizedStringFromTable(key, @"description", @"iubox short description");
}

+ (IUWidgetType)widgetType{
    return IUWidgetTypePrimary;
}

/* Note
 IUText is not programmed.
 */
#pragma mark - initialize


-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super init];
    if (self) {

        [aDecoder decodeToObject:self withProperties:[[IUBox class] propertiesWithOutProperties:@[@"delegate", @"textType", @"linkCaller"]]];
        
        //VERSION COMPABILITY: texttype decode int issue
        @try {
            _textType = [aDecoder decodeInt32ForKey:@"textType"] ;
        }
        @catch (NSException *exception) {
            _textType = IUTextTypeDefault;
        }
        
        
        _css = [aDecoder decodeObjectForKey:@"css"];
        _css.delegate = self;
        
        //move css to cssStorage
        
        _mqData = [aDecoder decodeObjectForKey:@"mqData"];
        _mqData.delegate = self;
        
        _event = [aDecoder decodeObjectForKey:@"event"];
        changedCSSWidths = [NSMutableSet set];
        if ([self.htmlID length] == 0) {
            self.htmlID = [NSString randomStringWithLength:8];
        }
        NSAssert([self.htmlID length] != 0 , @"");
        
        //create storage
        cssManagersDict = [NSMutableDictionary dictionary];
        [self setCssManager:[_css convertToStorageDefaultManager] forSelector:kIUCSSManagerDefault];
        [self setCssManager:[_css convertToStorageHoverManager] forSelector:kIUCSSManagerHover];


    }
    return self;
}


-(id)initWithJDCoder:(JDCoder *)aDecoder{
    
    _htmlID = [aDecoder decodeObjectForKey:@"htmlID"];
//    _css = [aDecoder decodeObjectForKey:@"css"];
    _mqData = [aDecoder decodeObjectForKey:@"mqData"];
    _m_children = [aDecoder decodeObjectForKey:@"children"];
    
    return self;
}

- (void)awakeAfterUsingJDCoder:(JDCoder *)aDecoder{
    _link = [aDecoder decodeByRefObjectForKey:@"link"];
    _parent = [aDecoder decodeByRefObjectForKey:@"parent"];
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder encodeObject:self.htmlID forKey:@"htmlID"];
//    [aCoder encodeObject:self.css forKey:@"css"];
    [aCoder encodeObject:self.mqData forKey:@"mqData"];
    [aCoder encodeObject:self.children forKey:@"children"];
    [aCoder encodeByRefObject:self.link forKey:@"link"];
    [aCoder encodeByRefObject:self.parent forKey:@"parent"];
}


/**
 Review: _m_children의 decode는 순서가 꼬이기 때문에 initWithCoder가 아닌 awkaAfterUsingCoder로 하도록한다.
 (self가 다 할당되기전에 children이 먼저 할당 되면서 발생하는 문제 제거)
 */
- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    [super awakeAfterUsingCoder:aDecoder];
    
    _m_children = [aDecoder decodeObjectForKey:@"children"];
    
    
    //version Control
    if(self.project){
        if(IU_VERSION_V1_GREATER_THAN_V2(IU_VERSION_LAYOUT, self.project.IUProjectVersion)){
            _enableHCenter = [aDecoder decodeInt32ForKey:@"enableCenter"];
        }
        
        if(IU_VERSION_V1_GREATER_THAN_V2(IU_VERSION_FONTFIX, self.project.IUProjectVersion)){
            NSDictionary *dict = _css.effectiveTagDictionary;
            if(dict[IUCSSTagFontWeight]){
                BOOL bold = [dict[IUCSSTagFontWeight] boolValue];
                [_css eradicateTag:IUCSSTagFontWeight];
                if(bold){
                    [_css setValue:@"700" forTag:IUCSSTagFontWeight forViewport:IUCSSDefaultViewPort];
                }
                else{
                    [_css setValue:@"400" forTag:IUCSSTagFontWeight forViewport:IUCSSDefaultViewPort];
                }
            }
            
            NSString *fontName = dict[IUCSSTagFontName];
            if(fontName && [fontName containsString:@"Roboto"]){
                [_css eradicateTag:IUCSSTagFontName];
                [_css setValue:@"Roboto" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];
                if([fontName containsString:@"Light"] || [fontName containsString:@"Thin"]){
                    [_css eradicateTag:IUCSSTagFontWeight];
                    [_css setValue:@"300" forTag:IUCSSTagFontWeight forViewport:IUCSSDefaultViewPort];
                }
            }
        }
        if(IU_VERSION_V1_GREATER_THAN_V2(IU_VERSION_TEXTMCE, self.project.IUProjectVersion)){
            _mqData = [[IUMQData alloc] init];
            _mqData.delegate = self;
            
            //sampletext가 아니고 innerHTML로 동작해야 하는경우에는 mqdata로 옮겨준다.
            if(_text && _text.length > 0 && [self textInputType] == IUTextInputTypeEditable ){
                NSString *innerHTML = [NSString stringWithFormat:@"<p>%@</p>", _text];
                innerHTML = [innerHTML stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
                [_mqData setValue:innerHTML forTag:IUMQDataTagInnerHTML forViewport:IUCSSDefaultViewPort];
                _text = nil;
            }
        }
        
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    if ([self.htmlID length] == 0) {
#ifdef DEBUG
        NSAssert(0, @"");
#endif 
        self.htmlID = [NSString randomStringWithLength:8];
    }
    [aCoder encodeFromObject:self withProperties:[[IUBox class] propertiesWithOutProperties:@[@"identifierManager", @"textController", @"linkCaller", @"cssManager"]]];
    [aCoder encodeObject:_css forKey:@"css"];
    [aCoder encodeObject:_mqData forKey:@"mqData"];
    [aCoder encodeObject:_event forKey:@"event"];
    [aCoder encodeObject:_m_children forKey:@"children"];
    
}

-(id)initWithPreset {
    self = [self init];
    self.liveCSSStorage.bgColor = [NSColor randomLightMonoColor];
    self.name = self.className;
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        _css = [[IUCSS alloc] init];
        _css.delegate = self;
        
        _mqData = [[IUMQData alloc] init];
        _mqData.delegate = self;
        
        _event = [[IUEvent alloc] init];
        _m_children = [NSMutableArray array];
        
        changedCSSWidths = [NSMutableSet set];

        //create storage
        cssManagersDict = [NSMutableDictionary dictionary];
        IUCSSStorageManager *cssManager = [[IUCSSStorageManager alloc] init];
        [self setCssManager:cssManager forSelector:kIUCSSManagerDefault];
        if (self.cssDefaultManager) {
            [self bind:@"liveCSSStorage" toObject:self.cssDefaultManager withKeyPath:@"liveStorage" options:nil];
            [self bind:@"currentCSSStorage" toObject:self.cssDefaultManager withKeyPath:@"currentStorage" options:nil];
            [self bind:@"defaultCSSStorage" toObject:self.cssDefaultManager withKeyPath:@"defaultStorage" options:nil];
        }
        IUCSSStorageManager *cssHoverManager = [[IUCSSStorageManager alloc] init];
        [self setCssManager:cssHoverManager forSelector:kIUCSSManagerHover];

        
        _htmlID = [NSString stringWithFormat:@"%@%d",self.className, rand()];
        _name = _htmlID;
    }
    return self;
}




-(id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super init];
    if(self){
        
        [[self undoManager] disableUndoRegistration];
        
        _tempProject = project;
        _css = [[IUCSS alloc] init];
        _css.delegate = self;
        
        _mqData = [[IUMQData alloc] init];
        _mqData.delegate = self;
        
        _event = [[IUEvent alloc] init];
        _m_children = [NSMutableArray array];
        _lineHeightAuto = NO;
        
        _overflowType = IUOverflowTypeHidden;
        /*
         set HTMLID for temporary : IUResourceManager and IdentifierManager can be nil for test
         */
        _htmlID = [NSString stringWithFormat:@"%@%d",self.className, rand()];
        
        [_css setValue:@(0) forTag:IUCSSTagXUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [_css setValue:@(0) forTag:IUCSSTagYUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [_css setValue:@(0) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [_css setValue:@(0) forTag:IUCSSTagHeightUnitIsPercent forViewport:IUCSSDefaultViewPort];
        
        [_css setValue:@(100) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        [_css setValue:@(60) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        
        //background
        [_css setValue:[NSColor randomLightMonoColor] forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
        [_css setValue:@(IUBGSizeTypeAuto) forTag:IUCSSTagBGSize forViewport:IUCSSDefaultViewPort];
        [_css setValue:@(0) forTag:IUCSSTagBGXPosition forViewport:IUCSSDefaultViewPort];
        [_css setValue:@(0) forTag:IUCSSTagBGYPosition forViewport:IUCSSDefaultViewPort];
        
        //border
        [_css setValue:@(0) forTag:IUCSSTagBorderTopWidth forViewport:IUCSSDefaultViewPort];
        [_css setValue:@(0) forTag:IUCSSTagBorderLeftWidth forViewport:IUCSSDefaultViewPort];
        [_css setValue:@(0) forTag:IUCSSTagBorderRightWidth forViewport:IUCSSDefaultViewPort];
        [_css setValue:@(0) forTag:IUCSSTagBorderBottomWidth forViewport:IUCSSDefaultViewPort];
        
        [_css setValue:[NSColor rgbColorRed:0 green:0 blue:0 alpha:1] forTag:IUCSSTagBorderTopColor forViewport:IUCSSDefaultViewPort];
        [_css setValue:[NSColor rgbColorRed:0 green:0 blue:0 alpha:1] forTag:IUCSSTagBorderLeftColor forViewport:IUCSSDefaultViewPort];
        [_css setValue:[NSColor rgbColorRed:0 green:0 blue:0 alpha:1] forTag:IUCSSTagBorderRightColor forViewport:IUCSSDefaultViewPort];
        [_css setValue:[NSColor rgbColorRed:0 green:0 blue:0 alpha:1] forTag:IUCSSTagBorderBottomColor forViewport:IUCSSDefaultViewPort];
        
        //font-type
        [_css setValue:@(1.0) forTag:IUCSSTagLineHeight forViewport:IUCSSDefaultViewPort];
        [_css setValue:@(IUAlignCenter) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
        
        
        if ([project respondsToSelector:@selector(identifier)]) {
            if (options[IUFileName]) {
                [project.identifierManager setIdentifierAndRegisterToTemp:self identifier:options[IUFileName]];
            }
            else {
                [project.identifierManager setNewIdentifierAndRegisterToTemp:self withKey:nil];
            }
        }
        self.name = self.htmlID;
        
        cssManagersDict = [NSMutableDictionary dictionary];
        IUCSSStorageManager *cssManager = [[IUCSSStorageManager alloc] init];
        [self setCssManager:cssManager forSelector:kIUCSSManagerDefault];
        if (self.cssDefaultManager) {
            
            [self bind:@"liveCSSStorage" toObject:self.cssDefaultManager withKeyPath:@"liveStorage" options:nil];
            [self bind:@"currentCSSStorage" toObject:self.cssDefaultManager withKeyPath:@"currentStorage" options:nil];
        }
        
        IUCSSStorageManager *cssHoverManager = [[IUCSSStorageManager alloc] init];
        [self setCssManager:cssHoverManager forSelector:kIUCSSManagerHover];



        [[self undoManager] enableUndoRegistration];
        
    }
    
    return self;
}



- (void)connectWithEditor{
    NSAssert(self.project, @"");
    
    
    [[self undoManager] disableUndoRegistration];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMQSelect:) name:IUNotificationMQSelected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMQSize:) name:IUNotificationMQAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeMQSize:) name:IUNotificationMQRemoved object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(structureChanged:) name:IUNotificationStructureDidChange object:self.project];
    
    
    for (IUBox *box in self.children) {
        [box connectWithEditor];
    }
    
    _isEnabledFrameUndo = NO;
    [[self undoManager] enableUndoRegistration];

}
- (void)disconnectWithEditor{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (IUBox *box in self.children) {
        [box disconnectWithEditor];
    }
    _isConnectedWithEditor = NO;
    
}

- (void)dealloc{
    if([self isConnectedWithEditor]){
        [self disconnectWithEditor];
    }
}
#pragma mark - default box 

/**
 
 Some convenience methods to create iubox
 */
+(IUBox *)copyrightBoxWithProject:(id <IUProjectProtocol>)project{
    IUBox *copyright = [[IUBox alloc] initWithProject:project options:nil];
    [copyright.undoManager disableUndoRegistration];
    
    copyright.name = @"Copyright";
    [copyright.mqData setValue:@"Copyright (C) IUEditor all rights reserved" forTag:IUMQDataTagInnerHTML forViewport:IUCSSDefaultViewPort];

    copyright.enableHCenter = YES;
    [copyright.css setValue:@(40) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    [copyright.css eradicateTag:IUCSSTagPixelWidth];
    [copyright.css eradicateTag:IUCSSTagPixelHeight];
    [copyright.css eradicateTag:IUCSSTagBGColor];
    
    [copyright.css setValue:@"Roboto" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];
    [copyright.css setValue:@(12) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
    [copyright.css setValue:@(1.5) forTag:IUCSSTagLineHeight forViewport:IUCSSDefaultViewPort];
    [copyright.css setValue:@(IUAlignCenter) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
    [copyright.css setValue:[NSColor rgbColorRed:102 green:102 blue:102 alpha:1] forTag:IUCSSTagFontColor forViewport:IUCSSDefaultViewPort];
    
    
    [copyright.undoManager enableUndoRegistration];
    return copyright;
}


#pragma mark - copy

- (id)copyWithZone:(NSZone *)zone{
    
    [[self undoManager] disableUndoRegistration];
    [_canvasVC disableUpdateAll:self];

    IUBox *box = [[[self class] allocWithZone: zone] init];
    if(box){
        
        IUCSS *newCSS = [_css copy];
        IUMQData *newMQData = [_mqData copy];
        IUEvent *newEvent = [_event copy];
        NSArray *children = [self.children deepCopy];
        box.text = [_text copy];
        
        box.overflowType = _overflowType;
        box.positionType = _positionType;
        box.enableHCenter = _enableHCenter;
        box.enableVCenter = _enableVCenter;
        
        box.css = newCSS;
        newCSS.delegate  = box;
        
        box.mqData = newMQData;
        newMQData.delegate = box;
        
        box.event = newEvent;
        
        [box setCanvasVC:_canvasVC];
        [box setTempProject:self.project];
        
        for (IUBox *iu in children) {
            BOOL result = [box addIU:iu error:nil];
            NSAssert(result == YES, @"copy");
        }
        
        NSAssert(self.project, @"project");
        [self.project.identifierManager resetUnconfirmedIUs];
        [self.project.identifierManager setNewIdentifierAndRegisterToTemp:box withKey:@"copy"];
        box.name = box.htmlID;
        [box.project.identifierManager confirm];
        
        [box connectWithEditor];
        [box setIsConnectedWithEditor];
        
        [[self undoManager] enableUndoRegistration];
    }

    [_canvasVC enableUpdateAll:self];
    return box;
}
- (void)copyCSSFromIU:(IUBox *)box{
    IUCSS *newCSS = [box.css copy];
    _css = newCSS;
    _css.delegate = self;
}

- (BOOL)canCopy{
    return YES;
}
- (BOOL)canSelectedWhenOpenProject{
    return YES;
}

#pragma mark - css Manager
/* css manager */

- (NSArray *)allCSSSelectors{
    return [cssManagersDict allKeys];
}


- (void)setCssManager:(IUCSSStorageManager *)cssManager forSelector:(NSString *)selector{
//    cssManager.box = self;
    cssManagersDict[selector] = cssManager;
}

- (IUCSSStorageManager *)cssManagerForSelector:(NSString *)selector{
    return cssManagersDict[selector];
}
- (IUCSSStorageManager *)cssDefaultManager{
    return cssManagersDict[kIUCSSManagerDefault];
}
- (IUCSSStorageManager *)cssHoverManager{
    return cssManagersDict[kIUCSSManagerHover];
}


#pragma mark - Core Manager

- (NSUndoManager *)undoManager{
   return [[[[NSApp mainWindow] windowController] document] undoManager];
}

- (IUSourceManager *)sourceManager{
#if DEBUG
    if(_sourceManager){
        return _sourceManager;
    }
    else{
        return [(LMWC *)([[NSApp mainWindow] windowController]) sourceManager];
    }
#else
    return [(LMWC *)([[NSApp mainWindow] windowController]) sourceManager];
#endif
}

#pragma mark - setXXX

-(void)setCanvasVC:(id<IUSourceDelegate>)canvasVC{
    _canvasVC = canvasVC;
    for (IUBox *obj in _m_children) {
        [obj setCanvasVC:canvasVC];
    }
}

-(IUSheet*)sheet{
    if ([self isKindOfClass:[IUSheet class]]) {
        return (IUSheet*)self;
    }
    if (self.parent) {
        return self.parent.sheet;
    }
    return nil;
}

- (id <IUProjectProtocol>)project{
    if (self.sheet.group.project) {
        return self.sheet.group.project;
    }
    else if (_tempProject) {
        //not assigned to document
        return _tempProject;
    }
    //FIXME: decoder할때 project가 없을때가 있음 확인요
    return nil;
}

-(NSString*)description{
    return [[super description] stringByAppendingFormat:@" %@", self.htmlID];
}

- (void)setTempProject:(IUProject*)project{
    _tempProject = project;
}

- (void)setCss:(IUCSS *)css{
    _css = css;
}

#pragma mark - MQData
- (void)setMqData:(IUMQData *)mqData{
    _mqData = mqData;
}


#pragma mark - Event

- (void)setEvent:(IUEvent *)event{
    _event = event;
}

- (void)setOpacityMove:(float)opacityMove{
    if(_opacityMove != opacityMove){
        [[self.undoManager prepareWithInvocationTarget:self] setOpacityMove:_opacityMove];
        _opacityMove = opacityMove;
    }
}

- (void)setXPosMove:(float)xPosMove{
    if(_xPosMove != xPosMove){
        [[self.undoManager prepareWithInvocationTarget:self] setXPosMove:_xPosMove];
        _xPosMove = xPosMove;
        
        if(xPosMove !=0 && _enableHCenter==YES){
            self.enableHCenter = NO;
        }
    }
}

#pragma mark - setXXX : can Undo

- (void)setName:(NSString *)name{
    
    //ignore same name
    if([_name isEqualToString:name]){
        return;
    }
    //loading - not called rename notification
    if (_name == nil) {
        _name = [name copy];
    }
    //rename precedure
    else {
        _name = [name copy];
        if (self.isConnectedWithEditor) {
            [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationStructureDidChange object:self.project userInfo:
             @{IUNotificationStructureChangeType: IUNotificationStructureChangeTypeRenaming,
               IUNotificationStructureChangedIU: self}];
        }
    }
}
-(void)setLink:(id)link{
    if([link isEqualTo:_link] == NO){
        [[self.undoManager prepareWithInvocationTarget:self] setLink:_link];
    }
    _link = link;
    [self updateCSS];
}

-(void)setDivLink:(id)divLink{
    if([divLink isEqualTo:_divLink]== NO){
        [[self.undoManager prepareWithInvocationTarget:self] setDivLink:_divLink];
    }
    _divLink = divLink;
}

- (void)setImageName:(NSString *)imageName{
 
    NSString *currentImage = _css.effectiveTagDictionary[IUCSSTagImage];
    if([currentImage isEqualToString:imageName] == NO){
        
        [[[self undoManager] prepareWithInvocationTarget:self] setImageName:_css.effectiveTagDictionary[IUCSSTagImage]];
        
        [self willChangeValueForKey:@"imageName"];
        [_css setValue:imageName forTag:IUCSSTagImage];
        [self didChangeValueForKey:@"imageName"];
    }
}
- (NSString *)imageName{
    return _css.effectiveTagDictionary[IUCSSTagImage];
}


//iucontroller & inspectorVC sync가 안맞는듯.
- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

- (void)confirmIdentifier{
    [self.project.identifierManager confirm];
}


#pragma mark - noti
- (CalledByNoti)structureChanged:(NSNotification*)noti{
    NSDictionary *userInfo = noti.userInfo;
    
    if ([userInfo[IUNotificationStructureChangeType] isEqualToString:IUNotificationStructureChangeRemoving]
        && [userInfo[IUNotificationStructureChangedIU] isKindOfClass:[IUPage class]]) {
        if([self.link isEqualTo:userInfo[IUNotificationStructureChangedIU]]){
            //disable undoManager;
            _link = nil;
            _divLink = nil;
            [self updateCSS];
        }
    }
}

- (void)addMQSize:(NSNotification *)notification{
    
    NSInteger size = [[notification.userInfo objectForKey:IUNotificationMQSize] integerValue];
    NSInteger oldMaxSize = [[notification.userInfo valueForKey:IUNotificationMQOldMaxSize] integerValue];
    NSInteger maxSize = [[notification.userInfo valueForKey:IUNotificationMQMaxSize] integerValue];
    
    if ([notification.userInfo valueForKey:IUNotificationMQLargerSize]) {
        NSInteger nextSize = [[notification.userInfo valueForKey:IUNotificationMQLargerSize] integerValue];
        if(nextSize != maxSize){
            //media query 바로 위에 size를 copy함
            // 760이 있을때  750 size 를 copy
            [_css copyCSSDictFrom:nextSize to:size];
        }
    }

    //max size가 변하면 max css를 현재 css로 카피시킴.
    //960을만들고 1280을 나중에 만들면
    //1280으로 그냥 다옮겨가면서 960css 가 망가지게 됨.
    //방지하기 위한 용도
    if(size == maxSize){
        [_css copyCSSMaxViewPortDictTo:oldMaxSize];
    }
    
    [_css setMaxViewPort:maxSize];
    [_mqData setMaxViewPort:maxSize];
    
}

- (void)removeMQSize:(NSNotification *)notification{
    NSInteger size = [[notification.userInfo objectForKey:IUNotificationMQSize] integerValue];
    NSInteger maxSize = [[notification.userInfo valueForKey:IUNotificationMQMaxSize] integerValue];
    [_css removeTagDictionaryForViewport:size];
    [_css setMaxViewPort:maxSize];
    [_mqData setMaxViewPort:maxSize];

}


- (void)changeMQSelect:(NSNotification *)notification{
    
    [self willChangeValueForKey:@"canChangeHCenter"];

    NSInteger selectedSize = [[notification.userInfo valueForKey:IUNotificationMQSize] integerValue];
    NSInteger maxSize = [[notification.userInfo valueForKey:IUNotificationMQMaxSize] integerValue];

    if (selectedSize == maxSize) {
        [_css setEditViewPort:IUCSSDefaultViewPort];
        [_mqData setEditViewPort:IUCSSDefaultViewPort];
    }
    else {
        [_css setEditViewPort:selectedSize];
        [_mqData setEditViewPort:selectedSize];
    }
    [_css setMaxViewPort:maxSize];
    [_mqData setMaxViewPort:maxSize];
    
    [self didChangeValueForKey:@"canChangeHCenter"];
        
    
}

//source
#pragma mark HTML


- (void)updateHTML{
    
    /*
    if (_canvasVC && [_canvasVC isUpdateHTMLEnabled]) {
        
        
        [_canvasVC disableUpdateJS:self];
        NSString *editorHTML = [self.project.compiler htmlCode:self target:IUTargetEditor].string;
        
        [_canvasVC IUHTMLIdentifier:self.htmlID HTML:editorHTML];
        
        if([self.sheet isKindOfClass:[IUClass class]]){
            for(IUBox *box in ((IUClass *)self.sheet).references){
                [box updateHTML];
            }
        }
        
        for(IUBox *box in self.allChildren){
            [box updateCSS];
        }
        
        [_canvasVC enableUpdateJS:self];
        [self updateCSS];
        
    }
     */
    
    if (self.sourceManager) {
        [self.sourceManager setNeedsUpdateHTML:self];
        if([self.sheet isKindOfClass:[IUClass class]]){
            for(IUBox *box in ((IUClass *)self.sheet).references){
                [self.sourceManager setNeedsUpdateHTML:box];
            }
        }
    }
    
    
}

#pragma mark - css

/**
 @brief use cssIdentifierArray when remove IU, All CSS Identifiers should be in it.
 
 */
- (NSArray *)cssIdentifierArray{
    NSMutableArray *array = [NSMutableArray arrayWithArray:@[[self cssIdentifier], [self cssHoverClass]]];
    
    if(_pgContentVariable){
        [array addObject:[[self cssIdentifier] stringByAppendingString:@">p"]];
    }
    
    return array;
}


- (void)updateCSSValuesBeforeUpdateEditor{
    if(_lineHeightAuto && self.shouldCompileFontInfo){
        if(_css.effectiveTagDictionary[IUCSSTagPixelHeight]){
            
            NSInteger brCount = [_canvasVC countOfLineWithIdentifier:self.htmlID];
            CGFloat height = [_css.effectiveTagDictionary[IUCSSTagPixelHeight] floatValue];
            CGFloat fontSize = [_css.effectiveTagDictionary[IUCSSTagFontSize] floatValue];
            CGFloat lineheight;
            
            if(height < 0.1 || height < fontSize || brCount <0.1 || fontSize <0.1){
                lineheight = 1.0;
            }
            else{
                lineheight = ((height/brCount)/fontSize);
            }
            
            if(brCount > 3 && lineheight > 50){
                lineheight = 50;
            }
            [_css setValueWithoutUpdateCSS:@(lineheight) forTag:IUCSSTagLineHeight];
        }
    }
}
/*FIXME: Structre Error!!!

//updateCSS는 delegate에 화면을 업데이트 하는 함수인데 함수가 다시 _css에 값을 세팅하고 있음.
//2014.09.30
updateCSS가 화면을 업데이트 하는 함수라기보다는 현재 css를 적용시킨다는 말이 맞는것같음???
아니면 구분을 지어야할듯.
 
updateCSS를 updateCanvasForCSS, updateCSSValues로 두개를 호출하게.
 
현재상황에서는 css가 변할때마다 변화해야 하는 값들을 넣어주어야함.
(media query를 support하기때문에 css값이지만 jquery+property에 의해서 정해지는 값)
e.g. 만약 css로 옮긴다면)
->css로 넘어가면 js를 호출할수가 없음(연결선을 빼야함->css.delegate->iu->iu.delegate)까지 연장해야함(가능)
->iu property를 delegate쪽으로 빼야함.(이것도 struture error)
 */
- (void)updateCSS{
    
    if(self.sourceManager){
        [self updateCSSValuesBeforeUpdateEditor];
        [self.sourceManager setNeedsUpdateCSS:self];
    }
    
    /*
    if (_canvasVC) {
        
        [self updateCSSValuesBeforeUpdateEditor];
        
        IUCSSCode *cssCode = [self.project.compiler cssCodeForIU:self];
        NSDictionary *dictionaryWithIdentifier = [cssCode stringTagDictionaryWithIdentifier:(int)_css.editViewPort];
        for (NSString *identifier in dictionaryWithIdentifier) {
            [_canvasVC IUClassIdentifier:identifier CSSUpdated:dictionaryWithIdentifier[identifier]];
        }
        
        
        //Review : sheet css로 들어가는 id 들은 없어지면, 지워줘야함.
        NSMutableArray *removedIdentifier = [NSMutableArray arrayWithArray:[self cssIdentifierArray]];
        [removedIdentifier removeObjectsInArray:[dictionaryWithIdentifier allKeys]];
        
        for(NSString *identifier in removedIdentifier){
            if([identifier containsString:@"hover"]){
                [_canvasVC removeCSSTextInDefaultSheetWithIdentifier:identifier];
            }
        }
        
        
        [_canvasVC updateJS];
        
    }
     */
}

- (void)updateCSSWithIdentifiers:(NSArray *)identifiers{
    if (_canvasVC) {
        IUCSSCode *cssCode = [self.project.compiler cssCodeForIU:self];
        NSDictionary *dictionaryWithIdentifier = [cssCode stringTagDictionaryWithIdentifier:(int)_css.editViewPort];
        
        for (NSString *identifier in identifiers) {
            [_canvasVC IUClassIdentifier:identifier CSSUpdated:dictionaryWithIdentifier[identifier]];
        }
    }
}



#pragma mark children

- (NSMutableArray *)allIdentifierChildren{
    if (self.children) {
        NSMutableArray *array = [NSMutableArray array];
        for (IUBox *iu in self.children) {
            [array addObject:iu];
            [array addObjectsFromArray:iu.allIdentifierChildren];
        }
        return array;
    }
    return nil;}


-(NSMutableArray*)allChildren{
    if (self.children) {
        NSMutableArray *array = [NSMutableArray array];
        for (IUBox *iu in self.children) {
            [array addObject:iu];
            [array addObjectsFromArray:iu.allChildren];
        }
        return array;
    }
    return nil;
}

-(NSArray*)children{
    return [_m_children copy];
}

#pragma mark should

-(BOOL)canAddIUByUserInput{
    if(self.pgContentVariable && self.pgContentVariable.length > 0){
        return NO;
    }
    if( [self.mqData dictionaryForTag:IUMQDataTagInnerHTML].count > 0){
        return NO;
    }
    return YES;
}

- (BOOL)canRemoveIUByUserInput{
    return YES;
}

-(BOOL)shouldCompileChildrenForOutput{
    return YES;
}

#pragma mark add
-(BOOL)addIU:(IUBox *)iu error:(NSError**)error{
    if (_m_children == nil) {
        _m_children = [NSMutableArray array];
    }
    NSInteger index = [_m_children count];
    return [self insertIU:iu atIndex:index error:error];
}

-(BOOL)isConnectedWithEditor{
    return _isConnectedWithEditor;
}

-(void)setIsConnectedWithEditor{
    _isConnectedWithEditor = YES;
    for (IUBox *iu in self.children) {
        [iu setIsConnectedWithEditor];
    }
}

-(BOOL)insertIU:(IUBox *)iu atIndex:(NSInteger)index  error:(NSError**)error{
    if ([iu isKindOfClass:[IUImport class]] && [[self sheet] isKindOfClass:[IUImport class]]) {
        [JDUIUtil hudAlert:@"IUImport can't be inserted to IUImport" second:2];
        return NO;
    }
    if (_m_children == nil) {
        _m_children = [NSMutableArray array];
    }

    [[self.undoManager prepareWithInvocationTarget:self] removeIU:iu];
    
    [_m_children insertObject:iu atIndex:index];
    
    //iu 의 delegate와 children
    [iu setCanvasVC:_canvasVC];

    iu.parent = self;
    if (self.isConnectedWithEditor) {
        [iu connectWithEditor];
        [iu setIsConnectedWithEditor];
    }
    
    if ([self.sheet isKindOfClass:[IUClass class]]) {
        for (IUBox *import in [(IUClass*)self.sheet references]) {
            [import updateHTML];
        }
    }
    

    [self updateHTML];
    [iu bind:@"identifierManager" toObject:self withKeyPath:@"identifierManager" options:nil];

    if (self.isConnectedWithEditor) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationStructureDidChange object:self.project userInfo:@{IUNotificationStructureChangeType: IUNotificationStructureAdding, IUNotificationStructureChangedIU: iu}];
    }

    return YES;
}

-(BOOL)addIUReference:(IUBox *)iu error:(NSError**)error{
    [_m_children addObject:iu];
    if (_canvasVC) {
        [iu setCanvasVC:_canvasVC];
    }
    return YES;
}


-(BOOL)removeIU:(IUBox *)iu{
        NSInteger index = [_m_children indexOfObject:iu];
        [[self.undoManager prepareWithInvocationTarget:self] insertIU:iu atIndex:index error:nil];
        
        //IURemoved 호출한 다음에 m_children을 호출해야함.
        //border를 지울려면 controller 에 iu 정보 필요.
        //--undo [self.project.identifierManager unregisterIUs:@[iu]];
        [_canvasVC IURemoved:iu.htmlID];
        [_m_children removeObject:iu];
        
        if (self.isConnectedWithEditor) {
            [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationStructureDidChange object:self.project userInfo:@{IUNotificationStructureChangeType: IUNotificationStructureChangeRemoving, IUNotificationStructureChangedIU: iu}];
        }
    
    [iu disconnectWithEditor];
    [self updateHTML];
    return YES;
}

-(BOOL)removeAllIU{
    NSArray *children = self.children;
    for (IUBox *iu in children) {
        NSInteger index = [_m_children indexOfObject:iu];
        [[self.undoManager prepareWithInvocationTarget:self] insertIU:iu atIndex:index error:nil];
        
        //IURemoved 호출한 다음에 m_children을 호출해야함.
        //border를 지울려면 controller 에 iu 정보 필요.
        //--undo [self.project.identifierManager unregisterIUs:@[iu]];
        [_canvasVC IURemoved:iu.htmlID];
        [_m_children removeObject:iu];
    }
    
    if (self.isConnectedWithEditor) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationStructureDidChange object:self.project userInfo:@{IUNotificationStructureChangeType: IUNotificationStructureChangeRemoving, IUNotificationStructureChangedIU: children}];
    }
    
    return YES;
}

-(BOOL)changeIUIndex:(IUBox*)iu to:(NSUInteger)index error:(NSError**)error{
    NSInteger currentIndex = [_m_children indexOfObject:iu];

    [[self.undoManager prepareWithInvocationTarget:self] changeIUIndex:iu to:currentIndex error:nil];
    
    //자기보다 앞으로 갈 경우
    [_m_children removeObject:iu];
    if (index > currentIndex) {
        index --;
    }
    [_m_children insertObject:iu atIndex:index];
    
    [self updateHTML];
    if (self.isConnectedWithEditor) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationStructureDidChange object:self.project userInfo:@{IUNotificationStructureChangeType: IUNotificationStructureChangeReindexing, IUNotificationStructureChangedIU: iu}];
    }
    
    return YES;
}

-(BOOL)removeIUAtIndex:(NSUInteger)index{
    
    IUBox *box = [_m_children objectAtIndex:index];
    return [self removeIU:box];
}

#pragma mark - text
- (void)setPgContentVariable:(NSString *)pgContentVariable{
    if([pgContentVariable isEqualToString:_pgContentVariable]){
        return;
    }
    
    [self willChangeValueForKey:@"shouldCompileFontInfo"];
    
    [[[self undoManager] prepareWithInvocationTarget:self] setPgContentVariable:_pgContentVariable];
    
    BOOL needUpdate = NO;
    
    if(_pgContentVariable == nil && pgContentVariable && pgContentVariable.length > 0){
        _text = [self.mqData valueForTag:IUMQDataTagInnerHTML forViewport:IUCSSDefaultViewPort];
        [self.mqData eradicateTag:IUMQDataTagInnerHTML];
    }
    else if((pgContentVariable == nil || pgContentVariable.length==0) && _pgContentVariable && _pgContentVariable.length > 0){
        [self.mqData setValue:_text forTag:IUMQDataTagInnerHTML forViewport:IUCSSDefaultViewPort];
        _text = nil;
    }
    
    _pgContentVariable = pgContentVariable;
    
    if(needUpdate){
        [self updateHTML];
    }
    
    [self didChangeValueForKey:@"shouldCompileFontInfo"];
}

- (void)setPgVisibleConditionVariable:(NSString *)pgVisibleConditionVariable{
    if([pgVisibleConditionVariable isEqualToString:_pgVisibleConditionVariable]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setPgVisibleConditionVariable:_pgVisibleConditionVariable];
    
    _pgVisibleConditionVariable = pgVisibleConditionVariable;
}

- (BOOL)shouldCompileFontInfo{
    IUTextInputType inputType = [self textInputType];
    
    switch (inputType) {
        case IUTextInputTypeNone:
            return NO;
        case IUTextInputTypeAddible:
        case IUTextInputTypeTextField:
            return YES;
        case IUTextInputTypeEditable:
            if( [self.mqData dictionaryForTag:IUMQDataTagInnerHTML].count > 0){
                return YES;
            }
            else{
                return NO;
            }
    }
    
    return NO;

}

- (IUTextInputType)textInputType{
    
    if(self.children.count > 0){
        return IUTextInputTypeNone;
    }
    
    if([self isMemberOfClass:[IUBox class]]){
        if(self.pgContentVariable && self.pgContentVariable.length > 0){
            return IUTextInputTypeAddible;
        }
        else{
            return IUTextInputTypeEditable;
        }
    }
    
    return IUTextInputTypeNone;
}

#pragma mark - Frame
- (BOOL)shouldCompileImagePositionInfo{
    return YES;
}


-(BOOL)shouldCompileX{
    return YES;
}

-(BOOL)shouldCompileY{
    if (self.positionType == IUPositionTypeAbsoluteBottom) {
        return NO;
    }
    return YES;
}
-(BOOL)shouldCompileWidth{
    return YES;
}
-(BOOL)shouldCompileHeight{
    return YES;
}
- (BOOL)centerChangeable{
    return YES;
}

- (BOOL)canChangeXByUserInput{
    if(self.enableHCenter){
        return NO;
    }
    return YES;
}
- (BOOL)canChangeYByUserInput{
    if(self.enableVCenter){
        return NO;
    }
    return YES;
}
- (BOOL)canChangeWidthByUserInput{
    return YES;
}
- (BOOL)canChangeHeightByUserInput{
    return YES;
}
- (BOOL)canChangeWidthUnitByUserInput{
    return YES;
}

#pragma mark setFrame

- (void)setX:(float)x{
    [_css setValueWithoutUpdateCSS:@(x) forTag:IUCSSTagPixelX];
}

- (void)setY:(float)y{
    [_css setValueWithoutUpdateCSS:@(y) forTag:IUCSSTagPixelY];
}

- (void)setPercentFrame:(NSRect)frame{
    CGFloat x = frame.origin.x;
    CGFloat xExist =[_css.effectiveTagDictionary[IUCSSTagPercentX] floatValue];
    if (x != xExist) {
        [_css setValueWithoutUpdateCSS:@(frame.origin.x) forTag:IUCSSTagPercentX];
    }
    if (frame.origin.x != [_css.effectiveTagDictionary[IUCSSTagPercentY] floatValue]) {
        [_css setValueWithoutUpdateCSS:@(frame.origin.y) forTag:IUCSSTagPercentY];
    }
    if (frame.origin.x != [_css.effectiveTagDictionary[IUCSSTagPercentHeight] floatValue]) {
        [_css setValueWithoutUpdateCSS:@(frame.size.height) forTag:IUCSSTagPercentHeight];
    }
    if (frame.origin.x != [_css.effectiveTagDictionary[IUCSSTagPercentWidth] floatValue]) {
        [_css setValueWithoutUpdateCSS:@(frame.size.width) forTag:IUCSSTagPercentWidth];
    }
}

- (void)setPixelFrame:(NSRect)frame{
    [_css setValueWithoutUpdateCSS:@(frame.origin.x) forTag:IUCSSTagPixelX];
    [_css setValueWithoutUpdateCSS:@(frame.origin.y) forTag:IUCSSTagPixelY];
    [_css setValueWithoutUpdateCSS:@(frame.size.height) forTag:IUCSSTagPixelHeight];
    [_css setValueWithoutUpdateCSS:@(frame.size.width) forTag:IUCSSTagPixelWidth];
}


#pragma mark move by drag & drop




/*
 drag 중간의 diff size로 하면 css에 의한 오차가 생김.
 drag session이 시작될때부터 위치에서의 diff size로 계산해야 오차가 발생 안함.
 drag session이 시작할때 그 때의 위치를 저장함.
 */

- (NSPoint)currentPosition{
    NSInteger currentX = [_css.effectiveTagDictionary[IUCSSTagPixelX] integerValue];
    NSInteger currentY = 0;
    if([_css.effectiveTagDictionary objectForKey:IUCSSTagPixelY]){
        currentY = [_css.effectiveTagDictionary[IUCSSTagPixelY] integerValue];
    }
    else if(self.positionType == IUPositionTypeRelative || self.positionType == IUPositionTypeFloatRight ||
            self.positionType == IUPositionTypeFloatLeft){
        
        NSRect currentFrame = [_canvasVC absoluteIUFrame:self.htmlID];
        NSRect parentframe = [_canvasVC absoluteIUFrame:self.parent.htmlID];
        currentY = parentframe.origin.y - currentFrame.origin.y;
        
    }
    return NSMakePoint(currentX, currentY);
}
- (NSPoint)currentPercentPosition{
    NSInteger currentX = 0;
    NSInteger currentY = 0;
    if([_css.effectiveTagDictionary objectForKey:IUCSSTagPercentX]){
        currentX = [_css.effectiveTagDictionary[IUCSSTagPercentX] integerValue];
    }
    if([_css.effectiveTagDictionary objectForKey:IUCSSTagPercentY]){
        currentY = [_css.effectiveTagDictionary[IUCSSTagPercentY] integerValue];
    }
    return NSMakePoint(currentX, currentY);
}
- (NSSize)currentSize{
    NSInteger currentWidth = [_css.effectiveTagDictionary[IUCSSTagPixelWidth] integerValue];
    NSInteger currentHeight = [_css.effectiveTagDictionary[IUCSSTagPixelHeight] integerValue];
    
    return NSMakeSize(currentWidth, currentHeight);
}

- (NSSize)currentPercentSize{
    NSInteger currentPWidth = [_css.effectiveTagDictionary[IUCSSTagPercentWidth] floatValue];
    NSInteger currentPHeight = [_css.effectiveTagDictionary[IUCSSTagPercentHeight] floatValue];
    
    return NSMakeSize(currentPWidth, currentPHeight);
}
- (void)startFrameMoveWithUndoManager{
    
    _isEnabledFrameUndo = YES;
    
    undoFrameDict = [NSMutableDictionary dictionary];
    
    if(_css.effectiveTagDictionary[IUCSSTagPixelX]){
        undoFrameDict[IUCSSTagPixelX] = _css.effectiveTagDictionary[IUCSSTagPixelX];
    }
    if(_css.effectiveTagDictionary[IUCSSTagPixelY]){
        undoFrameDict[IUCSSTagPixelY] = _css.effectiveTagDictionary[IUCSSTagPixelY];
    }
    if(_css.effectiveTagDictionary[IUCSSTagPixelWidth]){
        undoFrameDict[IUCSSTagPixelWidth] = _css.effectiveTagDictionary[IUCSSTagPixelWidth];
    }
    if(_css.effectiveTagDictionary[IUCSSTagPixelHeight]){
        undoFrameDict[IUCSSTagPixelHeight] = _css.effectiveTagDictionary[IUCSSTagPixelHeight];
    }

    
    if(_css.effectiveTagDictionary[IUCSSTagPercentX]){
        undoFrameDict[IUCSSTagPercentX] = _css.effectiveTagDictionary[IUCSSTagPercentX];
    }
    if(_css.effectiveTagDictionary[IUCSSTagPercentY]){
        undoFrameDict[IUCSSTagPercentY] = _css.effectiveTagDictionary[IUCSSTagPercentY];
    }
    if(_css.effectiveTagDictionary[IUCSSTagPercentWidth]){
        undoFrameDict[IUCSSTagPercentWidth] = _css.effectiveTagDictionary[IUCSSTagPercentWidth];
    }
    if(_css.effectiveTagDictionary[IUCSSTagPercentHeight]){
        undoFrameDict[IUCSSTagPercentHeight] = _css.effectiveTagDictionary[IUCSSTagPercentHeight];
    }

    originalSize = [self currentSize];
    originalPercentSize = [self currentPercentSize];
    originalPoint = [self currentPosition];
    originalPercentPoint = [self currentPercentPosition];
    
}

- (void)endFrameMoveWithUndoManager{
    _isEnabledFrameUndo = NO;
    
    [[self undoManager] beginUndoGrouping];
    [[self.undoManager prepareWithInvocationTarget:self] undoFrameWithDictionary:undoFrameDict];
    [[self undoManager] endUndoGrouping];    
}

- (BOOL)isEnabledFrameUndo{
    return _isEnabledFrameUndo;
}

- (void)undoFrameWithDictionary:(NSMutableDictionary *)dictionary{
    
    _isEnabledFrameUndo = YES;
    NSMutableDictionary *currentFrameDict = [NSMutableDictionary dictionary];
    
    if(_css.effectiveTagDictionary[IUCSSTagPixelX]){
        currentFrameDict[IUCSSTagPixelX] = _css.effectiveTagDictionary[IUCSSTagPixelX];
    }
    if(_css.effectiveTagDictionary[IUCSSTagPixelY]){
        currentFrameDict[IUCSSTagPixelY] = _css.effectiveTagDictionary[IUCSSTagPixelY];
    }
    if(_css.effectiveTagDictionary[IUCSSTagPixelWidth]){
        currentFrameDict[IUCSSTagPixelWidth] = _css.effectiveTagDictionary[IUCSSTagPixelWidth];
    }
    if(_css.effectiveTagDictionary[IUCSSTagPixelHeight]){
        currentFrameDict[IUCSSTagPixelHeight] = _css.effectiveTagDictionary[IUCSSTagPixelHeight];
    }
    
    
    if(_css.effectiveTagDictionary[IUCSSTagPercentX]){
        currentFrameDict[IUCSSTagPercentX] = _css.effectiveTagDictionary[IUCSSTagPercentX];
    }
    if(_css.effectiveTagDictionary[IUCSSTagPercentY]){
        currentFrameDict[IUCSSTagPercentY] = _css.effectiveTagDictionary[IUCSSTagPercentY];
    }
    if(_css.effectiveTagDictionary[IUCSSTagPercentWidth]){
        currentFrameDict[IUCSSTagPercentWidth] = _css.effectiveTagDictionary[IUCSSTagPercentWidth];
    }
    if(_css.effectiveTagDictionary[IUCSSTagPercentHeight]){
        currentFrameDict[IUCSSTagPercentHeight] = _css.effectiveTagDictionary[IUCSSTagPercentHeight];
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] undoFrameWithDictionary:currentFrameDict];
    
    [_css setValueWithoutUpdateCSS:dictionary[IUCSSTagPixelX] forTag:IUCSSTagPixelX];
    [_css setValueWithoutUpdateCSS:dictionary[IUCSSTagPixelY] forTag:IUCSSTagPixelY];
    [_css setValueWithoutUpdateCSS:dictionary[IUCSSTagPixelWidth] forTag:IUCSSTagPixelWidth];
    [_css setValueWithoutUpdateCSS:dictionary[IUCSSTagPixelHeight] forTag:IUCSSTagPixelHeight];

    [_css setValueWithoutUpdateCSS:dictionary[IUCSSTagPixelX] forTag:IUCSSTagPixelX];
    [_css setValueWithoutUpdateCSS:dictionary[IUCSSTagPixelY] forTag:IUCSSTagPixelY];
    [_css setValueWithoutUpdateCSS:dictionary[IUCSSTagPercentWidth] forTag:IUCSSTagPercentWidth];
    [_css setValueWithoutUpdateCSS:dictionary[IUCSSTagPercentHeight] forTag:IUCSSTagPercentHeight];

    
    [self updateCSS];
    
    _isEnabledFrameUndo = NO;
}

- (NSPoint)originalPoint{
    return originalPoint;
}
- (NSSize)originalSize{
    return originalSize;
}

- (BOOL)canChangeWidthByDraggable{
    
    if([self canChangeWidthByUserInput]){
        //userinput을 통해 바꿀 수 있어도 tag가 nil일 경우에는 drag를 통해서 넣지 않는다.
        id pixelValue = [_css effectiveValueForTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        id percentValue = [_css effectiveValueForTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
        if(pixelValue == nil && percentValue == nil){
            return NO;
        }
        else{
            return YES;
        }
    }
    return NO;
   
}
- (BOOL)canChangeHeightByDraggable{
    
    if([self canChangeHeightByUserInput]){
        //userinput을 통해 바꿀 수 있어도 tag가 nil일 경우에는 drag를 통해서 넣지 않는다.
        id pixelValue = [_css effectiveValueForTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        id percentValue = [_css effectiveValueForTag:IUCSSTagPercentHeight forViewport:IUCSSDefaultViewPort];
        if(pixelValue == nil && percentValue == nil){
            return NO;
        }
        else{
            return YES;
        }
    }
    return NO;
    
}

- (void)setPixelX:(CGFloat)pixelX percentX:(CGFloat)percentX{
    [_css setValueWithoutUpdateCSS:@(pixelX) forTag:IUCSSTagPixelX];
    [_css setValueWithoutUpdateCSS:@(percentX) forTag:IUCSSTagPercentX];
}
- (void)setPixelY:(CGFloat)pixelY percentY:(CGFloat)percentY{
    [_css setValueWithoutUpdateCSS:@(pixelY) forTag:IUCSSTagPixelY];
    [_css setValueWithoutUpdateCSS:@(percentY) forTag:IUCSSTagPercentY];
}
- (void)setPixelWidth:(CGFloat)pixelWidth percentWidth:(CGFloat)percentWidth{
    [_css setValueWithoutUpdateCSS:@(pixelWidth) forTag:IUCSSTagPixelWidth];
    [_css setValueWithoutUpdateCSS:@(percentWidth) forTag:IUCSSTagPercentWidth];
}
- (void)setPixelHeight:(CGFloat)pixelHeight percentHeight:(CGFloat)percentHeight{
    [_css setValueWithoutUpdateCSS:@(pixelHeight) forTag:IUCSSTagPixelHeight];
    [_css setValueWithoutUpdateCSS:@(percentHeight) forTag:IUCSSTagPercentHeight];
}

#pragma mark - position
- (BOOL)canChangePositionType{
    return YES;
}

- (BOOL)canChangePositionAbsolute{
    return YES;
}

- (BOOL)canChangePositionRelative{
    return YES;
}

- (BOOL)canChangePositionFloatLeft{
    return YES;
}

- (BOOL)canChangePositionFloatRight{
    return YES;
}

- (BOOL)canChangePositionAbsoluteBottom{
    return YES;
}
- (BOOL)canChangePositionFixed{
    return YES;
}
- (BOOL)canChangePositionFixedBottom{
    return YES;
}

- (BOOL)canChangeHCenter{
    if(_positionType == IUPositionTypeFloatLeft || _positionType == IUPositionTypeFloatRight
       || _css.editViewPort != IUCSSDefaultViewPort){
        return NO;
    }
    return YES;
}

- (BOOL)canChangeVCenter{
    if(_positionType == IUPositionTypeAbsolute ||
       _positionType == IUPositionTypeFixed){
        return YES;
    }
    return NO;
}



- (BOOL)canChangeOverflow{
    return YES;
}


- (void)setPositionType:(IUPositionType)positionType{
    
    if(_positionType == positionType){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setPositionType:_positionType];
    
    if (_positionType == IUPositionTypeFloatRight || positionType == IUPositionTypeFloatRight){
        [self.css setValue:@(0) forTag:IUCSSTagPixelX];
        [self.css setValue:@(0) forTag:IUCSSTagPercentX];
    }
    
    BOOL disableCenterFlag = NO;
    if (positionType == IUPositionTypeFloatLeft || positionType == IUPositionTypeFloatRight
        || _positionType == IUPositionTypeFloatLeft || _positionType == IUPositionTypeFloatRight) {
        if(positionType == IUPositionTypeFloatLeft || positionType == IUPositionTypeFloatRight){
            self.enableHCenter = NO;
        }
        disableCenterFlag = YES;
        [self willChangeValueForKey:@"canChangeHCenter"];

    }
    
    BOOL disableVCenterFlag = NO;
    if(positionType == IUPositionTypeFloatLeft || positionType == IUPositionTypeFloatRight
       || positionType == IUPositionTypeRelative
       || positionType == IUPositionTypeAbsoluteBottom
       || positionType == IUPositionTypeFixedBottom
       || _positionType == IUPositionTypeFloatLeft
       || _positionType == IUPositionTypeFloatRight
       || _positionType == IUPositionTypeRelative
       || _positionType == IUPositionTypeAbsoluteBottom
       || _positionType == IUPositionTypeFixedBottom){
        
        if( _positionType == IUPositionTypeFloatLeft
           || _positionType == IUPositionTypeFloatRight
           || _positionType == IUPositionTypeRelative
           || _positionType == IUPositionTypeAbsoluteBottom
           || _positionType == IUPositionTypeFixedBottom){
            self.enableVCenter = NO;
        }
        
        [self willChangeValueForKey:@"canChangeVCenter"];
        disableVCenterFlag= YES;
        
    }
    
    
    BOOL absoluteBottomFlag = _positionType == IUPositionTypeAbsoluteBottom || positionType == IUPositionTypeAbsoluteBottom;
    if (absoluteBottomFlag) {
        [self.css setValue:@(0) forTag:IUCSSTagPixelY];
        [self.css setValue:@(0) forTag:IUCSSTagPercentY];
        [self.css setValue:@(NO) forTag:IUCSSTagYUnitIsPercent];
        [self willChangeValueForKey:@"shouldCompileY"];
    }
    _positionType = positionType;
    if (absoluteBottomFlag) {
        [self didChangeValueForKey:@"shouldCompileY"];
    }
    if (disableCenterFlag){
        [self didChangeValueForKey:@"canChangeHCenter"];

    }
    if (disableVCenterFlag){
        [self didChangeValueForKey:@"canChangeVCenter"];
    }
    
    
    if(_positionType == IUPositionTypeRelative ||
       _positionType == IUPositionTypeFloatLeft ||
       _positionType == IUPositionTypeFloatRight){
        //html order
        [self.parent updateHTML];
    }
    else{
        [self updateCSS];
    }

}
- (void)setEnableHCenter:(BOOL)enableHCenter{

    if(_enableHCenter != enableHCenter){
        [self willChangeValueForKey:@"canChangeXByUserInput"];
        [[self.undoManager prepareWithInvocationTarget:self] setEnableHCenter:_enableHCenter];
        _enableHCenter = enableHCenter;
        [self updateHTML];
        [self didChangeValueForKey:@"canChangeXByUserInput"];
    }
}


- (void)setEnableVCenter:(BOOL)enableVCenter{
    
    if(_enableVCenter != enableVCenter){
        [self willChangeValueForKey:@"canChangeYByUserInput"];
        [[self.undoManager prepareWithInvocationTarget:self] setEnableVCenter:_enableVCenter];
        _enableVCenter = enableVCenter;
        [self updateHTML];
        [self didChangeValueForKey:@"canChangeYByUserInput"];
    }
}



- (void)setOverflowType:(IUOverflowType)overflowType{
    _overflowType = overflowType;
    [self updateHTML];
}

#pragma mark -text

- (void)setText:(NSString *)text{
    if([_text isEqualToString:text]){
        return;
    }
    BOOL isNeedUpdated = NO;
    if(_text == nil || text == nil){
        [self willChangeValueForKey:@"shouldCompileFontInfo"];
        isNeedUpdated = YES;
    }
    _text = text;
    
    if(_text.length > 300){
        [self setLineHeightAuto:NO];
    }
    
    if(isNeedUpdated){
        [self didChangeValueForKey:@"shouldCompileFontInfo"];
    }

}

- (void)setLineHeightAuto:(BOOL)lineHeightAuto{
    if( _text && _text.length > 300){
        lineHeightAuto = false;
    }
    if(lineHeightAuto != _lineHeightAuto){
        [[self.undoManager prepareWithInvocationTarget:self] setLineHeightAuto:_lineHeightAuto];
        _lineHeightAuto = lineHeightAuto;
        [self updateCSS];
    }
}

- (NSString*)cssIdentifier{
    return [@"." stringByAppendingString:self.htmlID];
}
- (NSString*)cssHoverClass{
    return [NSString stringWithFormat:@"%@:hover", self.cssIdentifier];
}
- (NSString*)cssActiveClass{
    return [NSString stringWithFormat:@"%@.active", self.cssIdentifier];
}

- (NSString*)cssClassStringForHTML{
    NSArray *classPedigree = [[self class] classPedigreeTo:[IUBox class]];
    NSMutableString *className = [NSMutableString string];
    for (NSString *str in classPedigree) {
        [className appendString:str];
        [className appendString:@" "];
    }
    [className appendFormat:@" %@", self.htmlID];
    return className;
}

- (BOOL)canMoveToOtherParent{
    return YES;
}

#pragma mark - javascript

- (NSRect)currentPercentFrame{
    NSString *frameJS = [NSString stringWithFormat:@"$('#%@').iuPercentFrame()", self.htmlID];
    id currentValue = [self.sourceManager evaluateWebScript:frameJS];
    NSRect percentFrame = NSMakeRect([[currentValue valueForKey:@"left"] floatValue],
                                     [[currentValue valueForKey:@"top"] floatValue],
                                     [[currentValue valueForKey:@"width"] floatValue],
                                     [[currentValue valueForKey:@"height"] floatValue]
                                     );
    
    
    return percentFrame;
}

- (NSRect)currentPixelFrame{
    
    NSString *frameJS = [NSString stringWithFormat:@"$('#%@').iuPosition()", self.htmlID];
    id currentValue = [self.sourceManager evaluateWebScript:frameJS];
    NSRect pixelFrame = NSMakeRect([[currentValue valueForKey:@"left"] floatValue],
                                     [[currentValue valueForKey:@"top"] floatValue],
                                     [[currentValue valueForKey:@"width"] floatValue],
                                     [[currentValue valueForKey:@"height"] floatValue]
                                     );
    
    
    return pixelFrame;
    
}

@end
