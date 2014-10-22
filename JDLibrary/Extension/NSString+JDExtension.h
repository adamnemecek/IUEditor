//
//  NSString+JDExtension.h
//  IUEditor
//
//  Created by JD on 3/19/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JDExtension)
+ (NSString *)randomStringWithLength:(int)len;
+ (NSString *)stringWithValueMarker:(id)marker;

- (NSString*)JSEscape;
- (BOOL)isHTTPURL;
- (BOOL)isDjangoVariable;
- (NSString*)CSSURLString;
- (NSString *)faviconType;

- (NSString*)lastLine;

- (BOOL)isStartWithPrefix:(NSString *)prefix;


- (NSString*)changeFileNameWithExtensionUntouched:(NSString*)fileName;
- (NSString*)stringByAppendFileNameWithExtensionUntouched:(NSString*)appendingString;

- (NSString*)stringByAppendingPathComponents:(NSArray*)paths;
- (NSString*)stringByPathDiff:(NSString*)path;


- (NSString*) relativePathFrom: (NSString*) endPath;
- (BOOL) containsString:(NSString*)string;

- (NSString*)nameWithoutExtensionAsFile;
- (NSString*)substringToChar:(unichar)charecter;
- (NSString*)substringFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;

- (NSString*)stringByChangeExtension:(NSString*)extension;
- (NSString*)stringByIndent:(NSUInteger)indent prependIndent:(BOOL)prependIndent;
- (NSString*)stringByAddingTab;

- (BOOL)isValidEmail;
#define RGXEmailPattern @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"

- (NSArray*) RGXMatchAllStringsWithPatten:(NSString*)patten;
- (NSString*) stringByTrim;
- (NSRange)fullRange;

@end

@interface NSMutableString(JDExtension)
- (void)appendNewline;
- (void)appendTabAndString:(NSString *)aString;
- (void)appendString:(NSString*)string multipleTimes:(NSUInteger)multipleTimes;
- (void)appendStringIfNotNil:(NSString*)string;
- (void)trim;
- (void)trimWithCharacterInString:(NSString*)string;
@end