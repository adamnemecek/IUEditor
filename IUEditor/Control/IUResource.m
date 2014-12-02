//
//  IUResource.m
//  IUEditor
//
//  Created by JD on 4/6/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUResource.h"
#import "JDMutableArrayDict.h"

@interface IUResourceRootItem()
- (void)updateImageResourceItem;
- (void)updateVideoResourceItem;
@end


@interface IUResourceFileItem()
- (void)setParent:(IUResourceGroupItem *)parent;
- (void)setName:(NSString *)name;
@end

@implementation IUResourceFileItem {
    __weak IUResourceGroupItem *_parent;
    NSString *_name;
}

- (NSString *)description{
    return [[super description] stringByAppendingString:self.name];
}

- (void)setParent:(IUResourceGroupItem *)parent{
    _parent = parent;
}

- (void)setName:(NSString *)name {
    _name = [name copy];
}

- (IUResourceGroupItem *)parent{
    return _parent;
}

- (NSString *)name {
    return _name;
}
- (NSString*)absolutePath {
    return [_parent.absolutePath stringByAppendingPathComponent:self.name];
}
- (NSString*)relativePath {
    return [_parent.relativePath stringByAppendingPathComponent:self.name];
}

-(IUResourceType)type{
    NSString *pathExtension = [[_name pathExtension] lowercaseString];
    if ([pathExtension isEqualToString:@"js"]) {
        return IUResourceTypeJS;
    }
    if ([pathExtension isEqualToString:@"css"]) {
        return IUResourceTypeCSS;
    }
    if ([JDFileUtil isMovieFileExtension:pathExtension]) {
        return IUResourceTypeVideo;
    }
    if ([JDFileUtil isImageFileExtension:pathExtension]){
        return IUResourceTypeImage;
    }
    return IUResourceTypeNone;
}

@end


@implementation IUResourceGroupItem {
    NSMutableArray *_children;
}

- (id)init {
    self = [super init];
    _children = [[NSMutableArray alloc] init];
    return self;
}

- (NSArray*)imageResourceItems {
    NSMutableArray *arr = [NSMutableArray array];
    for (IUResourceFileItem *item in _children) {
        if ([item isKindOfClass:[IUResourceGroupItem class]]) {
            [arr addObjectsFromArray:((IUResourceGroupItem *)item).imageResourceItems];
        }
        else if (item.type == IUResourceTypeImage) {
            [arr addObject:item];
        }
    }
    return [arr copy];
}

- (NSArray*)videoResourceItems {
    NSMutableArray *arr = [NSMutableArray array];
    for (IUResourceFileItem *item in _children) {
        if ([item isKindOfClass:[IUResourceGroupItem class]]) {
            [arr addObjectsFromArray:((IUResourceGroupItem *)item).videoResourceItems];
        }
        else if (item.type == IUResourceTypeVideo) {
            [arr addObject:item];
        }
    }
    return [arr copy];
}

- (void)refresh:(BOOL)recursive {
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.absolutePath]
                                    includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                       options:NSDirectoryEnumerationSkipsHiddenFiles
                                                         error:nil];
    NSMutableArray *childrenTemp = [_children mutableCopy];
    NSArray *currentChildrenNames = [_children valueForKey:@"name"];
    
    [files enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
        NSString *name = [url lastPathComponent];

        for (IUResourceFileItem *item in _children) {
            if ([item.name isEqualToString:name]) {
                [childrenTemp removeObject:item];
                break;
            }
        }
        
        if ([currentChildrenNames containsObject:name] == NO) {
            NSNumber *isDirectory;
            BOOL success = [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
            if (success && [isDirectory boolValue]) {
                IUResourceGroupItem *item = [[IUResourceGroupItem alloc] init];
                item.name = name;
                item.parent = self;
                [_children addObject:item];
                if (recursive) {
                    [item refresh:YES];
                }
            } else {
                IUResourceFileItem *item = [[IUResourceFileItem alloc] init];
                item.name = name;
                item.parent = self;
                [_children addObject:item];
            }
        }
    }];
    /* 남은 파일을 삭제 */
    [childrenTemp enumerateObjectsUsingBlock:^(IUResourceFileItem *item, NSUInteger idx, BOOL *stop) {
        [[NSFileManager defaultManager] removeItemAtPath:item.absolutePath error:nil];
        [_children removeObject:item];
    }];
}

- (IUResourceFileItem *)resourceFileItemForName:(NSString *)name{
    for(IUResourceFileItem *item in [self allChildren]){
        if([item.name isEqualToString:name]){
            return item;
        }
    }
    
    return nil;
}

- (NSArray *)allChildren{
    NSMutableArray *array = [NSMutableArray array];
    for(IUResourceFileItem *item in _children){
        if([item isMemberOfClass:[IUResourceGroupItem class]]){
            [array addObjectsFromArray:[(IUResourceGroupItem *)item allChildren]];
        }
        else{
            [array addObject:item];
        }
    }
    
    return [array copy];
}

- (NSArray *)children{
    return [_children copy];
}
@end


/**
 IUResource is root file item in resource field
 */
@implementation IUResourceRootItem {
    NSString *_absolutePath;
}

- (void)sendKVONoti_startUpdateImageResourceItem {
    [self willChangeValueForKey:@"imageResourceItems"];
    
}

- (void)sendKVONoti_endUpdateImageResourceItem {
    [self didChangeValueForKey:@"imageResourceItems"];
}

- (void)sendKVONoti_startUpdateVideoResourceItem {
    [self willChangeValueForKey:@"imageResourceItems"];
    
}

- (void)sendKVONoti_endUpdateVideoResourceItem {
    [self didChangeValueForKey:@"imageResourceItems"];
}

- (void)loadFromPath:(NSString *)path{
    _absolutePath = [path copy];
    [self refresh:YES];
}

- (NSString *)absolutePath{
    return _absolutePath;
}

- (NSString *)relativePath{
    return @"/";
}
- (void)updateImageResourceItem{
    
}
- (void)updateVideoResourceItem{
    
}


@end
