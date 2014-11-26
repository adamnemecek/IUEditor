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
/* old version : decode 용도로만 사용됨*/

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
