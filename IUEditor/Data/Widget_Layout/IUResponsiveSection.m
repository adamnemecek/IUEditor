//
//  IUResponsiveSection.m
//  IUEditor
//
//  Created by jd on 4/24/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUResponsiveSection.h"
#import "IUSection.h"

@implementation IUResponsiveSection

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [self.css setValue:@(0) forTag:IUCSSTagXUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(0) forTag:IUCSSTagYUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(1) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(0) forTag:IUCSSTagHeightUnitIsPercent forViewport:IUCSSDefaultViewPort];
        
        [self.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(500) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(0) forTag:IUCSSTagPixelX forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(0) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
        
        self.positionType = IUPositionTypeRelative;
     }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    IUSection *section = [[IUSection alloc] initWithCoder:aDecoder];
    
    [aDecoder decodeToObject:section withProperties:[[IUSection class] properties]];
    /*
     Version control
     
     since no IUResponsiveSection is allocated, check child and assign it to 'section'
     */
    for (IUBox *box in section.children) {
        box.parent = section;
    }
    return (IUResponsiveSection*)section;
}


-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[IUResponsiveSection class] properties]];
    
}


- (BOOL)canChangeXByUserInput{
    return NO;
}
- (BOOL)canChangeYByUserInput{
    return NO;
}
- (BOOL)canChangeWidthByUserInput{
    return NO;
}

- (BOOL)canChangePositionType{
    return NO;
}

@end
