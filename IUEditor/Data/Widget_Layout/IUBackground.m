//
//  IUBackground.m
//  IUEditor
//
//  Created by jd on 3/31/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUBackground.h"

@interface IUBackground()
@property NSMutableArray    *bodyParts;
@end


@implementation IUBackground __storage_deprecated


-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeToObject:self withProperties:[IUBackground properties]];
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[IUBackground properties]];
}


-(BOOL)shouldCompileX{
    return NO;
}

-(BOOL)shouldCompileY{
    return NO;
}

-(BOOL)shouldCompileWidth{
    return NO;
}

-(BOOL)shouldCompileHeight{
    return NO;
}

-(BOOL)canAddIUByUserInput{
    return NO;
}

- (void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"IUBackGround"];
}

- (BOOL)canCopy{
    return NO;
}

@end