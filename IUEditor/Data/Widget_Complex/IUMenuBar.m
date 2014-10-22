//
//  IUMenuBar.m
//  IUEditor
//
//  Created by seungmi on 2014. 7. 31..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUMenuBar.h"
#import "IUMenuItem.h"
#import "IUProject.h"

@implementation IUMenuBar

-(id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [[self undoManager] disableUndoRegistration];
        
        self.count = 3;
        self.align = IUMenuBarAlignLeft;
        self.overflowType = IUOverflowTypeVisible;
        
        self.mobileTitle = @"MENU";
        self.iconColor = [NSColor whiteColor];
        [self.css setValue:@(IUAlignLeft) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
        
        if (self.shouldCompileHeight) {
            [self.css setValue:@(50) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        }
        
        
        [[self undoManager] enableUndoRegistration];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [[self undoManager] disableUndoRegistration];
        
        [aDecoder decodeToObject:self withProperties:[[IUMenuBar class] properties]];
        
        [[self undoManager] enableUndoRegistration];
    }
    return self;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    
    [super awakeAfterUsingCoder:aDecoder];
    
    if(self.project && IU_VERSION_V1_GREATER_THAN_V2(IU_VERSION_BETA2, self.project.IUProjectVersion)){
        [[self undoManager] disableUndoRegistration];

        [self.css setValue:nil forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        
        [[self undoManager] enableUndoRegistration];

    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[IUMenuBar class] properties]];
    
}

- (id)copyWithZone:(NSZone *)zone{
    IUMenuBar *menuBar = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    [self.delegate disableUpdateAll:self];

    
    //menubar
    menuBar.align = self.align;
    
    //mobile
    menuBar.mobileTitle = [self.mobileTitle copy];
    menuBar.iconColor = [self.iconColor copy];
    
    [self.delegate enableUpdateAll:self];
    [self.undoManager enableUndoRegistration];
    return menuBar;
}

- (void)connectWithEditor{
    [super connectWithEditor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanged:) name:IUNotificationSelectionDidChange object:nil];
    
    [self.css.effectiveTagDictionary addObserver:self forKeyPath:@"height" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    
}

- (void)dealloc{
    if([self isConnectedWithEditor]){
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.css.effectiveTagDictionary removeObserver:self forKeyPath:@"height" context:nil];
    }
}

-(void)selectionChanged:(NSNotification*)noti{
    
    if(self.children.count > 0 && self.css.editViewPort <= IUMobileSize){
        NSMutableSet *set = [NSMutableSet setWithArray:[self.allChildren arrayByAddingObject:self]];
        [set intersectSet:[NSSet setWithArray:[noti userInfo][@"selectedObjects"]]];
        
        if ([set count] >= 1) {
            _isOpened = YES;
        }
        else{
            _isOpened = NO;
        }
                
        [self updateCSSWithIdentifiers:@[[self editorDisplayIdentifier]]];

    }
    
}

- (void)heightDidChange:(NSDictionary *)dictionary{
    if(self.css.editViewPort <= IUMobileSize){
        //mobile에서만 사용하는 button들
        [self updateCSSWithIdentifiers:@[[self mobileButtonIdentifier], [self topButtonIdentifier], [self bottomButtonIdentifier]]];
    }
     
}
#pragma mark - css identifier

- (NSString *)editorDisplayIdentifier{
    if(self.children.count > 0){
        return [[self cssIdentifier] stringByAppendingString:@" > ul"];
    }
    return nil;
}

- (NSString *)mobileButtonIdentifier{
    return [[self cssIdentifier] stringByAppendingString:@" > .mobile-button"];
}

- (NSString *)topButtonIdentifier{
    return [[self cssIdentifier] stringByAppendingString:@" .menu-top"];
}

- (NSString *)bottomButtonIdentifier{
    return [[self cssIdentifier] stringByAppendingString:@" .menu-bottom"];
}

- (NSArray *)cssIdentifierArray{
    NSMutableArray *array = [[super cssIdentifierArray] mutableCopy];
    [array addObjectsFromArray:@[self.mobileButtonIdentifier, self.topButtonIdentifier, self.bottomButtonIdentifier]];
    return array;
}

#pragma mark - count
- (void)setCount:(NSInteger)count{
    if (count <= 1 || count > 20 || count == self.children.count ) {
        return;
    }
    if( count < self.children.count ){
        NSInteger diff = self.children.count - count;
        for( NSInteger i=0 ; i < diff ; i++ ) {
            [self removeIUAtIndex:[self.children count]-1];
        }
    }
    else if(count > self.children.count) {
        
        if (self.isConnectedWithEditor) {
            [self.project.identifierManager resetUnconfirmedIUs];
        }
        
        for(NSInteger i=self.children.count; i <count; i++){
            IUMenuItem *item = [[IUMenuItem alloc] initWithProject:self.project options:nil];
            item.name = item.htmlID;
            [self addIU:item error:nil];
        }
        
        if (self.isConnectedWithEditor) {
            [self.project.identifierManager confirm];
        }
    }
    
    [self updateHTML];

}

- (NSInteger)count{
    return [self.children count];
}



#pragma mark - setProperty

- (void)setMobileTitle:(NSString *)mobileTitle{
    if([_mobileTitle isEqualToString:mobileTitle]){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setMobileTitle:_mobileTitle];
    _mobileTitle = mobileTitle;
    [self updateHTML];
}

- (void)setMobileTitleColor:(NSColor *)mobileTitleColor{
    if([_mobileTitleColor isEqualTo:mobileTitleColor]){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setMobileTitleColor:_mobileTitleColor];
    _mobileTitleColor = mobileTitleColor;
    
    [self updateCSSWithIdentifiers:@[self.mobileButtonIdentifier]];
}

- (void)setIconColor:(NSColor *)iconColor{
    if([_iconColor isEqualTo:iconColor]){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setIconColor:_iconColor];
    _iconColor = iconColor;
    [self updateCSSWithIdentifiers:@[self.topButtonIdentifier, self.bottomButtonIdentifier]];
}

- (void)setAlign:(IUMenuBarAlign)align{
    if(_align == align){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setAlign:_align];
    _align = align;
    [self updateHTML];

}

#pragma mark - changeXXX

- (BOOL)canChangeOverflow{
    return NO;
}
- (BOOL)shouldCompileFontInfo{
    return YES;
}

- (BOOL)canAddIUByUserInput{
    return NO;
}

- (BOOL)canChangeWidthByUserInput{
    if( self.css.editViewPort <= IUMobileSize){
        return YES;
    }
    else{
        return NO;
    }
}
- (BOOL)shouldCompileWidth{
    return YES;
}
@end
