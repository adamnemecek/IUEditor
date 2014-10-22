//
//  ClipArt.m
//  IUEditor
//
//  Created by G on 2014. 7. 23..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "ClipArt.h"

@implementation ClipArt

-(id) init{
    self = [super init];
    if (self) {
        _title = @"default.jpg";
        _tag = @"puppy, default";
        _image = [NSImage imageNamed:self.title];
    }
    return self;
}

@end
