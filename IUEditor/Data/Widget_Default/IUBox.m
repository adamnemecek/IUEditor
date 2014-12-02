//
//  IUBox.m
//  IUEditor
//
//  Created by JD on 3/18/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUIdentifierManager.h"
#import "IUSourceManager.h"

#import "IUBox.h"
#import "NSString+JDExtension.h"
#import "NSObject+JDExtension.h"
#import "NSCoder+JDExtension.h"
#import "NSDictionary+JDExtension.h"
#import "NSArray+JDExtension.h"

#import "JDUIUtil.h"

#import "IUCSSCompiler.h"

#import "IUCompiler.h"

#import "IUSheet.h"
#import "IUBox.h"
#import "IUClass.h"
#import "IUProject.h"
#import "IUItem.h"
#import "IUImport.h"
#import "IUPage.h"
#import "IUText.h"

#import "IUStyleStorage.h"

@interface IUBox()
@end

@implementation IUBox{
    NSMutableSet *changedCSSWidths;
    
    //for storage manager tuple dictionary
    NSMutableDictionary *storageManagersDict;
    
    NSRect origianlFrame;
    
    __weak IUProject *_tempProject;
    BOOL    _isConnectedWithEditor;
    
    NSMutableArray *_events;
    NSMutableArray *_eventsCalledByOtherIU;
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

-(id)initWithJDCoder:(JDCoder *)aDecoder{
    
    _htmlID = [aDecoder decodeObjectForKey:@"htmlID"];
    _name = [aDecoder decodeObjectForKey:@"name"];
    _m_children = [aDecoder decodeObjectForKey:@"children"];
    
    _linkTarget = [aDecoder decodeBoolForKey:@"linkTarget"];
    
    //storage manager
    IUDataStorageManager *positionManager = [aDecoder decodeObjectForKey:@"positionManager"];
    IUDataStorageManager *styleManager = [aDecoder decodeObjectForKey:@"styleManager"];
    IUDataStorageManager *propertyManager = [aDecoder decodeObjectForKey:@"propertyManager"];
    IUDataStorageManager *hoverManager = [aDecoder decodeObjectForKey:@"hoverStyleManager"];
    
    storageManagersDict = [NSMutableDictionary dictionary];
    
    [self setStorageManager:positionManager forSelector:kIUPositionManager];
    [self setStorageManager:styleManager forSelector:kIUStyleManager];
    [self setStorageManager:propertyManager forSelector:kIUPropertyManager];
    [self setStorageManager:hoverManager forSelector:kIUStyleHoverManager];
    
    
    //binding
    if (self.defaultStyleManager) {
        [self bind:@"liveStyleStorage" toObject:self.defaultStyleManager withKeyPath:@"liveStorage" options:nil];
        [self bind:@"currentStyleStorage" toObject:self.defaultStyleManager withKeyPath:@"currentStorage" options:nil];
        [self bind:@"defaultStyleStorage" toObject:self.defaultStyleManager withKeyPath:@"defaultStorage" options:nil];
    }
    
    if(self.positionManager){
        [self bind:@"currentPositionStorage" toObject:self.positionManager withKeyPath:@"currentStorage" options:nil];
        [self bind:@"livePositionStorage" toObject:self.positionManager withKeyPath:@"liveStorage" options:nil];
        [self bind:@"defaultPositionStorage" toObject:self.positionManager withKeyPath:@"defaultStorage" options:nil];
        
    }
    
    if(self.propertyManager){
        [self bind:@"currentPropertyStorage" toObject:self.propertyManager withKeyPath:@"currentStorage" options:nil];
        [self bind:@"livePropertyStorage" toObject:self.propertyManager withKeyPath:@"liveStorage" options:nil];
        [self bind:@"defaultPropertyStorage" toObject:self.propertyManager withKeyPath:@"defaultStorage" options:nil];
    }
    
    return self;
}

- (void)awakeAfterUsingJDCoder:(JDCoder *)aDecoder{
    [self.undoManager disableUndoRegistration];
    
    _parent = [aDecoder decodeByRefObjectForKey:@"parent"];
    
    _link = [aDecoder decodeObjectForKey:@"link"];
    _divLink = [aDecoder decodeByRefObjectForKey:@"divLink"];
    

    [self.undoManager enableUndoRegistration];
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    
    [aCoder encodeObject:self.htmlID forKey:@"htmlID"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.children forKey:@"children"];
    
    [aCoder encodeByRefObject:self.parent forKey:@"parent"];
    
    [aCoder encodeBool:self.linkTarget forKey:@"linkTarget"];
    [aCoder encodeObject:self.link forKey:@"link"];
    [aCoder encodeByRefObject:self.divLink forKey:@"divLink"];
    
    
    [aCoder encodeObject:self.positionManager forKey:@"positionManager"];
    [aCoder encodeObject:self.defaultStyleManager forKey:@"styleManager"];
    [aCoder encodeObject:self.propertyManager forKey:@"propertyManager"];
    [aCoder encodeObject:self.hoverStyleManager forKey:@"hoverStyleManager"];
}

-(id <IUProjectProtocol>)project{
    return self.sheet.project;
}

-(id)initWithPreset {
    self = [super init];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        [self setDefaultProperties];
        [self createDefaultStorages];

        //setting for css
        self.defaultStyleStorage.bgColor = [NSColor randomLightMonoColor];

        [self.undoManager enableUndoRegistration];
    }
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        [self.undoManager disableUndoRegistration];

        [self setDefaultProperties];
        [self createDefaultStorages];
        
        
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)setDefaultProperties{
    _htmlID = [NSString stringWithFormat:@"%@%d",self.className, rand()];
    _name = _htmlID;
    
    _event = [[IUEvent alloc] init];
    _m_children = [NSMutableArray array];

    _events = [NSMutableArray array];
    _eventsCalledByOtherIU = [NSMutableArray array];
    
    changedCSSWidths = [NSMutableSet set];
}


- (void)createDefaultStorages{
    //create storage
    storageManagersDict = [NSMutableDictionary dictionary];
    
    IUDataStorageManager *styleManager = [[IUDataStorageManager alloc] initWithStorageClassName:[IUStyleStorage class].className];
    [self setStorageManager:styleManager forSelector:kIUStyleManager];
    if (self.defaultStyleManager) {
        [self bind:@"liveStyleStorage" toObject:self.defaultStyleManager withKeyPath:@"liveStorage" options:nil];
        [self bind:@"currentStyleStorage" toObject:self.defaultStyleManager withKeyPath:@"currentStorage" options:nil];
        [self bind:@"defaultStyleStorage" toObject:self.defaultStyleManager withKeyPath:@"defaultStorage" options:nil];
    }
    
    IUDataStorageManager *positionManager = [[IUDataStorageManager alloc] initWithStorageClassName:[IUPositionStorage class].className];
    [self setStorageManager:positionManager forSelector:kIUPositionManager];
    if(self.positionManager){
        [self bind:@"currentPositionStorage" toObject:self.positionManager withKeyPath:@"currentStorage" options:nil];
        [self bind:@"livePositionStorage" toObject:self.positionManager withKeyPath:@"liveStorage" options:nil];
        [self bind:@"defaultPositionStorage" toObject:self.positionManager withKeyPath:@"defaultStorage" options:nil];
        
    }
    
    IUDataStorageManager *hoverManager = [[IUDataStorageManager alloc] initWithStorageClassName:[IUStyleStorage class].className];
    [self setStorageManager:hoverManager forSelector:kIUStyleHoverManager];
    
    IUDataStorageManager *propertyManager = [[IUDataStorageManager alloc] initWithStorageClassName:[IUPropertyStorage class].className];
    [self setStorageManager:propertyManager forSelector:kIUPropertyManager];
    if(self.propertyManager){
        [self bind:@"currentPropertyStorage" toObject:self.propertyManager withKeyPath:@"currentStorage" options:nil];
        [self bind:@"livePropertyStorage" toObject:self.propertyManager withKeyPath:@"liveStorage" options:nil];
        [self bind:@"defaultPropertyStorage" toObject:self.propertyManager withKeyPath:@"defaultStorage" options:nil];
    }

    [self.defaultPositionStorage setPosition:@(IUPositionTypeAbsolute)];
    [self.defaultPositionStorage setX:nil unit:@(IUFrameUnitPixel)];
    [self.defaultPositionStorage setY:nil unit:@(IUFrameUnitPixel)];
    
    [self.defaultStyleStorage setWidth:nil unit:@(IUFrameUnitPixel)];
    [self.defaultStyleStorage setHeight:nil unit:@(IUFrameUnitPixel)];
    self.defaultStyleStorage.overflowType = @(IUOverflowTypeHidden);

    [(IUStyleStorage *)self.hoverStyleManager.defaultStorage setWidth:nil unit:@(IUFrameUnitPixel)];
    [(IUStyleStorage *)self.hoverStyleManager.defaultStorage setHeight:nil unit:@(IUFrameUnitPixel)];
}


- (void)connectWithEditor{
    /*
     FIXME: self.project
    NSAssert(self.project, @"");
     */
    
    
    [[self undoManager] disableUndoRegistration];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMQSelect:) name:IUNotificationMQSelected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMQSize:) name:IUNotificationMQAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeMQSize:) name:IUNotificationMQRemoved object:nil];
    /*
     FIXME
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(structureChanged:) name:IUNotificationStructureDidChange object:self.project];
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(structureChanged:) name:IUNotificationStructureDidChange object:nil];

    
    
    for (IUBox *box in self.children) {
        [box connectWithEditor];
    }
    
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

#pragma mark - copy

- (id)copyWithZone:(NSZone *)zone{
    

    IUBox *box = [[[self class] allocWithZone: zone] init];
    if(box){
        [[self undoManager] disableUndoRegistration];
        
        NSArray *children = [self.children deepCopy];
        for (IUBox *iu in children) {
            BOOL result = [box addIU:iu error:nil];
            NSAssert(result == YES, @"copy");
        }
        
        
        box.enableHCenter = _enableHCenter;
        box.enableVCenter = _enableVCenter;
        
        box.event = [_event copy];
        
        if([_link isKindOfClass:[IUBox class]]){
            box.link = _link;
        }
        else if([_link isKindOfClass:[NSString class]]){
            box.link = [_link copy];
        }

        
        box.divLink = _divLink;
        box.divLink = _linkCaller;
        
        //handle storage manager
        for(NSString *managerKey in [storageManagersDict allKeys]){
            IUDataStorageManager *copiedManager = [[storageManagersDict objectForKey:managerKey] copy];
            [box setStorageManager:copiedManager forSelector:managerKey];
        }
        //binding
        if (box.defaultStyleManager) {
            [box bind:@"liveStyleStorage" toObject:box.defaultStyleManager withKeyPath:@"liveStorage" options:nil];
            [box bind:@"currentStyleStorage" toObject:box.defaultStyleManager withKeyPath:@"currentStorage" options:nil];
            [box bind:@"defaultStyleStorage" toObject:box.defaultStyleManager withKeyPath:@"defaultStorage" options:nil];
        }
        if(box.positionManager){
            [box bind:@"currentPositionStorage" toObject:box.positionManager withKeyPath:@"currentStorage" options:nil];
            [box bind:@"livePositionStorage" toObject:box.positionManager withKeyPath:@"liveStorage" options:nil];
            [box bind:@"defaultPositionStorage" toObject:box.positionManager withKeyPath:@"defaultStorage" options:nil];
            
        }
        if(box.propertyManager){
            [box bind:@"currentPropertyStorage" toObject:box.propertyManager withKeyPath:@"currentStorage" options:nil];
            [box bind:@"livePropertyStorage" toObject:box.propertyManager withKeyPath:@"liveStorage" options:nil];
            [box bind:@"defaultPropertyStorage" toObject:box.propertyManager withKeyPath:@"defaultStorage" options:nil];
        }
        
        box.name = box.htmlID;
        
        [[self undoManager] enableUndoRegistration];
    }

    return box;
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
    return [storageManagersDict allKeys];
}


- (void)setStorageManager:(IUDataStorageManager *)cssManager forSelector:(NSString *)selector{
    
    if(storageManagersDict == nil){
        storageManagersDict = [NSMutableDictionary dictionary];
    }
    storageManagersDict[selector] = cssManager;
}

- (IUDataStorageManager *)dataManagerForSelector:(NSString *)selector{
    return storageManagersDict[selector];
}
- (IUDataStorageManager *)defaultStyleManager{
    return storageManagersDict[kIUStyleManager];
}
- (IUDataStorageManager *)hoverStyleManager{
    return storageManagersDict[kIUStyleHoverManager];
}
- (IUDataStorageManager *)positionManager{
    return storageManagersDict[kIUPositionManager];
}
- (IUDataStorageManager *)propertyManager{
    return storageManagersDict[kIUPropertyManager];
}




#pragma mark - Core Manager

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
        return [[[NSApp mainWindow] windowController] performSelector:@selector(sourceManager)];
    }
}

- (IUIdentifierManager *)identifierManager{
    if(_identifierManager){
        return _identifierManager;
    }
    else{
        return [[[[NSApp mainWindow] windowController] document] performSelector:@selector(identifierManager)];

    }
}

#else
- (id <IUSourceManagerProtocol>)sourceManager{
    return [[[NSApp mainWindow] windowController] performSelector:@selector(sourceManager)];
}
- (IUIdentifierManager *)identifierManager{
    return [[[[NSApp mainWindow] windowController] document] performSelector:@selector(identifierManager)];

}
#endif

#pragma mark - setXXX

-(IUSheet*)sheet{
    if ([self isKindOfClass:[IUSheet class]]) {
        return (IUSheet*)self;
    }
    if (self.parent) {
        return self.parent.sheet;
    }
    return nil;
}


-(NSString*)description{
    return [[super description] stringByAppendingFormat:@" %@", self.htmlID];
}

- (void)setTempProject:(IUProject*)project{
    _tempProject = project;
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
 
    NSString *currentImage = self.liveStyleStorage.imageName;
    if([currentImage isEqualToString:imageName] == NO){
        
        [[[self undoManager] prepareWithInvocationTarget:self] setImageName:currentImage];
        
        [self willChangeValueForKey:@"imageName"];
        self.currentStyleStorage.imageName = imageName;
        [self didChangeValueForKey:@"imageName"];
    }
}
- (NSString *)imageName{
    return self.liveStyleStorage.imageName;
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
            //[_css copyCSSDictFrom:nextSize to:size];
        }
    }

    //max size가 변하면 max css를 현재 css로 카피시킴.
    //960을만들고 1280을 나중에 만들면
    //1280으로 그냥 다옮겨가면서 960css 가 망가지게 됨.
    //방지하기 위한 용도
    if(size == maxSize){
        //[_css copyCSSMaxViewPortDictTo:oldMaxSize];
    }
    
    //[_css setMaxViewPort:maxSize];
    
}

- (void)removeMQSize:(NSNotification *)notification{
    NSInteger size = [[notification.userInfo objectForKey:IUNotificationMQSize] integerValue];
    NSInteger maxSize = [[notification.userInfo valueForKey:IUNotificationMQMaxSize] integerValue];
    NSInteger currentSize;
    if(size == maxSize){
        currentSize = IUDefaultViewPort;
    }
    else{
        currentSize = maxSize;
    }
    
    for(IUDataStorageManager *manager in storageManagersDict){
        [manager removeStorageForViewPort:currentSize];
    }
    
}


- (void)changeMQSelect:(NSNotification *)notification{
    
    [self willChangeValueForKey:@"canChangeHCenter"];

    NSInteger selectedSize = [[notification.userInfo valueForKey:IUNotificationMQSize] integerValue];
    NSInteger maxSize = [[notification.userInfo valueForKey:IUNotificationMQMaxSize] integerValue];
    NSInteger currentSize;

    if(selectedSize == maxSize){
        currentSize = IUDefaultViewPort;
    }
    else{
        currentSize = maxSize;
    }
    
    for(IUDataStorageManager *manager in [storageManagersDict allValues]){
        [manager setCurrentViewPort:currentSize];
    }
    
    [self didChangeValueForKey:@"canChangeHCenter"];
    
}


//source
#pragma mark HTML


- (void)updateHTML{
    
    if (self.sourceManager && self.isConnectedWithEditor) {
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
    /*
    if(_lineHeightAuto){
        if(_css.effectiveTagDictionary[IUCSSTagPixelHeight]){
            
            NSInteger brCount = [self.sourceManager countOfLineWithIdentifier:self.htmlID];
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
     */
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
    
    if(self.sourceManager && self.isConnectedWithEditor){
        [self updateCSSValuesBeforeUpdateEditor];
        [self.sourceManager setNeedsUpdateCSS:self];
    }
}


- (void)updateCSSWithIdentifiers:(NSArray *)identifiers{
    if(self.sourceManager){
        [self updateCSSValuesBeforeUpdateEditor];
        [self.sourceManager setNeedsUpdateCSS:self withIdentifiers:identifiers];
    }
}

- (void)setNeedsToUpdateStorage:(IUDataStorage *)storage{
    //FIXME:
    if(self.sourceManager){
        [self updateHTML];
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

    [(IUBox *)[self.undoManager prepareWithInvocationTarget:self] removeIU:iu];
    
    [_m_children insertObject:iu atIndex:index];
    
    iu.parent = self;
    if (self.isConnectedWithEditor) {
        [iu connectWithEditor];
        [iu setIsConnectedWithEditor];
    }
    
    
    [iu bind:@"identifierManager" toObject:self withKeyPath:@"identifierManager" options:nil];

    if (self.isConnectedWithEditor) {
        
        if ([self.sheet isKindOfClass:[IUClass class]]) {
            for (IUBox *import in [(IUClass*)self.sheet references]) {
                [import updateHTML];
            }
        }
        [self updateHTML];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationStructureDidChange object:self.project userInfo:@{IUNotificationStructureChangeType: IUNotificationStructureAdding, IUNotificationStructureChangedIU: iu}];
    }

    return YES;
}

-(BOOL)addIUReference:(IUBox *)iu error:(NSError**)error{
    [_m_children addObject:iu];
    return YES;
}


-(BOOL)removeIU:(IUBox *)iu{
        NSInteger index = [_m_children indexOfObject:iu];
        [[self.undoManager prepareWithInvocationTarget:self] insertIU:iu atIndex:index error:nil];
        
        //IURemoved 호출한 다음에 m_children을 호출해야함.
        //border를 지울려면 controller 에 iu 정보 필요.
        //--undo [self.project.identifierManager unregisterIUs:@[iu]];
        [self.sourceManager removeIU:self];
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
        [self.sourceManager removeIU:iu];
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
    
    [[[self undoManager] prepareWithInvocationTarget:self] setPgContentVariable:_pgContentVariable];
    
    BOOL needUpdate = NO;
    
    /*
    if(_pgContentVariable == nil && pgContentVariable && pgContentVariable.length > 0){
        _text = [self.mqData valueForTag:IUMQDataTagInnerHTML forViewport:IUCSSDefaultViewPort];
        [self.mqData eradicateTag:IUMQDataTagInnerHTML];
    }
    else if((pgContentVariable == nil || pgContentVariable.length==0) && _pgContentVariable && _pgContentVariable.length > 0){
        [self.mqData setValue:_text forTag:IUMQDataTagInnerHTML forViewport:IUCSSDefaultViewPort];
        _text = nil;
    }
    */
    
    _pgContentVariable = pgContentVariable;
    
    if(needUpdate){
        [self updateHTML];
    }
    
}

- (void)setPgVisibleConditionVariable:(NSString *)pgVisibleConditionVariable{
    if([pgVisibleConditionVariable isEqualToString:_pgVisibleConditionVariable]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setPgVisibleConditionVariable:_pgVisibleConditionVariable];
    
    _pgVisibleConditionVariable = pgVisibleConditionVariable;
}


- (IUTextInputType)textInputType{
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
    if ([self.currentPositionStorage.position isEqualToNumber:@(IUPositionTypeAbsoluteBottom)]) {
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

- (BOOL)canChangeWidthByDraggable{
    return YES;
}

- (BOOL)canChangeHeightByDraggable{
    return YES;
}

#pragma mark move by drag & drop




/*
 drag 중간의 diff size로 하면 css에 의한 오차가 생김.
 drag session이 시작될때부터 위치에서의 diff size로 계산해야 오차가 발생 안함.
 drag session이 시작할때 그 때의 위치를 저장함.
 */
/*


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
 */


- (void)startFrameMoveWithTransactionForStartFrame:(NSRect)frame{
    [self.currentPositionStorage beginTransaction:JD_CURRENT_FUNCTION];
    [self.currentStyleStorage beginTransaction:JD_CURRENT_FUNCTION];
    
    origianlFrame = frame;
}


- (void)endFrameMoveWithTransaction{
    [self.currentPositionStorage commitTransaction:JD_CURRENT_FUNCTION];
    [self.currentStyleStorage commitTransaction:JD_CURRENT_FUNCTION];
    
}
- (NSRect)originalFrame{
    return origianlFrame;
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
//    if(_positionType == IUPositionTypeFloatLeft || _positionType == IUPositionTypeFloatRight
//       || _css.editViewPort != IUCSSDefaultViewPort){
    if([self.livePositionStorage.position isEqualToNumber:@(IUPositionTypeFloatLeft)]
       || [self.livePositionStorage.position isEqualToNumber:@(IUPositionTypeFloatRight)]){
        return NO;
    }
    return YES;
}

- (BOOL)canChangeVCenter{
//    if(_positionType == IUPositionTypeAbsolute ||
//       _positionType == IUPositionTypeFixed){
    if([self.livePositionStorage.position isEqualToNumber:@(IUPositionTypeAbsolute)]
       || [self.livePositionStorage.position isEqualToNumber:@(IUPositionTypeFixed)]){
        return YES;
    }
    return NO;
}



- (BOOL)canChangeOverflow{
    return YES;
}

/*

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
 
 */

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


- (void)setLineHeightAuto:(BOOL)lineHeightAuto{
    /*
    if( _text && _text.length > 300){
        lineHeightAuto = false;
    }
     */
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

- (NSArray *)events{
    return [_events copy];
}

- (NSArray *)eventsCalledByOtherIU:(IUEvent2 *)event{
    return [_eventsCalledByOtherIU copy];
}

- (void)addEvent:(IUEvent2 *)event{
    [_events addObject:event];
}

- (void)addEventCalledByOtherIU:(IUEvent2 *)event{
    [_eventsCalledByOtherIU addObject:event];
}

- (void)removeEvent:(IUEvent2 *)event{
    [_events removeObject:event];
    [_eventsCalledByOtherIU removeObject:event];
}

@end
