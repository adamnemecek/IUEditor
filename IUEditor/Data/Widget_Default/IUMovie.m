//
//  IUMovie.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 21..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUMovie.h"
#import <AVFoundation/AVFoundation.h>

#import "IUImageUtil.h"
#import "IUSheet.h"
#import "IUCompiler.h"


@implementation IUMovie



-(id)initWithCoder:(NSCoder *)aDecoder{
    self =  [super initWithCoder:aDecoder];
    [self.undoManager disableUndoRegistration];
    if(self){
        [aDecoder decodeToObject:self withProperties:[[IUMovie class] properties]];
    }
    [self.undoManager enableUndoRegistration];
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[IUMovie class] properties]];
    
}

-(id)copyWithZone:(NSZone *)zone{
    IUMovie *movie = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    [self.delegate disableUpdateAll:self];

    
    movie.videoPath = [_videoPath copy];
    movie.altText = [_altText copy];
    movie.posterPath = [_posterPath copy];
    
    movie.enableAutoPlay = _enableAutoPlay;
    movie.enableControl = _enableControl;
    movie.enableLoop = _enableLoop;
    movie.enableMute = _enableMute;
    
    [self.delegate enableUpdateAll:self];
    [self.undoManager enableUndoRegistration];
    return movie;
}

- (void)connectWithEditor{
    [super connectWithEditor];
    [self addObserver:self forKeyPaths:@[@"posterPath"] options:0 context:@"attributes"];
}


-(void)dealloc{
    [self removeObserver:self forKeyPaths:@[@"posterPath"]];
}

- (BOOL)canAddIUByUserInput{
    return NO;
}


- (void)setVideoPath:(NSString *)videoPath{
    if([videoPath isEqualToString:_videoPath]){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setVideoPath:_videoPath];
    _videoPath = videoPath;
    
    [self updateHTML];
}

- (void)setEnableAutoPlay:(BOOL)enableAutoPlay{
    if(enableAutoPlay == _enableAutoPlay){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setEnableAutoPlay:_enableAutoPlay];
    
    _enableAutoPlay = enableAutoPlay;
    [self updateHTML];

}

- (void)setEnableControl:(BOOL)enableControl{
    if(enableControl == _enableControl){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setEnableControl:_enableControl];
    _enableControl = enableControl;
    [self updateHTML];

}

- (void)setEnableLoop:(BOOL)enableLoop{
    if(_enableLoop == enableLoop){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setEnableLoop:_enableLoop];
    _enableLoop = enableLoop;
    [self updateHTML];

}

- (void)setEnableMute:(BOOL)enableMute{
    if(_enableMute == enableMute){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setEnableMute:_enableMute];
    _enableMute = enableMute;
    [self updateHTML];

}

- (void)setCover:(BOOL)cover{
    if(_cover == cover){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setCover:_cover];
    _cover = cover;
    [self updateHTML];
}

- (void)attributesContextDidChange:(NSDictionary *)change{
    [self updateHTML];
}

@end
