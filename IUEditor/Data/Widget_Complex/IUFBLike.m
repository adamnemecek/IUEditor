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

-(id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [[self undoManager] disableUndoRegistration];

        self.innerHTML = @"";
        _fbSource = @"<iframe src=\"//www.facebook.com/plugins/like.php?href=__FB_LINK_ADDRESS__+&amp;width&amp;layout=standard&amp;action=like&amp;show_faces=__SHOW_FACE__&amp;share=true&amp;colorscheme=__COLOR_SCHEME__&amp;\" scrolling=\"no\" frameborder=\"0\" style=\"border:none; overflow:hidden; height:__HEIGHT__px\" allowTransparency=\"true\"></iframe>";
        _showFriendsFace = YES;
        _colorscheme = IUFBLikeColorLight;
        [self.css setValue:@(80) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(320) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        [self.css setValue:nil forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
        
        [[self undoManager] enableUndoRegistration];

    }
    return self;
}

- (void)connectWithEditor{
    [super connectWithEditor];
    [self addObserver:self forKeyPaths:@[@"showFriendsFace", @"likePage", @"colorscheme"] options:0 context:@"IUFBSource"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self =  [super initWithCoder:aDecoder];
    if(self){
        [[self undoManager] disableUndoRegistration];

        [aDecoder decodeToObject:self withProperties:[[IUFBLike class] properties]];
        _fbSource = @"<iframe src=\"//www.facebook.com/plugins/like.php?href=__FB_LINK_ADDRESS__+&amp;width&amp;layout=standard&amp;action=like&amp;show_faces=__SHOW_FACE__&amp;share=true&amp;colorscheme=__COLOR_SCHEME__&amp;\" scrolling=\"no\" frameborder=\"0\" style=\"border:none; overflow:hidden; height:__HEIGHT__px\" allowTransparency=\"true\"></iframe>";
        [[self undoManager] enableUndoRegistration];

    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[IUFBLike class] properties]];
    
}

- (id)copyWithZone:(NSZone *)zone{
    IUFBLike *iu = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    [_canvasVC disableUpdateAll:self];
    
    iu.likePage = [_likePage copy];
    iu.showFriendsFace = _showFriendsFace;
    
    [_canvasVC enableUpdateAll:self];
    [self.undoManager enableUndoRegistration];
    return iu;
}

-(void) dealloc{
    [self removeObserver:self forKeyPaths:@[@"showFriendsFace", @"likePage", @"colorscheme"]];
}

- (void)IUFBSourceContextDidChange:(NSDictionary *)change{
    NSString *showFaces;
    if(self.showFriendsFace){
        [self.css setValue:@(80) forTag:IUCSSTagPixelHeight forViewport:self.css.editViewPort];
        showFaces = @"true";
    }else{
        [self.css setValue:@(45) forTag:IUCSSTagPixelHeight forViewport:self.css.editViewPort];
        showFaces = @"false";
    }
    
    [self updateCSS];
        
    NSString *currentPixel = [[NSString alloc] initWithFormat:@"%.0f", [self.css.effectiveTagDictionary[IUCSSTagPixelHeight] floatValue]];
    
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
