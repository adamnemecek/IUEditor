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

-(id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        [self.css eradicateTag:IUCSSTagPixelWidth];
        [self.css eradicateTag:IUCSSTagBGColor];
        
        self.positionType = IUPositionTypeFloatLeft;
        self.overflowType = IUOverflowTypeVisible;
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)increaseSize:(NSSize)size withParentSize:(NSSize)parentSize{
    [super increaseSize:size withParentSize:parentSize];
    CGFloat width = [self.css.effectiveTagDictionary[IUCSSTagPercentWidth] floatValue];
    CGFloat pageContentWidth = 100-width;
    
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
