//
//  IUCSSCode.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 7..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUDefinition.h"

typedef enum{
    IUCSSIdentifierTypeInline,
    IUCSSIdentifierTypeNonInline,
}IUCSSIdentifierType;

@interface IUCSSCode : NSObject
- (NSDictionary*)stringTagDictionaryWithIdentifier:(int)viewport;
- (NSDictionary*)stringTagDictionaryWithIdentifierForOutputViewport:(NSInteger)viewport;
- (NSDictionary*)stringTagDictionaryWithIdentifierForTarget:(IUTarget)target viewPort:(int)viewport;

- (NSString *)stringCodeWithMainIdentifieForTarget:(IUTarget)target viewPort:(int)viewport;


- (NSArray*)allViewports;
- (NSArray*)allIdentifiers;

- (NSDictionary*)stringTagDictionaryWithIdentifier_storage:(IUTarget)target viewPort:(NSInteger)viewPort;

- (NSDictionary *)inlineTagDictionyForViewport:(NSInteger)viewport; // css for inline insertion ( for example, main css )
- (NSDictionary *)nonInlineTagDictionaryForViewport:(NSInteger)viewport; // css for non-inline insertion (for example, hover or active )

/*
- (NSArray* )minusInlineTagSelector:(IUCSSCode *)code;
- (NSArray *)minusNonInlineSelector:(IUCSSCode *)code;
 */

/* uses inline code for IUDefaultViewPort and defaultIdentifier */
- (NSString *)mainIdentifier;
@end



@interface IUCSSCode(Generator)

//set current max viewport of project, not iu's max viewport
- (void)setMaxViewPort:(NSInteger)viewport;

- (void)setInsertingTarget:(IUTarget)target;
- (void)setInsertingViewPort:(NSInteger)viewport;
- (NSInteger)insertingViewPort;
- (void)setInsertingIdentifier:(NSString *)identifier;
- (void)setInsertingIdentifier:(NSString *)identifier withType:(IUCSSIdentifierType)type;
- (void)setInsertingIdentifiers:(NSArray *)identifiers;
- (void)setInsertingIdentifiers:(NSArray *)identifiers withType:(IUCSSIdentifierType)type;
- (void)renameIdentifier:(NSString*)fromIdentifier to:(NSString*)toIdentifier;
- (void)setMainIdentifier:(NSString *)identifier;

- (NSString*)valueForTag:(NSString*)tag identifier:(NSString*)identifier largerThanViewport:(NSInteger)viewport target:(IUTarget)target;
- (NSString*)valueForTag:(NSString*)tag identifier:(NSString*)identifier viewport:(NSInteger)viewport target:(IUTarget)target;

/**
 insert css tag to receiver
 */

- (void)insertTag:(NSString*)tag color:(NSColor*)colorValue;
- (void)insertTag:(NSString*)tag string:(NSString*)stringValue;
- (void)insertTag:(NSString*)tag string:(NSString*)stringValue target:(IUTarget)target;
- (void)insertTag:(NSString*)tag number:(NSNumber*)number;
- (void)insertTag:(NSString*)tag number:(NSNumber*)number unit:(IUUnit)unit;
- (void)insertTag:(NSString*)tag number:(NSNumber*)number frameUnit:(NSNumber *)frameUnit;


/*
 remove css tag to receiver
 */
- (void)removeTag:(NSString*)tag identifier:(NSString*)identifier;
- (void)removeTag:(NSString*)tag identifier:(NSString*)identifier viewport:(NSInteger)viewport;

@end