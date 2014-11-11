//
//  WPContentCollection.m
//  IUEditor
//
//  Created by jw on 7/15/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPArticle.h"
#import "WPArticleTitle.h"
#import "WPArticleDate.h"
#import "WPArticleBody.h"
#import "WPCommentCollection.h"
#import "WPCommentFormCollection.h"

#import "IUIdentifierManager.h"
#import "IUProject.h"

@implementation WPArticle{
}

- (BOOL)canChangeWidthByUserInput{
    return NO;
}

- (BOOL)canChangeXByUserInput{
    return NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self.undoManager disableUndoRegistration];
    
    @try {
        _enableTitle = [aDecoder decodeBoolForKey:@"enableTitle"];
        _enableBody = [aDecoder decodeBoolForKey:@"enableBody"];
        _enableDate = [aDecoder decodeBoolForKey:@"enableDate"];
        _enableComment = [aDecoder decodeBoolForKey:@"enableComment"];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    [self.undoManager enableUndoRegistration];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:_enableTitle forKey:@"enableTitle"];
    [aCoder encodeBool:_enableBody forKey:@"enableBody"];
    [aCoder encodeBool:_enableDate forKey:@"enableDate"];
    [aCoder encodeBool:_enableComment forKey:@"enableComment"];
}

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    [self.undoManager disableUndoRegistration];
    
    self.positionType = IUPositionTypeRelative;
    [self.css eradicateTag:IUCSSTagPixelHeight];
    [self.css eradicateTag:IUCSSTagBGColor];

    [self.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
    [self setEnableTitle:YES];
    [self setEnableDate:YES];
    [self setEnableBody:YES];
    [self setEnableComment:YES];
    [self setEnableCommentForm:YES];
    
    [self.undoManager enableUndoRegistration];
    
    return self;
}

- (void)setEnableTitle:(BOOL)enableTitle{
    _enableTitle = enableTitle;
    if (enableTitle) {
        if (self.isConnectedWithEditor) {
            [self.project.identifierManager resetUnconfirmedIUs];
        }

        WPArticleTitle *title = [[WPArticleTitle alloc] initWithProject:self.project options:nil];
        [self addIU:title error:nil];
        if (self.isConnectedWithEditor) {
            [title confirmIdentifier];
        }
    }
    else {
        for (IUBox *box in self.children) {
            if ([box isKindOfClass:[WPArticleTitle class]]) {
                [self removeIU:box];
            }
        }
    }
}

- (void)setEnableDate:(BOOL)enableDate{
    _enableDate = enableDate;
    if (enableDate) {
        if (self.isConnectedWithEditor) {
            [self.project.identifierManager resetUnconfirmedIUs];
        }
        WPArticleDate *date = [[WPArticleDate alloc] initWithProject:self.project options:nil];
        [self addIU:date error:nil];
        if (self.isConnectedWithEditor) {
            [date confirmIdentifier];
        }
    }
    else {
        for (IUBox *box in self.children) {
            if ([box isKindOfClass:[WPArticleDate class]]) {
                [self removeIU:box];
            }
        }
    }
}

- (void)setEnableCommentForm:(BOOL)enableCommentForm{
    _enableCommentForm = enableCommentForm;
    if (enableCommentForm) {
        if (self.isConnectedWithEditor) {
            [self.project.identifierManager resetUnconfirmedIUs];
        }
        WPCommentFormCollection *formCollection = [[WPCommentFormCollection alloc] initWithProject:self.project options:nil];
        [self addIU:formCollection error:nil];
        if (self.isConnectedWithEditor) {
            [formCollection confirmIdentifier];
        }
    }
    else {
        for (IUBox *box in self.children) {
            if ([box isKindOfClass:[WPCommentFormCollection class]]) {
                [self removeIU:box];
            }
        }
    }
}

- (void)setEnableBody:(BOOL)enableBody{
    _enableBody = enableBody;
    if (enableBody) {
        if (self.isConnectedWithEditor) {
            [self.project.identifierManager resetUnconfirmedIUs];
        }
        WPArticleBody *body = [[WPArticleBody alloc] initWithProject:self.project options:nil];
        [self addIU:body error:nil];
        if (self.isConnectedWithEditor) {
            [self.project.identifierManager confirm];
        }
    }
    else {
        for (IUBox *box in self.children) {
            if ([box isKindOfClass:[WPArticleBody class]]) {
                [self removeIU:box];
            }
        }
    }
}

//TODO: comment
- (void)setEnableComment:(BOOL)enableComment{
    _enableComment = enableComment;
    if (enableComment) {
        if (self.isConnectedWithEditor) {
            [self.project.identifierManager resetUnconfirmedIUs];
        }
        WPCommentCollection *comment = [[WPCommentCollection alloc] initWithProject:self.project options:nil];
        [self addIU:comment error:nil];
        if (self.isConnectedWithEditor) {
            [self.project.identifierManager confirm];
        }
    }
    else {
        for (IUBox *box in self.children) {
            if ([box isKindOfClass:[WPCommentCollection class]]) {
                [self removeIU:box];
            }
        }
    }

    
}

- (BOOL)canMoveToOtherParent{
    return NO;
}

- (BOOL)canRemoveIUByUserInput{
    return NO;
}



@end
