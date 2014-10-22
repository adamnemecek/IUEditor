//
//  IUTransition.m
//  IUEditor
//
//  Created by jd on 4/22/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUTransition.h"
#import "IUItem.h"

@interface IUTransition()

@property IUItem *firstItem;
@property IUItem *secondItem;

@end


@implementation IUTransition{
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[self undoManager] disableUndoRegistration];
        
        [aDecoder decodeToObject:self withProperties:[IUTransition propertiesWithOutProperties:@[@"firstItem", @"secondItem"]]];
     
        
        [[self undoManager] enableUndoRegistration];
    }
    return self;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    [super awakeAfterUsingCoder:aDecoder];
    
    if(self.children.count > 1){
        _firstItem = self.children[0];
        _secondItem = self.children[1];
    }
    else{
        assert(0);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[IUTransition propertiesWithOutProperties:@[@"firstItem", @"secondItem"]]];
}

- (id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    
    if(self){
        [[self undoManager] disableUndoRegistration];

        _firstItem = [[IUItem alloc] initWithProject:project options:options];
        _secondItem = [[IUItem alloc] initWithProject:project options:options];
        [_secondItem.css setValue:@(NO) forTag:IUCSSTagEditorDisplay forViewport:IUCSSDefaultViewPort];
        
        [self addIU:_firstItem error:nil];
        [self addIU:_secondItem error:nil];
        self.currentEdit = 0;
        self.eventType = @"Click";
        self.animation = @"Blind";
        self.duration  = 0.2;
        
        [[self undoManager] enableUndoRegistration];

    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    IUTransition *iu = [super copyWithZone:zone];
    [[self undoManager] disableUndoRegistration];
    [self.delegate disableUpdateAll:self];

    

    iu.currentEdit = _currentEdit;
    iu.eventType = [_eventType copy];
    iu.animation = [_animation copy];
    iu.duration = _duration;
    
    if(iu.children.count > 0){
        iu.firstItem = iu.children[0];
        iu.secondItem = iu.children[1];
    }
    
    [self.delegate enableUpdateAll:self];
    [[self undoManager] enableUndoRegistration];

    return iu;
}
- (void)connectWithEditor{
    [super connectWithEditor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanged:) name:IUNotificationSelectionDidChange object:nil];

}

- (void)dealloc{
    if([self isConnectedWithEditor]){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IUNotificationSelectionDidChange object:nil];
    }
}

- (void)selectionChanged:(NSNotification*)noti{
    
    
    NSMutableSet *set = [NSMutableSet setWithArray:self.children];
    [set intersectSet:[NSSet setWithArray:[noti userInfo][@"selectedObjects"]]];
    if ([set count] != 1) {
        return;
    }
    
    if(self.delegate){
        [self.delegate disableUpdateCSS:self];
    }
    
    
    IUBox *box = [set anyObject];
    if (box == _firstItem) {
        [self setCurrentEdit:0];
    }
    else {
        [self setCurrentEdit:1];
    }
    
    if(self.delegate){
        [self.delegate enableUpdateCSS:self];
    }
    
    [self updateHTML];
}


- (void)setHtmlID:(NSString *)htmlID{
    [super setHtmlID:htmlID];
    _firstItem.htmlID = [htmlID stringByAppendingString:@"Item1"];
    _firstItem.name = _firstItem.htmlID;
    _secondItem.htmlID = [htmlID stringByAppendingString:@"Item2"];
    _secondItem.name = _secondItem.htmlID;
}

- (void)setCurrentEdit:(NSInteger)currentEdit{
    _currentEdit = currentEdit;
    if (currentEdit == 0) {
        [_firstItem.css setValue:@(YES) forTag:IUCSSTagEditorDisplay forViewport:IUCSSDefaultViewPort];
        [_secondItem.css setValue:@(NO) forTag:IUCSSTagEditorDisplay forViewport:IUCSSDefaultViewPort];
    }
    else {
        [_firstItem.css setValue:@(NO) forTag:IUCSSTagEditorDisplay forViewport:IUCSSDefaultViewPort];
        [_secondItem.css setValue:@(YES) forTag:IUCSSTagEditorDisplay forViewport:IUCSSDefaultViewPort];
    }
}

- (void)setEventType:(NSString *)eventType{
    if([_eventType isEqualToString:eventType]){
        return ;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setEventType:_eventType];
    
    _eventType = eventType;
}

- (void)setAnimation:(NSString *)animation{
    if ([_animation isEqualToString:animation]) {
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setAnimation:_animation];
    _animation = animation;
}

- (void)setDuration:(float)duration{
    if(_duration == duration){
        return;
    }
    [(IUTransition *)[self.undoManager prepareWithInvocationTarget:self] setDuration:_duration];
    _duration = duration;
}

- (BOOL)canAddIUByUserInput{
    return NO;
}

@end
