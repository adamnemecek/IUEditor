//
//  IUResourceNode.m
//  IUEditor
//
//  Created by JD on 3/28/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUResourceFile.h"
#import "IUResourceGroup.h"
#import "IUProject.h"

@implementation IUResourceFile{
    NSString *_name;
    NSImage *_image;
}



-(id)initWithName:(NSString*)name{
    if (self) {
        _name = name;
    }
    return self;
}


- (id)copyWithZone:(NSZone *)zone{
    [self.undoManager disableUndoRegistration];
    
    IUResourceFile *file = [[IUResourceFile allocWithZone:zone] initWithName:_name];
    file.originalFilePath = self.absolutePath;
    [file setParent:self.parent];
    
    [self.undoManager enableUndoRegistration];
    return file;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    
    _name = [aDecoder decodeObjectForKey:@"_name"];
    _parent = [aDecoder decodeObjectForKey:@"_parent"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_name forKey:@"_name"];
    [aCoder encodeObject:_parent forKey:@"_parent"];
}

#pragma mark - Undo Manager
- (NSUndoManager *)undoManager{
    return [[[[NSApp mainWindow] windowController] document] undoManager];
}

- (NSArray *)children{
    return nil;
}


-(NSString*)absolutePath{
    if ([self.parent isKindOfClass:[IUProject class]]) {
        return [self.parent.absolutePath stringByAppendingPathComponent:_name];
    }
    NSAssert(self.parent.absolutePath, @"parent path");
    return [self.parent.absolutePath stringByAppendingPathComponent:_name];
}

-(NSString*)relativePath{
    return [self.parent.relativePath stringByAppendingPathComponent:_name];
}

-(NSString*)name{
    return _name;
}

-(NSArray*)childrenFiles{
    return nil;
}
-(NSString*)description{
    return _name;
}

-(NSImage*)image{
    if (_image == nil) {
        NSImage *image;
        NSString *pathExtension = [_name pathExtension];
        if ([JDFileUtil isImageFileExtension:pathExtension]) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:self.absolutePath]) {
                image = [[NSImage alloc] initWithContentsOfFile:self.absolutePath];
            }
            else {
                image = [[NSImage alloc] initWithContentsOfFile:self.originalFilePath];
            }
        }
        if ([JDFileUtil isMovieFileExtension:pathExtension]){
            image = [NSImage imageNamed:@"tool_movie"];
        }
        _image = image;
        return image;
    }
    else {
        return _image;
    }
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
