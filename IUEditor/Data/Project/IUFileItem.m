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

- (IUProject *)project {
    if ([self isKindOfClass:[IUProject class]]) {
        return (IUProject *)self;
    }
    else if (self.parentFileItem == nil && [self isKindOfClass:[IUProject class]] == NO){
        return nil;
    }
    return [self.parentFileItem project];
}

- (BOOL)isFileItemGroup {
    return NO;
}

@end
