//
//  IUSourceManagerProtocol.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#ifndef IUEditor_IUSourceManagerProtocol_h
#define IUEditor_IUSourceManagerProtocol_h


@protocol IUSourceManagerProtocol

/* working as transaction */
- (void)beginTransaction:(id)sender;
- (void)commitTransaction:(id)sender;


/* update obj */
- (void)setNeedsUpdateHTML:(id)obj;
- (void)setNeedsUpdateCSS:(id)obj;
- (void)setNeedsUpdateCSS:(id)obj withIdentifiers:(NSArray *)identifiers;
- (void)removeIU:(id)obj;

/* call js */
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;
- (id)evaluateWebScript:(NSString *)script;

/* call js - common function */
- (NSInteger)countOfLineWithIdentifier:(NSString *)identifier;
- (NSRect)absolutePixelFrameWithIdentifier:(NSString *)identifier;


/* compile type */
@property NSString *compilerRule;

@end


#endif
