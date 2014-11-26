//
//  IUSidebar.m
//  IUEditor
//
//  Created by seungmi on 2014. 9. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUSidebar.h"
#import "IUPageContent.h"

@implementation IUSidebar

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_sidebar"];
}

#pragma mark - Initialize


- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        [self setDefaultProperties];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (id)initWithPreset:(IUClass *)aClass{
    self = [super initWithPreset:aClass];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        [self setDefaultProperties];

        [self.undoManager enableUndoRegistration];

    }
    return  self;
}

- (void)setDefaultProperties{
    
    self.defaultPositionStorage.position = @(IUPositionTypeFloatLeft);
    self.defaultStyleStorage.width = nil;
    self.defaultStyleStorage.bgColor = nil;
    self.defaultStyleStorage.overflowType = @(IUOverflowTypeVisible);
    
    [self.css eradicateTag:IUCSSTagPixelWidth];
    [self.css eradicateTag:IUCSSTagBGColor];
    
}

- (void)setPixelWidth:(CGFloat)pixelWidth percentWidth:(CGFloat)percentWidth{
    [super setPixelWidth:pixelWidth percentWidth:percentWidth];
    CGFloat pageContentWidth = 100 - percentWidth;
    
    for(IUBox *box in self.parent.children){
        if([box isKindOfClass:[IUPageContent class]]){
            [box.css setValueWithoutUpdateCSS:@(pageContentWidth) forTag:IUCSSTagPercentWidth];
            [box updateCSS];
        }
    }

}

-(BOOL)canRemoveIUByUserInput{
    return NO;
}

- (BOOL)canChangeOverflow{
    return NO;
}
- (BOOL)canChangePositionType{
    return NO;
}

- (BOOL)shouldCompileX{
    return NO;
}

- (BOOL)shouldCompileY{
    return NO;
}

- (BOOL)shouldCompileWidth{
    return YES;
}
- (BOOL)shouldCompileHeight{
    return NO;
}

- (BOOL)canChangeXByUserInput{
    return NO;
}

- (BOOL)canChangeYByUserInput{
    return NO;
}


- (BOOL)canCopy{
    return NO;
}

@end
