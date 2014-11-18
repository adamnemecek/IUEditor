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

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    self = [super awakeAfterUsingCoder:aDecoder];
    
    if(self){
        self.prototypeClass = [aDecoder decodeObjectForKey:@"_prototypeClass"];
    }
    
    return self;

}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:_prototypeClass forKey:@"_prototypeClass"];
}

- (id)copyWithZone:(NSZone *)zone{
    IUImport *iu = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    [_canvasVC disableUpdateAll:self];

    
    iu.prototypeClass = _prototypeClass;

    [_canvasVC enableUpdateAll:self];
    [self.undoManager enableUndoRegistration];
    return iu;
}

- (void)connectWithEditor{
    
    NSAssert(self.project, @"");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMQSelect:) name:IUNotificationMQSelected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMQSize:) name:IUNotificationMQAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeMQSize:) name:IUNotificationMQRemoved object:nil];
}

- (id)initWithPreset_prototype:(IUClass*)aClass{
    self = [super initWithPreset];
    [self.undoManager disableUndoRegistration];

    _prototypeClass = aClass;

    [self setCssManager:aClass.cssDefaultManager forSelector:kIUCSSManagerDefault];
    [self bind:@"liveCSSStorage" toObject:aClass.cssDefaultManager withKeyPath:@"liveStorage" options:nil];
    [self bind:@"currentCSSStorage" toObject:aClass.cssDefaultManager withKeyPath:@"currentStorage" options:nil];


    [self.undoManager enableUndoRegistration];
    return self;
}

- (void)setPrototypeClass:(IUClass *)prototypeClass{
    
    if(prototypeClass && [prototypeClass isEqualTo:_prototypeClass]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setPrototypeClass:_prototypeClass];

    [self willChangeValueForKey:@"children"];
    
    [_prototypeClass removeReference:self];
    
    if(prototypeClass == nil && _prototypeClass != nil){
        //remove layers
        for(IUBox *box in _prototypeClass.allChildren){
            NSString *currentID = [self modifieldHtmlIDOfChild:box];
            [_canvasVC IURemoved:currentID];
        }
        
        [_canvasVC IURemoved:[self modifieldHtmlIDOfChild:_prototypeClass]];

    }
    
    _prototypeClass = prototypeClass;
    
    if(_prototypeClass){
        [_prototypeClass setCanvasVC:  _canvasVC];
        [_prototypeClass addReference:self];
    }
    
    [self updateHTML];
    
    if (_canvasVC && _prototypeClass) {
        for (IUBox *iu in [prototypeClass.allChildren arrayByAddingObject:prototypeClass]) {
            [iu updateCSS];
        }
        
    }
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

- (void)setCanvasVC:(id<IUSourceDelegate>)canvasVC{
    [super setCanvasVC:canvasVC];
    [_prototypeClass setCanvasVC:canvasVC];
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
