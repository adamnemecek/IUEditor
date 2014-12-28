//
//  JDCode.h
//  IUEditor
//
//  Created by jd on 5/16/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDCode : NSObject

+ (id)code;
- (id)initWithCodeString:(NSString*)codeString;
- (id)initWithMainBundleFileName:(NSString *)bundleFileName;

- (void)increaseIndentLevelForEdit;
- (void)decreaseIndentLevelForEdit;

- (void)addCodeLine:(NSString*)code;
- (void)addCodeLineWithFormat:(NSString*)format, ...;

- (void)addCode:(JDCode*)code;
- (void)addCodeWithIndent:(JDCode*)code;
- (void)addCodeWithFormat:(NSString *)format, ...;
- (void)addNewLine;

- (void)addString:(NSString *)aString;
- (void)setCodeString:(NSString *)aString;
- (NSString*)string;
- (NSData *)UTF8Data;
- (NSUInteger)length;

- (void)pushIndent:(NSUInteger)indentLevel prependIndent:(BOOL)prepend;

- (void)replaceCodeString:(NSString*)code toCode:(JDCode*)code;


- (void)removeBlock:(NSString*)blockIdentifier;

- (void)replaceCodeString:(NSString *)code toCodeString:(NSString*)replacementString;

- (void)wrapTextWithStartString:(NSString*)startString endString:(NSString*)endString;
- (void)wrapChildTextWithStartString:(NSString*)startString endString:(NSString*)endString;

- (void)addJSBlockFromString:(NSString *)aString WithIdentifier:(NSString *)blockIdentifier;

@end