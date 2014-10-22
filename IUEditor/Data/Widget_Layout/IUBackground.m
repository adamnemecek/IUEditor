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


@implementation IUBackground

-(id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [self.undoManager disableUndoRegistration];
        [self.css setValue:nil forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
        
        NSNumber *num = [options objectForKey:kIUBackgroundOptionEmpty];
        if ([num intValue] == NO) {
            _header = [[IUHeader alloc] initWithProject:project options:nil];
            _header.htmlID = @"Header";
            [self addIU:_header error:nil];
        }
        NSAssert(self.children, @"");
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self.undoManager disableUndoRegistration];
    [aDecoder decodeToObject:self withProperties:[IUBackground properties]];
    [self.undoManager enableUndoRegistration];
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