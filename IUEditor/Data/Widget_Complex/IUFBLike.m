//
//  IUFBLike.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 23..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUFBLike.h"
@interface IUFBLike()

@property NSString *fbSource;

@end

@implementation IUFBLike{
}

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_fblike"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_fblike"];
}

+ (NSString *)widgetType{
    return kIUWidgetTypeSecondary;
}

#pragma mark - Initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [[self undoManager] disableUndoRegistration];

        self.innerHTML = @"";
        _fbSource = @"<iframe src=\"//www.facebook.com/plugins/like.php?href=__FB_LINK_ADDRESS__+&amp;width&amp;layout=standard&amp;action=like&amp;show_faces=__SHOW_FACE__&amp;share=true&amp;colorscheme=__COLOR_SCHEME__&amp;\" scrolling=\"no\" frameborder=\"0\" style=\"border:none; overflow:hidden; height:__HEIGHT__px\" allowTransparency=\"true\"></iframe>";
        _showFriendsFace = YES;
        _colorscheme = IUFBLikeColorLight;
        
        self.defaultStyleStorage.height = @(80);
        self.defaultStyleStorage.width = @(320);
        self.defaultStyleStorage.bgColor = nil;
        
        [[self undoManager] enableUndoRegistration];

    }
    return self;
}

- (void)connectWithEditor{
    [super connectWithEditor];
    [self addObserver:self forKeyPaths:@[@"showFriendsFace", @"likePage", @"colorscheme"] options:0 context:@"IUFBSource"];
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[[IUFBLike class] properties]];
        _fbSource = @"<iframe src=\"//www.facebook.com/plugins/like.php?href=__FB_LINK_ADDRESS__+&amp;width&amp;layout=standard&amp;action=like&amp;show_faces=__SHOW_FACE__&amp;share=true&amp;colorscheme=__COLOR_SCHEME__&amp;\" scrolling=\"no\" frameborder=\"0\" style=\"border:none; overflow:hidden; height:__HEIGHT__px\" allowTransparency=\"true\"></iframe>";
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[IUFBLike class] properties]];
}

- (id)copyWithZone:(NSZone *)zone{
    IUFBLike *iu = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    
    iu.likePage = [_likePage copy];
    iu.showFriendsFace = _showFriendsFace;
    
    [self.undoManager enableUndoRegistration];
    return iu;
}

-(void) dealloc{
    if(self.isConnectedWithEditor){
        [self removeObserver:self forKeyPaths:@[@"showFriendsFace", @"likePage", @"colorscheme"]];
    }
}

- (void)IUFBSourceContextDidChange:(NSDictionary *)change{
    NSString *showFaces;
    if(self.showFriendsFace){
        [self.currentStyleStorage setHeight:@(80) unit:@(IUFrameUnitPixel)];
        showFaces = @"true";
    }else{
        [self.currentStyleStorage setHeight:@(45) unit:@(IUFrameUnitPixel)];
        showFaces = @"false";
    }
    
    [self updateCSS];
        
    NSString *currentPixel = [[NSString alloc] initWithFormat:@"%.0f", [self.cascadingStyleStorage.height floatValue]];
    
    NSString *source;

    source = [self.fbSource stringByReplacingOccurrencesOfString:@"__HEIGHT__" withString:currentPixel];
    source = [source stringByReplacingOccurrencesOfString:@"__SHOW_FACE__" withString:showFaces];
    
    NSString *pageStr = self.likePage;
    if(self.likePage.length == 0){
        pageStr = @"";
    }
    
    switch (_colorscheme) {
        case IUFBLikeColorLight:
            source = [source stringByReplacingOccurrencesOfString:@"__COLOR_SCHEME__" withString:@"light"];
            break;
        case IUFBLikeColorDark:
            source = [source stringByReplacingOccurrencesOfString:@"__COLOR_SCHEME__" withString:@"dark"];
        default:
            break;
    }
    
    source = [source stringByReplacingOccurrencesOfString:@"__FB_LINK_ADDRESS__" withString:pageStr];
    
    self.innerHTML = source;
}

- (void)setShowFriendsFace:(BOOL)showFriendsFace{
    if(_showFriendsFace == showFriendsFace){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setShowFriendsFace:_showFriendsFace];
    _showFriendsFace = showFriendsFace;
}

- (void)setColorscheme:(IUFBLikeColor)colorscheme{
    if(_colorscheme == colorscheme){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setColorscheme:_colorscheme];
    _colorscheme = colorscheme;
}

- (void)setLikePage:(NSString *)likePage{
    if([likePage isEqualToString:_likePage]){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setLikePage:_likePage];
    _likePage = likePage;
}
- (BOOL)canChangeWidthByUserInput{
    return NO;
}
- (BOOL)canChangeHeightByUserInput{
    return NO;
}

@end
