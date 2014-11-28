//
//  IUMenuBarItem.m
//  IUEditor
//
//  Created by seungmi on 2014. 7. 31..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUMenuItem.h"
#import "IUMenuBar.h"
#import "IUProject.h"

@implementation IUMenuItem

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_carousel_item"];
}

#pragma mark - Initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        self.text = @"MENU";
        self.bgActive = [NSColor blackColor];
        self.fontActive = [NSColor whiteColor];

        self.defaultPositionStorage.position = @(IUPositionTypeRelative);
        
        self.defaultStyleStorage.overflowType = @(IUOverflowTypeVisible);
        self.defaultStyleStorage.bgColor = [NSColor grayColor];
        self.defaultStyleStorage.fontColor = [NSColor whiteColor];
        self.defaultStyleStorage.width = @(130);
        self.defaultStyleStorage.fontLineHeight = nil;

        [self.undoManager enableUndoRegistration];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        
        [aDecoder decodeToObject:self withProperties:[[IUMenuItem class] propertiesWithOutProperties:@[@"isOpened"]]];
        
    }
    return self;
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[[IUMenuItem class] propertiesWithOutProperties:@[@"isOpened"]]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}


- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    [super awakeAfterUsingCoder:aDecoder];
    if(self.project && IU_VERSION_V1_GREATER_THAN_V2(IU_VERSION_BETA2, self.project.IUProjectVersion)){

        [self.css eradicateTag:IUCSSTagWidthUnitIsPercent];
        [self.css setValue:@(0) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(130) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[IUMenuItem class]  propertiesWithOutProperties:@[@"isOpened"]]];

}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[IUMenuItem class]  propertiesWithOutProperties:@[@"isOpened"]]];
}

- (id)copyWithZone:(NSZone *)zone{
    IUMenuItem *menuItem = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];

    
    menuItem.bgActive = [NSColor grayColor];
    menuItem.fontActive = [NSColor whiteColor];
    
    [self.undoManager enableUndoRegistration];
    return menuItem;
}


- (void)connectWithEditor{
    [super connectWithEditor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanged:) name:IUNotificationSelectionDidChange object:nil];
    [self.parent.liveStyleStorage addObserver:self forKeyPath:@"height" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:@"height"];
    

}



- (void)disconnectWithEditor{
    if([self isConnectedWithEditor]){
        [self.parent.liveStyleStorage removeObserver:self forKeyPath:@"height" context:@"height"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];

    }
    [super disconnectWithEditor];
}


-(void)selectionChanged:(NSNotification*)noti{
    
    if(self.children.count > 0 && self.defaultStyleManager.currentViewPort > IUMobileSize){
        NSMutableSet *set = [NSMutableSet setWithArray:[self.allChildren arrayByAddingObject:self]];
        [set intersectSet:[NSSet setWithArray:[noti userInfo][@"selectedObjects"]]];
        BOOL isChanged = NO;
        
        if ([set count] >= 1) {
            if(_isOpened == NO){
                isChanged = YES;
            }
            _isOpened = YES;
            
        }
        else{
            if(_isOpened == YES){
                isChanged = YES;
            }
            _isOpened = NO;
        }
        
        if(isChanged){
            [self updateCSSWithIdentifiers:@[[self editorDisplayIdentifier]]];
            for(IUMenuItem *child in self.children){
                [child updateCSS];
            }
        }

    }
    
}


- (void)heightDidChange:(NSDictionary *)dictionary{
    [self updateCSS];
}



#pragma mark - count

- (BOOL)canSelectedWhenOpenProject{
    return NO;
}

- (void)setCount:(NSInteger)count{
    
    
    if (count < 0 || count > 20 || count == self.children.count ) {
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
            IUMenuItem *subMenu = [[IUMenuItem alloc] initWithPreset];
            subMenu.name = subMenu.htmlID;
            [self addIU:subMenu error:nil];
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

#pragma mark - depth

- (NSInteger)depth{
    if([self.parent isKindOfClass:[IUMenuBar class]]){
        return 1;
    }
    else if([self.parent isKindOfClass:[IUMenuItem class]]){
        return 1 + [(IUMenuItem *)self.parent depth];
    }
    return 0;
}

- (BOOL)hasItemChildren{
    if([self depth] > 2){
        return NO;
    }
    else{
        return YES;
    }
}

#pragma mark - property

- (void)setBgActive:(NSColor *)bgActive{
    if([_bgActive isEqualTo:bgActive]){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setBgActive:_bgActive];
    _bgActive = bgActive;

    [self updateCSSForItemColor];
}

- (void)setFontActive:(NSColor *)fontActive{
    if([_fontActive isEqualTo:fontActive]){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setFontActive:_fontActive];
    _fontActive = fontActive;
    
    [self updateCSSForItemColor];
}

- (void)setText:(NSString *)text{
    if([_text isEqualToString:text]){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setText:_text];
    
    _text = text;
    [self updateHTML];
}

#pragma mark - css

- (NSString *)editorDisplayIdentifier{
    if(self.children.count > 0){
        return [self.cssIdentifier stringByAppendingString:@" > ul"];
    }
    return nil;
}

- (NSString *)itemIdentifier{
    return [self.cssIdentifier stringByAppendingString:@" > a"];
}
- (NSString *)hoverItemIdentifier{
    return [self.cssHoverClass stringByAppendingString:@" > a"];
}

- (NSString *)activeItemIdentifier{
    return [self.cssActiveClass stringByAppendingString:@" > a"];
}

/* removed. 2014.10.10 smchoi
- (NSString *)closureIdentifier{
    if(self.children.count > 0){
        return [self.cssIdentifier stringByAppendingString:@" > div.closure"];
    }
    return nil;
}

- (NSString *)closureHoverIdentifier{
    if(self.children.count > 0){
        return [self.cssHoverClass stringByAppendingString:@" > div.closure:hover"];
    }
    return nil;
}
- (NSString *)closureActiveIdentifier{
    if(self.children.count > 0){
        return [self.cssActiveClass stringByAppendingString:@" > div.closure:active"];
    }
    return nil;
}
 */

- (NSArray *)cssIdentifierArray{
    if(self.children.count > 0){
        return @[[self cssIdentifier], [self itemIdentifier], [self hoverItemIdentifier], [self activeItemIdentifier], [self editorDisplayIdentifier]];
    }
    else{
        return @[[self cssIdentifier], [self itemIdentifier], [self hoverItemIdentifier], [self activeItemIdentifier]];
    }
}


- (void)updateCSSForItemColor{
    [self updateCSSWithIdentifiers:@[[self hoverItemIdentifier], [self activeItemIdentifier]]];
}


#pragma mark - shouldXXX
- (IUTextInputType)textInputType{
    return IUTextInputTypeTextField;
}

- (BOOL)shouldCompileX{
    return NO;
}
- (BOOL)shouldCompileY{
    return NO;
}

- (BOOL)shouldCompileHeight{
    if(self.depth == 2){
        return YES;
    }
    return NO;
}
- (BOOL)shouldCompileWidth{
    if(self.depth ==1){
        return YES;
    }
    else{
        return NO;
    }
}
- (BOOL)canChangeHeightByUserInput{
    if(self.depth == 2){
        return YES;
    }
    return NO;
}
- (BOOL)canChangePositionType{
    return NO;
}
- (BOOL)canChangeOverflow{
    return NO;
}
- (BOOL)canAddIUByUserInput{
    return NO;
}
- (BOOL)canRemoveIUByUserInput{
    return NO;
}
- (BOOL)shouldSelectParentFirst{
    if([self depth]==1){
        return YES;
    }
    return NO;
}

- (BOOL)canChangeWidthUnitByUserInput{
    return NO;
}

- (BOOL)canChangeWidthByUserInput{
    if(self.defaultStyleManager.currentViewPort <= IUMobileSize){
        return NO;
    }
    else{
        return YES;
    }
}
- (BOOL)shouldExtendParent{
    if(self.defaultStyleManager.currentViewPort <= IUMobileSize){
        return YES;
    }
    else{
        return NO;
    }
}
@end
