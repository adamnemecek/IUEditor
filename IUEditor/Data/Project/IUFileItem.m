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
        _name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}
- (void)awakeAfterUsingJDCoder:(JDCoder *)aDecoder{
    _parentFileItem = [aDecoder decodeObjectForKey:@"parentFileItem"];
    
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

- (NSString *)path {
    if (self.parentFileItem == nil) {
        return @"/";
    }
    else {
        return [[self.parentFileItem path] stringByAppendingPathComponent:_name];
    }
}

- (NSInteger)fileItemLevel {
    if (self.parentFileItem == nil) {
        return 0;
    }
    return [self.parentFileItem fileItemLevel] + 1;
}

@end
