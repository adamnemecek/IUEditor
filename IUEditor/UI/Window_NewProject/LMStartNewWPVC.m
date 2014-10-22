//
//  LMStartNewWPVC.m
//  IUEditor
//
//  Created by jd on 2014. 8. 9..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMStartNewWPVC.h"
#import "LMHelpWC.h"
#import "IUProject.h"
#import "IUProjectController.h"
#import "LMStartNewVC.h"


@interface LMStartNewWPVC ()

@property NSString *serverText;
@property NSInteger serverState;

@property (nonatomic) NSString *themeCollectionDirectory;
@property (nonatomic) NSString *themeDirectory;
@property (nonatomic) NSString *themeName;

@end

@implementation LMStartNewWPVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        /* We do not support mysql on v3
        // Initialization code here.
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://mysql.iueditor.org/state"]];
        NSDictionary *d;
        if (data) {
            d = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        self.serverState = [d[@"state"] intValue];
        self.serverText = @"Server is down";
        if (d[@"text"]) {
            self.serverText = d[@"text"];
        }
          */
        self.themeName = @"iusample";
        self.themeCollectionDirectory = [@"~/Sites/wordpress/wp-content/themes" stringByExpandingTildeInPath];
    }
    return self;
}

- (IBAction)openInstallTutorial:(id)sender {
    LMHelpWC *hWC = [LMHelpWC sharedHelpWC];
    [hWC showHelpWindowWithKey:@"InstallingWordpress"];
}

- (IBAction)copyWordpressFile:(id)sender {
    NSString *wordpressPath = [[NSBundle mainBundle] pathForResource:@"wordpress" ofType:@"zip"];
    NSString *targetPath = [@"~/Sites" stringByExpandingTildeInPath];
    [[JDFileUtil util] unzip:wordpressPath toDirectory:targetPath createDirectory:YES];
}

- (void)setThemeCollectionDirectory:(NSString *)themeCollectionDirectory{
    _themeCollectionDirectory = themeCollectionDirectory;
    [self updateThemeDirectory];
}

- (void)setThemeName:(NSString *)themeName{
    _themeName = themeName;
    [self updateThemeDirectory];
}

- (void)updateThemeDirectory{
    if (self.themeCollectionDirectory && self.themeName) {
        self.themeDirectory = [self.themeCollectionDirectory stringByAppendingPathComponent:self.themeName];
    }
    else {
        self.themeDirectory = nil;
    }
}

- (IBAction)selectWordpressThemeDirectory:(id)sender {
    NSURL *url = [[JDFileUtil util] openDirectoryByNSOpenPanelWithTitle:@"Select Wordpress Theme Collection Directory"];
    self.themeCollectionDirectory = [url path];
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

- (void)performNext{
    if (self.themeDirectory == nil) {
        [JDLogUtil alert:@"Please fill data" title:@"Error"];
        return;
    }
    NSString *fileName = [self.themeCollectionDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.iu", self.themeName]];
    NSDictionary *options = @{   IUProjectKeyGit: @(NO),
                                 IUProjectKeyHeroku: @(NO),
                                 IUProjectKeyAppName : self.themeName,
                                 IUProjectKeyIUFilePath : fileName,
                                 IUProjectKeyType:@(IUProjectTypeWordpress),
                                 };
    //create theme collection dir
    [[NSFileManager defaultManager] createDirectoryAtPath:_themeCollectionDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    [(IUProjectController*)[NSDocumentController sharedDocumentController] newDocument:nil withOption:options];
    [self.view.window close];
}


- (void)performPrev{
    NSAssert(_parentVC, @"");
    [_parentVC show];
}



@end
