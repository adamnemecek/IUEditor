//
//  IURender.m
//  IUEditor
//
//  Created by jd on 4/24/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUImport.h"
#import "IUBox.h"
#import "IUClass.h"

@implementation IUImport

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_render"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_render"];
}

+ (IUWidgetType)widgetType{
    return IUWidgetTypeSecondary;
}

#pragma mark - init

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeByRefObject:_prototypeClass forKey:@"_prototypeClass"];
}

- (void)awakeAfterUsingJDCoder:(JDCoder *)aDecoder{
    [super awakeAfterUsingJDCoder:aDecoder];
    [self.undoManager disableUndoRegistration];
    
    self.prototypeClass = [aDecoder decodeByRefObjectForKey:@"_prototypeClass"];
    
    [self.undoManager enableUndoRegistration];
}


- (id)copyWithZone:(NSZone *)zone{
    IUImport *iu = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];

    
    iu.prototypeClass = _prototypeClass;

    [self.undoManager enableUndoRegistration];
    return iu;
}



- (void)connectWithEditor{
    
    NSAssert(self.project, @"");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMQSelect:) name:IUNotificationMQSelected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMQSize:) name:IUNotificationMQAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeMQSize:) name:IUNotificationMQRemoved object:nil];
}


- (id)initWithPreset:(IUClass*)aClass{
    self = [super initWithPreset];
    [self.undoManager disableUndoRegistration];

    self.prototypeClass = aClass;
    
    for (NSString *selector in [aClass allCSSSelectors]) {
        [self setStorageManager:[aClass dataManagerForSelector:selector] forSelector:selector];
    }

    [self bind:@"liveStyleStorage" toObject:aClass.defaultStyleManager withKeyPath:@"liveStorage" options:nil];
    [self bind:@"currentStyleStorage" toObject:aClass.defaultStyleManager withKeyPath:@"currentStorage" options:nil];
    [self bind:@"livePositionStorage" toObject:aClass.positionManager withKeyPath:@"liveStorage" options:nil];
    [self bind:@"currentPositionStorage" toObject:aClass.positionManager withKeyPath:@"currentStorage" options:nil];



    [self.undoManager enableUndoRegistration];
    return self;
}

- (void)setPrototypeClass:(IUClass *)prototypeClass{
    
    if(prototypeClass && [prototypeClass isEqualTo:_prototypeClass]){
        return;
    }
    
    //FIXME: remove IU
    [[self.undoManager prepareWithInvocationTarget:self] setPrototypeClass:_prototypeClass];

    [self willChangeValueForKey:@"children"];
    
    [_prototypeClass removeReference:self];
    
    if(prototypeClass == nil && _prototypeClass != nil){
        //remove layers
        for(IUBox *box in _prototypeClass.allChildren){
//            NSString *currentID = [self modifieldHtmlIDOfChild:box];
            [self.sourceManager removeIU:box];
//            [_canvasVC IURemoved:currentID];
        }
        
        [self.sourceManager removeIU:_prototypeClass];
//        [_canvasVC IURemoved:[self modifieldHtmlIDOfChild:_prototypeClass]];

    }
    
    _prototypeClass = prototypeClass;
    
    if(_prototypeClass){
//        [_prototypeClass setCanvasVC:  _canvasVC];
        [_prototypeClass addReference:self];
    }
    
    [self updateHTML];
    
    /*
    if (_canvasVC && _prototypeClass) {
        for (IUBox *iu in [prototypeClass.allChildren arrayByAddingObject:prototypeClass]) {
            [iu updateCSS];
        }
        
    }
     */
    [self didChangeValueForKey:@"children"];
}

- (NSString *)modifieldHtmlIDOfChild:(IUBox *)iu{
    if([_prototypeClass.allChildren containsObject:iu]){
        NSString *importHTMLID = [NSString stringWithFormat:@"%@%@_%@",kIUImportEditorPrefix, self.htmlID, iu.htmlID];
        return importHTMLID;
    }
    else if(_prototypeClass == iu){
        NSString *importHTMLID = [NSString stringWithFormat:@"%@%@_%@",kIUImportEditorPrefix, self.htmlID, _prototypeClass.htmlID];
        return importHTMLID;
    }
    return nil;
}

- (NSArray*)children{
    if (_prototypeClass == nil) {
        return [NSArray array];
    }
    return @[_prototypeClass];
}

- (BOOL)canAddIUByUserInput{
    return NO;
}


- (NSMutableArray *)allIdentifierChildren{
    NSMutableArray *array =  [self allChildren];
    if(_prototypeClass){
        [array removeObject:_prototypeClass];
        [array removeObjectsInArray:[_prototypeClass allChildren]];
    }
    return array;
}


@end
