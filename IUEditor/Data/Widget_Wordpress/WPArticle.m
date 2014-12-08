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

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_wparticle"];
}

+ (NSString *)widgetType{
    return kIUWidgetTypeWordpress;
}


#pragma mark - initialize

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        _enableTitle = [aDecoder decodeBoolForKey:@"enableTitle"];
        _enableBody = [aDecoder decodeBoolForKey:@"enableBody"];
        _enableDate = [aDecoder decodeBoolForKey:@"enableDate"];
        _enableComment = [aDecoder decodeBoolForKey:@"enableComment"];
        [self.undoManager enableUndoRegistration];
    }
    
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeBool:_enableTitle forKey:@"enableTitle"];
    [aCoder encodeBool:_enableBody forKey:@"enableBody"];
    [aCoder encodeBool:_enableDate forKey:@"enableDate"];
    [aCoder encodeBool:_enableComment forKey:@"enableComment"];
}


- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        self.defaultPositionStorage.position = @(IUPositionTypeRelative);
        
        self.defaultStyleStorage.height = nil;
        self.defaultStyleStorage.bgColor = nil;
        
        [self.defaultStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
        
        [self setEnableTitle:YES];
        [self setEnableDate:YES];
        [self setEnableBody:YES];
        [self setEnableComment:YES];
        [self setEnableCommentForm:YES];
        
        [self.undoManager enableUndoRegistration];
    }
    
    return self;
}

#pragma mark - set property

- (void)setEnableTitle:(BOOL)enableTitle{
    _enableTitle = enableTitle;
    if (enableTitle) {

        WPArticleTitle *title = [[WPArticleTitle alloc] initWithPreset];
        title.htmlID = [self.identifierManager createIdentifierWithPrefix:[title className]];
        title.name = title.htmlID;

        [self addIU:title error:nil];
        if (self.isConnectedWithEditor) {
            [self.identifierManager commit];
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
        WPArticleDate *date = [[WPArticleDate alloc] initWithPreset];
        date.htmlID = [self.identifierManager createIdentifierWithPrefix:[date className]];
        date.name = date.htmlID;
        [self addIU:date error:nil];
        if (self.isConnectedWithEditor) {
            [self.identifierManager commit];
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
        WPCommentFormCollection *formCollection = [[WPCommentFormCollection alloc] initWithPreset];
        formCollection.htmlID = [self.identifierManager createIdentifierWithPrefix:[formCollection className]];
        formCollection.name = formCollection.htmlID;

        [self addIU:formCollection error:nil];
        if (self.isConnectedWithEditor) {
            [self.identifierManager commit];
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
        WPArticleBody *body = [[WPArticleBody alloc] initWithPreset];
        body.htmlID = [self.identifierManager createIdentifierWithPrefix:[body className]];
        body.name = body.htmlID;

        [self addIU:body error:nil];
        if (self.isConnectedWithEditor) {
            [self.identifierManager commit];
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
        WPCommentCollection *comment = [[WPCommentCollection alloc] initWithPreset];
        comment.htmlID = [self.identifierManager createIdentifierWithPrefix:[comment className]];
        comment.name = comment.htmlID;

        [self addIU:comment error:nil];
        if (self.isConnectedWithEditor) {
            [self.identifierManager commit];
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

#pragma mark - should XXX

- (BOOL)canChangeWidthByUserInput{
    return NO;
}

- (BOOL)canChangeXByUserInput{
    return NO;
}

- (BOOL)canMoveToOtherParent{
    return NO;
}

- (BOOL)canRemoveIUByUserInput{
    return NO;
}



@end
