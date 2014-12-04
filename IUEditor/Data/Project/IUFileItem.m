//
//  IUFileItem.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 26..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUFileItem.h"
#import "IUProject.h"

@implementation IUFileItem {
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super init];
    if(self){
        [aDecoder decodeToObject:self withProperties:[IUFileItem properties]];
        
    }
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder encodeFromObject:self withProperties:[IUFileItem properties]];

}
- (IUProject *)project {
    if ([self isKindOfClass:[IUProject class]]) {
        return (IUProject *)self;
    }
    else if (self.parentFileItem == nil && [self isKindOfClass:[IUProject class]] == NO){
        return nil;
    }
    return [self.parentFileItem project];
}

- (BOOL)isLeaf {
    return YES;
}

@end
