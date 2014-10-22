//
//  IUEvent.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 25..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JavascriptReservedKeywords @[@"break",@"extends",@"switch",@"case",@"finally",@"this",@"class",@"for",@"throw",@"catch"\
@"function",@"try",@"const",@"if",@"typeof",@"continue",@"import",@"var",@"debugger",@"in",@"void",@"default",@"instanceof",@"while"\
@"delete",@"let",@"with",@"do",@"new",@"yield",@"else",@"return",@"export",@"super",@"enum",@"await",@"implements",@"static"\
@"public",@"package",@"interface",@"protected",@"private",@"abstract",@"float",@"short",@"boolean",@"goto",@"synchronized",@"byte",\
@"int",@"transient",@"char",@"long",@"volatile",@"double",@"native",@"final"]

#define JqueryReservedKeywords @[@"break",@"case",@"catch",@"class",@"const",@"continue",@"debugger",@"default",@"delete"\
@"do",@"else",@"enum",@"export",@"extends",@"false",@"finally",@"for",@"function",@"if",@"implements",@"import",@"in"\
@"instanceof",@"interface",@"let",@"new",@"null",@"package",@"private",@"protected",@"public",@"return",@"static",@"super"\
@"switch",@"this",@"throw",@"true",@"try",@"typeof",@"var",@"void",@"while",@"with",@"yield"]

typedef enum{
    IUEventActionTypeClick,
    IUEventActionTypeHover,
    
}IUEventActionType;

typedef enum{
    IUEventVisibleTypeBlind,
    IUEventVisibleTypeSlide,
    IUEventVisibleTypeFold,
    IUEventVisibleTypeBounce,
    IUEventVisibleTypeClip,
    IUEventVisibleTypeDrop,
    IUEventVisibleTypeExplode,
    IUEventVisibleTypeHide,
    IUEventVisibleTypePuff,
    IUEventVisibleTypePulsate,
    IUEventVisibleTypeScale,
    IUEventVisibleTypeShake,
    IUEventVisibleTypeSize,
    IUEventVisibleTypeHighlight,
}IUEventVisibleType;

@interface IUEvent : NSObject <NSCopying>

//trigger
@property (nonatomic) NSString *variable;
@property (nonatomic) NSInteger maxValue, initialValue;
@property (nonatomic) IUEventActionType actionType;

//receiver
@property (nonatomic) BOOL  enableVisible;
@property NSString *eqVisibleVariable;
@property (nonatomic) NSString *eqVisible;
@property (nonatomic) NSInteger eqVisibleDuration;
@property (nonatomic) IUEventVisibleType directionType;

@property (nonatomic) BOOL enableFrame;
@property NSString *eqFrameVariable;
@property (nonatomic) NSString *eqFrame;
@property (nonatomic) NSInteger eqFrameDuration;
@property (nonatomic) CGFloat   eqFrameWidth, eqFrameHeight;

+ (NSArray *)visibleTypeArray;

@end
