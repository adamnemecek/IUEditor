//
//  IUMQData.m
//  IUEditor
//
//  Created by seungmi on 2014. 10. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUMQData.h"
#import "IUDataStorage.h"
#import "IUPropertyStorage.h"

@interface IUMQData ()
@property NSMutableDictionary *mqDictWithViewPort;
@property (readwrite) NSMutableDictionary *effectiveTagDictionaryForEditWidth;
@end

@implementation IUMQData{
    /* for version control; used in 'convertToStorageManager' */
    IUPropertyStorage *convertPropertyStorage;
    NSDictionary *convertTagDict;
}


-(id)init{
    self = [super init];
    _mqDictWithViewPort = [[NSMutableDictionary alloc] init];
    _effectiveTagDictionaryForEditWidth = [NSMutableDictionary dictionary];
    
    self.editViewPort = IUCSSDefaultViewPort;
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_mqDictWithViewPort forKey:@"mqDictWithViewPort"];
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [self encodeWithCoder:(NSCoder*)aCoder];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    
    _mqDictWithViewPort = [aDecoder decodeObjectForKey:@"mqDictWithViewPort"];
    self.editViewPort = IUCSSDefaultViewPort;
    _effectiveTagDictionaryForEditWidth = [NSMutableDictionary dictionary];
    
    [self updateEffectiveTagDictionary];
    
    return self;
}


- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super init];
    
    _mqDictWithViewPort = [aDecoder decodeObjectForKey:@"mqDictWithViewPort"];
    self.editViewPort = IUCSSDefaultViewPort;
    _effectiveTagDictionaryForEditWidth = [NSMutableDictionary dictionary];
    [self updateEffectiveTagDictionary];
    
    return self;
}


- (id)copyWithZone:(NSZone *)zone{
    IUMQData *mqData = [[[self class] allocWithZone:zone] init];
    mqData.mqDictWithViewPort = [self.mqDictWithViewPort deepCopy];
    mqData.editViewPort = self.editViewPort;
    mqData.maxViewPort = self.maxViewPort;
    return mqData;
}


#pragma mark -

-(NSArray*)allViewports{
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
    return [[self.mqDictWithViewPort allKeys] sortedArrayUsingDescriptors:@[sortOrder]];
}

-(NSDictionary *)dictionaryForTag:(IUMQDataTag)tag{
    NSMutableDictionary *tagDict = [NSMutableDictionary dictionary];
    for(NSString *widthKey in _mqDictWithViewPort){
        NSDictionary *dictForWidth = _mqDictWithViewPort[widthKey];
        id value = dictForWidth[tag];
        if(value){
            tagDict[widthKey] = value;
        }
    }
    
    return tagDict;
}

#pragma mark -value
-(void)updateEffectiveTagDictionary{
    
    //REVIEW: style sheet는 default만 적용됨
    if(_mqDictWithViewPort[@(IUCSSDefaultViewPort)]){
        [_effectiveTagDictionaryForEditWidth setDictionary:_mqDictWithViewPort[@(IUCSSDefaultViewPort)]];
    }
    else{
        [_effectiveTagDictionaryForEditWidth removeAllObjects];
    }
    
    if(_editViewPort != IUCSSDefaultViewPort && _mqDictWithViewPort[@(_editViewPort)]){
        [_effectiveTagDictionaryForEditWidth addEntriesFromDictionary:_mqDictWithViewPort[@(_editViewPort)]];
        
    }
}


-(void)setValue:(id)value forKeyPath:(NSString *)keyPath{
    if ([keyPath containsString:@"effectiveTagDictionary."]) {
        NSString *tag = [keyPath substringFromIndex:23];
        [self setValue:value forTag:tag forViewport:_editViewPort];
        return;
    }
    else {
        [super setValue:value forKey:keyPath];
        return;
    }
}

-(void)setValue:(id)value forTag:(IUMQDataTag)tag{
    [self setValue:value forTag:tag forViewport:_editViewPort];
}
-(void)setValue:(id)value forTag:(IUMQDataTag)tag forViewport:(NSInteger)width{
    NSMutableDictionary *cssDict = _mqDictWithViewPort[Integer2Str(width)];
    
    id currentValue = [cssDict objectForKey:tag];
    if(currentValue == nil ||  [currentValue isNotEqualTo:value]){
        
        [[[self.delegate undoManager] prepareWithInvocationTarget:self] setValue:currentValue forTag:tag forViewport:width];
        
        
        if (cssDict == nil) {
            cssDict = [NSMutableDictionary dictionary];
            /* save as string : to change json object, key should be nsstring format */
            [_mqDictWithViewPort setObject:cssDict forKey:Integer2Str(width)];
        }
        
        if (value == nil) {
            [cssDict removeObjectForKey:tag];
            if(width == _editViewPort){
                [_effectiveTagDictionaryForEditWidth removeObjectForKey:tag];
            }
        }
        else {
            cssDict[tag] = value;
            if(width == _editViewPort){
                [_effectiveTagDictionaryForEditWidth setObject:value forKey:tag];
            }
        }
    }
    
    if([self isNeededToUpdateForTag:tag]){
        [self.delegate updateHTML];
    }
        
}

- (BOOL)isNeededToUpdateForTag:(IUMQDataTag)tag{
    if([tag isEqualToString:IUMQDataTagInnerHTML]){
        return NO;
    }
    else{
        return YES;
    }
}



-(id)valueForKeyPath:(NSString *)keyPath{
    if ([keyPath containsString:@"effectiveTagDictionary."]) {
        NSString *tag = [keyPath substringFromIndex:23];
        return [_effectiveTagDictionaryForEditWidth objectForKey:tag];
    }
    else {
        return [super valueForKey:keyPath];
    }
}


-(id)effectiveValueForTag:(IUMQDataTag)tag forViewport:(NSInteger)width{
    if( _mqDictWithViewPort[Integer2Str(width)]){
        id value = [_mqDictWithViewPort[Integer2Str(width)] objectForKey:tag];
        if(value){
            return value;
        }
    }
    
    id value = [_mqDictWithViewPort[Integer2Str(IUCSSDefaultViewPort)] objectForKey:tag];
    return value;

}

-(id)valueForTag:(IUMQDataTag)tag forViewport:(NSInteger)width{
    if( _mqDictWithViewPort[Integer2Str(width)]){
        id value = [_mqDictWithViewPort[Integer2Str(width)] objectForKey:tag];
        if(value){
            return value;
        }
    }
    
    return nil;
}


-(void)eradicateTag:(IUMQDataTag)tag{
    for (id key in _mqDictWithViewPort) {
        NSMutableDictionary *cssDict = _mqDictWithViewPort[key];
        [cssDict removeObjectForKey:tag];
    }
    
    [self updateEffectiveTagDictionary];
    if([self isNeededToUpdateForTag:tag]){
        [self.delegate updateHTML];
    }
}

-(void)removeTagDictionaryForViewport:(NSInteger)width{
    if([_mqDictWithViewPort objectForKey:Integer2Str(width)]){
        [_mqDictWithViewPort removeObjectForKey:Integer2Str(width)];
    }
}
-(NSDictionary*)tagDictionaryForViewport:(NSInteger)width{
    return _mqDictWithViewPort[Integer2Str(width)];
}

#pragma mark - conversion
/*
 static NSString * IUMQDataTagInnerHTML = @"innerHTML";
 static NSString * IUMQDataTagCollectionCount = @"collectionCount";
 */

- (void)convertToPropertyStorageManager_setTag:(NSString*)tag  toStorageWithkey:(NSString*)key{
    if (convertTagDict[tag]) {
        [convertPropertyStorage setPropertyValue:convertTagDict[key] fromMQDataforKey:key];
    }
}


- (IUDataStorageManager *)convertToPropertyStorageManager{
    IUDataStorageManager *cssStorageManager = [[IUDataStorageManager alloc] initWithStorageClassName:[IUPropertyStorage class].className];
    
    for (NSNumber *number in self.allViewports) {
        cssStorageManager.currentViewPort = [number integerValue];
        convertPropertyStorage = (IUPropertyStorage *)cssStorageManager.currentStorage;
        convertTagDict = [self tagDictionaryForViewport:[number integerValue]];
        
        if(convertTagDict[IUMQDataTagInnerHTML]){
            [self convertToPropertyStorageManager_setTag:IUMQDataTagInnerHTML toStorageWithkey:@"innerHTML"];
        }
        
        if(convertTagDict[IUMQDataTagCollectionCount]){
            [self convertToPropertyStorageManager_setTag:IUMQDataTagCollectionCount toStorageWithkey:@"collectionCount"];

        }
    }
    
    return cssStorageManager;
}


@end
