//
//  IUImage.m
//  IUEditor
//
//  Created by JD on 4/1/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUImage.h"

@implementation IUImage

-(id)initWithCoder:(NSCoder *)aDecoder{
    self =  [super initWithCoder:aDecoder];
    [self.undoManager disableUndoRegistration];

    if(self){
        [aDecoder decodeToObject:self withProperties:[[IUImage class] properties]];
    }
    
    [self.undoManager enableUndoRegistration];
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];

    [aCoder encodeFromObject:self withProperties:[[IUImage class] properties]];
    
}

- (BOOL)shouldCompileImagePositionInfo{
    return NO;
}

-(id)copyWithZone:(NSZone *)zone{
    [self.undoManager disableUndoRegistration];
    [_canvasVC disableUpdateAll:self];

    
    IUImage *image = [super copyWithZone:zone];
    image.imageName = [_imageName copy];
    image.altText = [_altText copy];
    
    [_canvasVC enableUpdateAll:self];
    [self.undoManager enableUndoRegistration];
    return image;
}

#pragma mark - 
#pragma mark IUImage

- (BOOL)canAddIUByUserInput{
    return NO;
}


- (void)setImageName:(NSString *)imageName{
    
    if([imageName isEqualToString:_imageName]){
        return;
    }
    [[[self undoManager] prepareWithInvocationTarget:self] setImageName:_imageName];
    _imageName = imageName;
    
    [self updateHTML];
}

- (void)setAltText:(NSString *)altText{
    if([altText isEqualToString:_altText]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setAltText:_altText];
    _altText = altText;
}

@end
