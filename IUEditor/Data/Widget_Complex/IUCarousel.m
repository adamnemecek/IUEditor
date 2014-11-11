//
//  IUCarousel.m
//  IUEditor
//
//  Created by jd on 4/15/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUCarousel.h"
#import "IUCarouselItem.h"
#import "IUSheet.h"
#import "IUProject.h"

@implementation IUCarousel{
}

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [[self undoManager] disableUndoRegistration];

        self.count = 3;
        [self.css setValue:@(500) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(300) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        [self.css setValue:[NSColor clearColor] forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
        _selectColor = [NSColor blackColor];
        _deselectColor = [NSColor grayColor];
        _rightArrowImage = @"clipArt/arrow_right.png";
        _leftArrowImage = @"clipArt/arrow_left.png";
        _leftY = 100;
        _rightY = 100;
        _pagerPosition = 50;
        
        [[self undoManager] enableUndoRegistration];

    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self =  [super initWithCoder:aDecoder];
    if(self){
        [[self undoManager] disableUndoRegistration];

        [aDecoder decodeToObject:self withProperties:[[IUCarousel class] propertiesWithOutProperties:@[@"count"]]];
        
        [[self undoManager] enableUndoRegistration];

    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[IUCarousel class] propertiesWithOutProperties:@[@"count"]]];
    
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    [super awakeAfterUsingCoder:aDecoder];
    
    if(self.project && IU_VERSION_V1_GREATER_THAN_V2(IU_VERSION_BETA2, self.project.IUProjectVersion)){
        [[self undoManager] disableUndoRegistration];
        
        BOOL disable = [[aDecoder decodeObjectForKey:@"disableArrowControl"] boolValue];
        [self.css setValue:@(disable) forTag:IUCSSTagCarouselArrowDisable forViewport:IUCSSDefaultViewPort];
        
        [[self undoManager] enableUndoRegistration];
        
    }
    
    return self;
}



- (id)copyWithZone:(NSZone *)zone{
    IUCarousel *carousel = [super copyWithZone:zone];
    
    [[self undoManager] disableUndoRegistration];
    [_canvasVC disableUpdateAll:self];


    //auto
    carousel.autoplay = _autoplay;
    carousel.timer = _timer;
    //arrow
    carousel.leftArrowImage = [_leftArrowImage copy];
    carousel.rightArrowImage = [_rightArrowImage copy];
    carousel.leftX = _leftX;
    carousel.leftY = _leftY;
    carousel.rightX = _rightX;
    carousel.rightY = _rightY;
    
    //pager
    carousel.controlType = _controlType;
    carousel.selectColor = [_selectColor copy];
    carousel.deselectColor = [_deselectColor copy];
    carousel.pagerPosition = _pagerPosition;
    
    [_canvasVC enableUpdateAll:self];
    [[self undoManager] enableUndoRegistration];

    
    return carousel;
}


- (void)connectWithEditor{
    [super connectWithEditor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanged:) name:IUNotificationSelectionDidChange object:nil];
    
    if(self.children.count > 0){
        IUCarouselItem *item = self.children[0];
        item.isActive = YES;
    }
    


}

-(void)dealloc{
    if([self isConnectedWithEditor]){
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}


-(void)setCount:(NSInteger)count{
    
    if (count <= 1 || count > 30 || count == self.children.count ) {
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
            IUCarouselItem *item = [[IUCarouselItem alloc] initWithProject:self.project options:nil];
            item.name = item.htmlID;
            [self addIU:item error:nil];
        }
        
        if (self.isConnectedWithEditor) {
            [self.project.identifierManager confirm];
        }
    }

    
    [self updateHTML];
}

-(void)selectionChanged:(NSNotification*)noti{
    NSMutableSet *set = [NSMutableSet setWithArray:self.allChildren];
    [set intersectSet:[NSSet setWithArray:[noti userInfo][@"selectedObjects"]]];
    if ([set count] != 1) {
        return;
    }
    
    if(_canvasVC){
        [_canvasVC disableUpdateCSS:self];
    }
    
    IUBox *selectedChild = [set anyObject];
    for(IUCarouselItem *item in self.children){
        if([item isEqualTo:selectedChild] || [item.allChildren containsObject:selectedChild]){
            [item.css setValue:@(YES) forTag:IUCSSTagEditorDisplay forViewport:IUCSSDefaultViewPort];
            item.isActive = YES;
        }
        else{
            [item.css setValue:@(NO) forTag:IUCSSTagEditorDisplay forViewport:IUCSSDefaultViewPort];
            item.isActive = NO;
        }
    }
    
    if(_canvasVC){
        [_canvasVC enableUpdateCSS:self];
    }
    
    [self updateHTML];
}

- (NSInteger)count{
    return [self.children count];
}

#pragma mark Inner CSS (Carousel)


- (NSString *)pagerWrapperID{
    return [NSString stringWithFormat:@"%@ > .Pager", self.cssIdentifier];
}

- (NSString *)pagerID{
    return [NSString stringWithFormat:@"%@ > .Pager > li", self.cssIdentifier];
}

- (NSString *)pagerIDHover{
    return [NSString stringWithFormat:@"%@ > .Pager > li:hover", self.cssIdentifier];
}

- (NSString *)pagerIDActive{
    return [NSString stringWithFormat:@"%@ > .Pager > li.active", self.cssIdentifier];
}

- (NSString *)prevID{
    return [NSString stringWithFormat:@"%@ > .Prev", self.cssIdentifier];
}

- (NSString *)nextID{
    return [NSString stringWithFormat:@"%@ > .Next", self.cssIdentifier];
}

- (NSArray *)cssIdentifierArray{
    NSMutableArray *cssArray = [[super cssIdentifierArray] mutableCopy];
    
    if(self.controlType == IUCarouselControlBottom){
        [cssArray addObjectsFromArray:@[self.pagerID, self.pagerIDHover , self.pagerIDActive, self.pagerWrapperID, self.prevID, self.nextID]];
    }
    
    return cssArray;
}


#pragma mark - pager
- (void)setControlType:(IUCarouselControlType)controlType{
    if(controlType == _controlType){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setControlType:_controlType];
    
    
    _controlType = controlType;
    [self updateHTML];
}

- (void)setSelectColor:(NSColor *)selectColor{
    
    if([selectColor isEqualTo:_selectColor]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setSelectColor:_selectColor];
    
    _selectColor = selectColor;
    [self updateCSSForItemColor];
}
- (void)setDeselectColor:(NSColor *)deselectColor{
    
    if([_deselectColor isEqualTo:deselectColor]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setDeselectColor:_deselectColor];
    
    _deselectColor = deselectColor;
    [self updateCSSForItemColor];
}

- (void)setPagerPosition:(NSInteger)pagerPosition{
    
    if(_pagerPosition == pagerPosition){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setPagerPosition:_pagerPosition];
    
    _pagerPosition = pagerPosition;
    [self updateCSSWithIdentifiers:@[self.pagerWrapperID]];
}

- (void)updateCSSForItemColor{
    [self updateCSSWithIdentifiers:@[self.pagerID, self.pagerIDHover, self.pagerIDActive]];
}

#pragma mark - arrow

- (void)setLeftArrowImage:(NSString *)leftArrowImage{
    
    if([_leftArrowImage isEqualToString:leftArrowImage]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setLeftArrowImage:_leftArrowImage];
    
    _leftArrowImage = leftArrowImage;
    [self cssForArrowImage:IUCarouselArrowLeft];
}

- (void)setRightArrowImage:(NSString *)rightArrowImage{
    
    if([_rightArrowImage isEqualToString:rightArrowImage]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setRightArrowImage:_rightArrowImage];
    
    _rightArrowImage = rightArrowImage;
    [self cssForArrowImage:IUCarouselArrowRight];

}

- (void)setLeftX:(int)leftX{
    
    if(_leftX == leftX){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setLeftX:_leftX];
    
    _leftX = leftX;
    [self cssForArrowImage:IUCarouselArrowLeft];
}
- (void)setLeftY:(int)leftY{
    
    if(_leftY == leftY){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setLeftY:_leftY];
    
    _leftY = leftY;
    [self cssForArrowImage:IUCarouselArrowLeft];
}

- (void)setRightX:(int)rightX{
    
    if(_rightX == rightX){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setRightX:_rightX];
    
    _rightX = rightX;
    [self cssForArrowImage:IUCarouselArrowRight];
}
- (void)setRightY:(int)rightY{
    
    if(_rightY == rightY){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setRightY:_rightY];
    
    _rightY = rightY;
    [self cssForArrowImage:IUCarouselArrowRight];
}

- (void)cssForArrowImage:(IUCarouselArrow)type{
    NSString *arrowID;
    if(type == IUCarouselArrowLeft){
        arrowID = self.prevID;
    }
    else if(type == IUCarouselArrowRight){
        arrowID = self.nextID;
    }
    if(arrowID){
        [self updateCSSWithIdentifiers:@[arrowID]];
    }
}

#pragma mark - property for undo

- (void)setAutoplay:(BOOL)autoplay{
    if(autoplay == _autoplay){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setAutoplay:_autoplay];
    _autoplay = autoplay;
}

- (void)setTimer:(NSInteger)timer{
    if(timer == _timer){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setTimer:_timer];
    _timer = timer;
}

- (BOOL)canAddIUByUserInput{
    return NO;
}

@end