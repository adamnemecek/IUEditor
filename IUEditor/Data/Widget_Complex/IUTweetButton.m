//
//  IUTweetButton.m
//  IUEditor
//
//  Created by seungmi on 2014. 8. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUTweetButton.h"

@interface IUTweetButton()


@end

@implementation IUTweetButton


-(id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [[self undoManager] disableUndoRegistration];
        self.sizeType = IUTweetButtonSizeTypeMeidum;
        self.countType = IUTweetButtonCountTypeNone;
        
        [self.css setValue:@(20) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(56) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        [self.css setValue:nil forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
        
        [[self undoManager] enableUndoRegistration];
        
    }
    return self;
}

- (void)connectWithEditor{
    [super connectWithEditor];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self =  [super initWithCoder:aDecoder];
    if(self){
        [[self undoManager] disableUndoRegistration];
        
        [aDecoder decodeToObject:self withProperties:[[IUTweetButton class] properties]];
        [[self undoManager] enableUndoRegistration];
        
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[IUTweetButton class] properties]];
    
}

- (id)copyWithZone:(NSZone *)zone{
    IUTweetButton *iu = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    [_canvasVC disableUpdateAll:self];
    

    iu.tweetText = [_tweetText copy];
    iu.urlToTweet = [_urlToTweet copy];
    iu.countType = _countType;
    iu.sizeType = _sizeType;
    
    [_canvasVC enableUpdateAll:self];
    [self.undoManager enableUndoRegistration];
    return iu;
}

#pragma mark - property
- (void)setTweetText:(NSString *)tweetText{
    if([_tweetText isEqualToString:tweetText]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setTweetText:_tweetText];
    _tweetText = tweetText;
}

- (void)setUrlToTweet:(NSString *)urlToTweet{
    if([_urlToTweet isEqualToString:urlToTweet]){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setUrlToTweet:_urlToTweet];
    _urlToTweet = urlToTweet;
}

/*
 widget default size
 small - v 56:62;
 small - h 107:20;
 small - n 56: 20;
 
 large -v (not supported by twitter)
 large -h 138:28;
 large -n 76:28
 
 */

- (void)setCountType:(IUTweetButtonCountType)countType{
    if(_countType == countType){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setCountType:_countType];
    _countType = countType;
    [self updateSize];
    [self updateHTML];
}


- (void)setSizeType:(IUTweetButtonSizeType)sizeType{
    if(_sizeType == sizeType){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setSizeType:_sizeType];
    _sizeType = sizeType;
    
    [self updateSize];
    
}

- (BOOL)enableLargeVertical{
    if(_sizeType == IUTweetButtonSizeTypeLarge){
        return NO;
    }

    return YES;
}

- (void)updateSize{
    NSSize currentSize;
    if(_sizeType == IUTweetButtonSizeTypeMeidum){
        switch (_countType) {
            case IUTweetButtonCountTypeVertical:
                currentSize = NSMakeSize(56, 62);
                break;
            case IUTweetButtonCountTypeHorizontal:
                currentSize = NSMakeSize(107, 20);
                break;
            case IUTweetButtonCountTypeNone:
                currentSize = NSMakeSize(56, 20);
            default:
                break;
        }
        
    }
    else if(_sizeType == IUTweetButtonSizeTypeLarge){
        switch (_countType) {
            case IUTweetButtonCountTypeVertical:
                currentSize = NSZeroSize;
                break;
            case IUTweetButtonCountTypeHorizontal:
                currentSize = NSMakeSize(138, 28);
                break;
            case IUTweetButtonCountTypeNone:
                currentSize = NSMakeSize(76, 28);
            default:
                break;
        }
    }
    
    [self.css setValue:@(currentSize.height) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(currentSize.width) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];

    [self updateCSS];
    
}

- (BOOL)canChangeWidthByUserInput{
    return NO;
}
- (BOOL)canChangeHeightByUserInput{
    return NO;
}



@end
