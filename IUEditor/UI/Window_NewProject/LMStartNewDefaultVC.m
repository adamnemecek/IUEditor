//
//  LMStartNewDefaultVC.m
//  IUEditor
//
//  Created by jd on 5/2/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMStartNewDefaultVC.h"
#import "JDFileUtil.h"
#import "IUProject.h"
#import "LMAppDelegate.h"
#import "LMWC.h"
#import "IUProjectController.h"
#import "LMStartNewVC.h"

@interface LMStartNewDefaultVC ()

@property (nonatomic) NSString *defaultProjectDir, *appName;
@property (nonatomic) NSString *wholeName;


@end

@implementation LMStartNewDefaultVC

- (void)performNext{
    if(_defaultProjectDir == nil || _defaultProjectDir==0){
        [JDUIUtil hudAlert:@"Select Project Folder Path" second:2];
        return;
    }

    if(_appName == nil || _appName.length==0){
        [JDUIUtil hudAlert:@"Input Project Name" second:2];
        return;
    }
    
    [self.view.window close];
    
    
    NSDictionary *options = @{  IUProjectKeyGit: @(NO),
                                IUProjectKeyHeroku: @(NO),
                                IUProjectKeyType:@(IUProjectTypeDefault),
                                IUProjectKeyAppName : _appName,
                                IUProjectKeyIUFilePath : self.wholeName,
                                };
    
    [(IUProjectController *)[NSDocumentController sharedDocumentController] newDocument:self withOption:options];
}

- (void)performPrev{
    NSAssert(_parentVC, @"");
    [_parentVC show];
}

- (void)show{
    NSAssert(_nextB, @"");
    NSAssert(_nextB != _prevB, @"");
    
    [_nextB setEnabled:YES];
    [_prevB setEnabled:YES];
    
    _prevB.target = self;
    _nextB.target = self;
    [_prevB setAction:@selector(performPrev)];
    [_nextB setAction:@selector(performNext)];
}

- (IBAction)performProjectDirSelect:(id)sender {
    self.defaultProjectDir = [[[JDFileUtil util] openDirectoryByNSOpenPanelWithTitle:@"Select Default Project Directory"] path];
}

- (void)setDefaultProjectDir:(NSString *)defaultProjectDir{
    [self willChangeValueForKey:@"wholeName"];
    _defaultProjectDir = defaultProjectDir;
    [self didChangeValueForKey:@"wholeName"];
}

- (void)setAppName:(NSString *)appName{
    [self willChangeValueForKey:@"wholeName"];
    _appName = appName;
    [self didChangeValueForKey:@"wholeName"];
}

- (NSString *)wholeName{
    if(_appName && _defaultProjectDir){
        NSString *iuName = [_appName stringByAppendingPathExtension:@"iu"];
        return [_defaultProjectDir stringByAppendingPathComponent:iuName];
    }
    else if(_appName){
        NSString *iuName = [_appName stringByAppendingPathExtension:@"iu"];
        return [@"Select Path/" stringByAppendingPathComponent:iuName];

    }
    else if(_defaultProjectDir){
        return [_defaultProjectDir stringByAppendingPathComponent:@"NAME.iu"];
    }
    return @"Your Project Name will be presented";
}

@end
