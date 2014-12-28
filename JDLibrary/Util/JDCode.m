//
//  JDCode.m
//  IUEditor
//
//  Created by jd on 5/16/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "JDCode.h"
#import "NSString+JDExtension.h"
#include <stdarg.h>

@implementation JDCode{
    NSMutableString *string;
    NSInteger  indentLevel;
    NSString *whiteSpace;
}

+ (id)code{
    return [[JDCode alloc] init];
}

- (void)increaseIndentLevelForEdit{
    indentLevel ++;
    whiteSpace = [@" " stringByPaddingToLength:indentLevel*2 withString:@" " startingAtIndex:0];
}
- (void)decreaseIndentLevelForEdit{
    indentLevel --;
    NSAssert(indentLevel >= 0, @"indent");
    whiteSpace = [@" " stringByPaddingToLength:indentLevel*2 withString:@" " startingAtIndex:0];
}

- (void)addCodeLine:(NSString*)newCode{
    if (newCode) {
        [string appendString:whiteSpace];
        [string appendString:newCode];
        [self addNewLine];
    }
}

- (void)addNewLine{
    [string appendString:whiteSpace];
    [string appendString:@"\n"];
}

- (void)addCodeWithIndent:(JDCode*)code{
    [code pushIndent:(indentLevel+1) prependIndent:YES];
    [string appendString:code.string];
}

- (void)addCode:(JDCode*)code{
    [code pushIndent:indentLevel prependIndent:YES];
    [string appendString:code.string];
}
- (void)addString:(NSString *)aString{
    [string appendString:whiteSpace];
    [string appendString:aString];
}

- (void)setCodeString:(NSString *)aString{
    string = [NSMutableString string];
    [self addString:aString];
}

- (void)addCodeWithFormat:(NSString *)format, ...{
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    [string appendString:whiteSpace];
    [string appendString:str];
}


-(void)addCodeLineWithFormat:(NSString *)format, ...{
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self addCodeLine:str];
}

-(NSString*)string{
    return [string copy];
}

- (NSData *)UTF8Data {
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSUInteger)length{
    return string.length;
}

- (void)pushIndent:(NSUInteger)indentspace prependIndent:(BOOL)prepend{
    if(string.length <1){
        return;
    }
    
    NSString *aWhiteSpace = [@" " stringByPaddingToLength:indentspace withString:@" " startingAtIndex:0];
    
    if (prepend) {
        [string insertString:aWhiteSpace atIndex:0];
    }
    
    
    NSString *aWhiteStringAndNewLine = [@"\n" stringByAppendingString:aWhiteSpace];
    [string replaceOccurrencesOfString:@"\n" withString:aWhiteStringAndNewLine options:0 range:NSMakeRange(0, string.length-1)];
    
}

- (id)initWithCodeString:(NSString*)codeString{
    self = [super init];
    string = [codeString mutableCopy];
    whiteSpace = [NSString string];
    return self;
}

- (id)initWithMainBundleFileName:(NSString *)bundleFileName {
    self = [super init];
    NSURL *url = [[NSBundle mainBundle] URLForResource:[bundleFileName stringByDeletingPathExtension] withExtension:[bundleFileName pathExtension]];
    string = [NSMutableString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    whiteSpace = [NSString string];
    return self;
}

- (id)init{
    self = [super init];
    string = [NSMutableString string];
    whiteSpace = [NSString string];
    return self;
}


- (void)replaceCodeString:(NSString*)codeString toCode:(JDCode*)replacementCode{
    //get indent of codeString
    NSRange range = [string rangeOfString:codeString];
    
    NSUInteger space = 0;
    for (NSUInteger i = range.location-1; i > 0; i-- ) {
        unichar c = [string characterAtIndex:i];
        if (c == '\n') {
            break;
        }
        space ++;
    }
    
    [replacementCode pushIndent:space prependIndent:NO];
    [string replaceOccurrencesOfString:codeString withString:replacementCode.string options:0 range:NSMakeRange(0, string.length)];
}

- (void)removeBlock:(NSString *)blockIdentifier{
    NSString *startString = [NSString stringWithFormat:@"<!-- %@ Start -->", blockIdentifier];
    NSString *endString = [NSString stringWithFormat:@"<!-- %@ End -->", blockIdentifier];

    NSRange removeStart =[string rangeOfString:startString];
    NSRange removeEnd =[string rangeOfString:endString];
    NSRange removeRange = NSMakeRange(removeStart.location, removeEnd.location+removeEnd.length-removeStart.location);
    [string deleteCharactersInRange:removeRange];
}

- (void)addJSBlockFromString:(NSString *)aString WithIdentifier:(NSString *)blockIdentifier{
    NSString *startString = [NSString stringWithFormat:@"/*INIT_%@_REPLACEMENT_START*/", blockIdentifier];
    NSString *endString = [NSString stringWithFormat:@"/*INIT_%@_REPLACEMENT_END*/", blockIdentifier];
    
    NSRange start =[aString rangeOfString:startString];
    NSRange end =[aString rangeOfString:endString];
    NSRange addRange = NSMakeRange(start.location+startString.length, end.location - start.location - startString.length);
    NSString *findBlock = [aString substringWithRange:addRange];
    
    [string appendString:findBlock];
}

- (void)replaceCodeString:(NSString *)code toCodeString:(NSString*)replacementString{
    [string replaceOccurrencesOfString:code withString:replacementString options:0 range:NSMakeRange(0, string.length)];
}

- (void)wrapTextWithStartString:(NSString*)startString endString:(NSString*)endString{
    [string insertString:startString atIndex:0];
    [string appendString:endString];
}

- (void)wrapChildTextWithStartString:(NSString*)startString endString:(NSString*)endString{
    NSRange startTagRange = [string rangeOfString:@">"];
    NSInteger startIndex = startTagRange.location + startTagRange.length;
    [string insertString:startString atIndex:startIndex];
    
    NSRange endTagRange = [string rangeOfString:@"<" options:NSBackwardsSearch];
    NSInteger endIndex = endTagRange.location;
    [string insertString:endString atIndex:endIndex];
}

@end
