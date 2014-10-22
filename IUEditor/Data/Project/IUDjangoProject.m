//
//  IUDjangoProject.m
//  IUEditor
//
//  Created by jd on 4/25/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUDjangoProject.h"
#import "IUPage.h"
#import "IUBackground.h"
#import "IUClass.h"
#import "IUSheetGroup.h"

@implementation IUDjangoProject

- (id)init{
    self = [super init];
    return self;
}

- (id)initWithCreation:(NSDictionary *)options error:(NSError *__autoreleasing *)error{
    self = [super initWithCreation:options error:error];
    if(self){
        [self.undoManager disableUndoRegistration];
        _port = 8000;
        _managePyPath = @"$IUFileDirectory/manage.py";
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self.undoManager disableUndoRegistration];
    
    _port = [aDecoder decodeIntForKey:@"_port"];
    _managePyPath = [aDecoder decodeObjectForKey:@"_managePyPath"];

    if(_port ==0 ){
        _port = 8000;
    }
    /* version control code */
    //REVIEW : sync with project version
    NSString *projectVersion = [aDecoder decodeObjectForKey:@"IUProjectVersion"];
    if(projectVersion == nil || projectVersion.length ==0){
        
        int IUEditorVersion = [aDecoder decodeIntForKey:@"IUEditorVersion"];
        if (IUEditorVersion < 1) {
            self.buildPath = @"$IUFileDirectory/templates";
            self.buildResourcePath = @"$IUFileDirectory/templates/resource";
        }
    }
    if ([_managePyPath length] == 0) {
        _managePyPath = @"$IUFileDirectory/manage.py";
    }
    
    [self.undoManager enableUndoRegistration];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder{
    [super encodeWithCoder:encoder];
    [encoder encodeInteger:_port forKey:@"_port"];
    [encoder encodeObject:_managePyPath forKey:@"_managePyPath"];
}

- (BOOL)runnable{
    return YES;
}

-(NSString*)absoluteManagePyPath{
    NSMutableString *str = [self.managePyPath mutableCopy];
    [str replaceOccurrencesOfString:@"$IUFileDirectory" withString:[[self path] stringByDeletingLastPathComponent] options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"$AppName" withString:[self name] options:0 range:NSMakeRange(0, [str length])];

    
    NSString *returnPath = [str stringByExpandingTildeInPath];
    return returnPath;
}

- (void)resetBuildPath{
    self.buildPath = @"$IUFileDirectory/templates";
    self.buildResourcePath = @"$IUFileDirectory/templates/resource";
    self.managePyPath = @"$IUFileDirectory/manage.py";
    self.port = 8000;
}

@end
