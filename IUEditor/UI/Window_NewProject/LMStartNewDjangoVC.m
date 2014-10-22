//
//  LMStartNewDjangoVC.m
//  IUEditor
//
//  Created by jw on 5/3/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMStartNewDjangoVC.h"
#import "JDFileUtil.h"
#import "IUDjangoProject.h"
#import "LMAppDelegate.h"
#import "IUProjectController.h"
#import "LMStartNewVC.h"

@interface LMStartNewDjangoVC ()
@property NSString *djangoProjectDir;
@property NSString *djangoResourceDir;
@property NSString *djangoTemplateDir;

@property (nonatomic) NSString *absoluteIUFilePath;

@end

@implementation LMStartNewDjangoVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (void)performNext{
    if (_djangoProjectDir == nil || [_djangoProjectDir length] == 0 ) {
        [JDLogUtil alert:@"Input project directory path"];
        return;
    }
    if (_djangoResourceDir == nil || [_djangoResourceDir length] == 0 ) {
        [JDLogUtil alert:@"Input project resource directory path"];
        return;
    }
    if (_djangoTemplateDir == nil || [_djangoTemplateDir length] == 0 ) {
        [JDLogUtil alert:@"Input project template directory path"];
        return;
    }

    NSDictionary *options = @{   IUProjectKeyGit: @(NO),
                                 IUProjectKeyHeroku: @(NO),
                                 IUProjectKeyAppName : [_djangoProjectDir lastPathComponent],
                                 IUProjectKeyIUFilePath : self.absoluteIUFilePath,
                                 IUProjectKeyType:@(IUProjectTypeDjango),
                                 IUProjectKeyResourcePath : _djangoResourceDir,
                                 IUProjectKeyBuildPath : _djangoTemplateDir
                                 };
    
    [(IUProjectController *)[NSDocumentController sharedDocumentController] newDocument:self withOption:options];
    [self.view.window close];
}

- (void)performPrev{
    NSAssert(_parentVC, @"");
    [_parentVC show];
}

- (NSString *)absoluteIUFilePath{
    if(_djangoProjectDir && _djangoProjectDir.length > 0){
        return [_djangoProjectDir stringByAppendingString:[NSString stringWithFormat:@"/%@.iu", [_djangoProjectDir lastPathComponent]] ];
    }
    else{
        return @"Your Project Name will be presented";
    }
}

- (IBAction)performProjectDirSelect:(id)sender {
    
    [self willChangeValueForKey:@"absoluteIUFilePath"];
    self.djangoProjectDir = [[[JDFileUtil util] openDirectoryByNSOpenPanelWithTitle:@"Select Django Project Directory"] path];
    [self didChangeValueForKey:@"absoluteIUFilePath"];
    
    self.djangoTemplateDir = @"$IUFileDirectory/templates";
    self.djangoResourceDir = @"$IUFileDirectory/templates/resource";
}

- (IBAction)performResourceDirSelect:(id)sender {
    self.djangoProjectDir = [[[JDFileUtil util] openDirectoryByNSOpenPanelWithTitle:@"Select Django resource Directory"] path];
}

- (IBAction)performTemplateDirSelect:(id)sender {
    self.djangoTemplateDir = [[[JDFileUtil util] openDirectoryByNSOpenPanelWithTitle:@"Select Django Project Template Directory"] path];
}

- (void)show{
    NSAssert(_nextB, @"");
//    NSAssert(_prevB, @"");
    
    _nextB.target = self;
    _prevB.target = self;
    
    [_prevB setEnabled:YES];
    [_nextB setAction:@selector(performNext)];
    [_prevB setAction:@selector(performPrev)];
    
}


@end
