//
//  LMHerokuWC.m
//  IUEditor
//
//  Created by jd on 2014. 7. 29..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMHerokuWC.h"
#import "JDHerokuUtil.h"
#import "JDGitUtil.h"
#import "JDDateTimeUtil.h"
#import "JDShellUtil.h"

@interface LMHerokuWC  () <JDHerokuUtilLoginDelegate, JDGitUtilDelegate>

//git info
@property BOOL     isGitRepo; // yes to repo. no to not initialized repo
@property NSString *gitRepoStatus; // text for git repo status log

//heroku login information
@property NSString *herokuID;
@property NSString *password;

//heroku app information
@property NSString *herokuAppName;


@property (weak) IBOutlet NSButton *gitInitB;


@property (weak) IBOutlet NSTextField *herokuAppNameTF;
@property (weak) IBOutlet NSTextField *herokuAppNameLabel;
@property (weak) IBOutlet NSButton *herokuVisitB;
@property (weak) IBOutlet NSButton *herokuCreateB;

@property (unsafe_unretained) IBOutlet NSTextView *herokuTV;

@property BOOL herokuLogined;
@property NSString *herokuLoginLog;


/* views */
@property (weak) IBOutlet NSView *herokuNotInstalledV;
@property (weak) IBOutlet NSView *gitInfoV;
@property (weak) IBOutlet NSView *herokuNotLoginedV;
@property (weak) IBOutlet NSView *herokuLoginedV;
@property (weak) IBOutlet NSView *herokuAppInfoV;
@property (weak) IBOutlet NSView *notBuiltV;

@end





@implementation LMHerokuWC  {
    JDHerokuUtil *herokuUtil;
    JDGitUtil   *gitUtil;
    NSString *_gitRepoPath;
    BOOL windowLoaded;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        herokuUtil = [[JDHerokuUtil alloc] init];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    windowLoaded = YES;
}

- (void)setGitRepoPath:(NSString *)path{
    _gitRepoPath = [path copy];
    gitUtil = [[JDGitUtil alloc] initWithGitRepoPath:_gitRepoPath];
    gitUtil.delegate = self;
    if ([[NSFileManager defaultManager] fileExistsAtPath:_gitRepoPath isDirectory:NO] == NO) {
        self.isGitRepo = NO;
        self.gitRepoStatus = @"No directory Existed. Please build first.";
    }
    else {
        self.isGitRepo = [gitUtil isGitRepo];
    }
}



- (NSString*)gitRepoPath{
    return _gitRepoPath;
}

- (void)willBeginSheet:(NSNotification *)notification{
    [self rearrangeView];
}

- (void)rearrangeView{
    BOOL herokuInstalled = [JDShellUtil canFindCommand:@"heroku"];
    
    //hide all view
    [self.herokuNotInstalledV setHidden:YES];
    [self.gitInfoV setHidden:YES];
    [self.herokuNotLoginedV setHidden:YES];
    [self.herokuLoginedV setHidden:YES];
    [self.herokuAppInfoV setHidden:YES];
    [self.notBuiltV setHidden:NO];

    BOOL isDirectory;
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:self.gitRepoPath isDirectory:&isDirectory];
    if (isDirectory && fileExist) {
        [self.notBuiltV setHidden:YES];
        
        if (herokuInstalled == NO) {
            //show
            [self.herokuNotInstalledV setHidden:NO];
        }
        else {
            [self.gitInfoV setHidden:NO];
            [self.gitInitB setHidden:NO];
            
            BOOL isGitRepo = [gitUtil isGitRepo];
            if (isGitRepo) {
                //hide git init button
                [self.gitInitB setHidden:YES];
                
                //show heroku login info
                self.herokuID = [JDHerokuUtil loginID];
                
                if (self.herokuID == NO) {
                    [self.herokuNotLoginedV setHidden:NO];
                }
                else {
                    [self.herokuLoginedV setHidden:NO];
                    [self.herokuAppInfoV setHidden:NO];
                    self.herokuAppName = [JDHerokuUtil herokuAppNameAtPath:self.gitRepoPath];
                    if (self.herokuAppName) {
                        [self.herokuAppNameTF setHidden:YES];
                        [self.herokuCreateB setHidden:YES];
                        
                        [self.herokuAppNameLabel setHidden:NO];
                        [self.herokuVisitB setHidden:NO];
                    }
                    else {
                        [self.herokuAppNameTF setHidden:NO];
                        [self.herokuCreateB setHidden:NO];
                        
                        [self.herokuAppNameLabel setHidden:YES];
                        [self.herokuVisitB setHidden:YES];
                    }
                }
            }
        }
    }
}

#pragma mark Heroku Not Install V

- (IBAction)visitHerokuDownloadPage:(id)sender{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://toolbelt.heroku.com" ]];
}

#pragma mark Git Info V

- (IBAction)gitInit:(id)sender{
    JDGitUtil *util = [[JDGitUtil alloc] initWithGitRepoPath:_gitRepoPath];
    BOOL result = [util gitInit];
    if (result) {
        self.isGitRepo = YES;
        [self.gitInitB setHidden:YES];
        [self rearrangeView];
    }
}

#pragma mark Heroku Login

- (IBAction)login:(id)sender {
    herokuUtil.loginDelegate = self;
    [herokuUtil login:self.herokuID password:self.password];
}

-(void)herokuUtil:(JDHerokuUtil*)util loginProcessFinishedWithResultCode:(NSInteger)resultCode{
    if (resultCode == 1) {
        //login failed
        self.herokuLoginLog = @"Login Failed";
    }
    else {
        self.herokuLoginLog = @"Login Success";
        [self rearrangeView];
    }
}

- (IBAction)logout:(id)sender {
    herokuUtil.loginDelegate = self;
    [herokuUtil logout];
}

-(void)herokuUtil:(JDHerokuUtil*)util logoutProcessFinishedWithResultCode:(NSInteger)resultCode{
    if (resultCode == 1) {
        //login failed
        self.herokuLoginLog = @"Logout Failed";
    }
    else {
        self.herokuLoginLog = @"Logout Success";
        [self rearrangeView];
    }
}

#pragma mark Heroku App Info

- (IBAction)herokuCreate:(id)sender {
    //heroku create app
    NSString *resultLog;
    NSString *enteredHerokuAppName = [self.herokuAppNameTF stringValue];
    BOOL result = [herokuUtil create:enteredHerokuAppName resultLog:&resultLog];
    if (result) {
        //YES
        //combine git
        [herokuUtil combineGitPath:self.gitRepoPath appName:enteredHerokuAppName];
        [JDUIUtil hudAlert:@"App created. Press Sync." second:2];
        [self addHerokuLog:@"App created. Press Sync.\n"];
        [self rearrangeView];
    }
    else {
        //Failed
        [JDUIUtil hudAlert:resultLog second:2];
    }
}


- (IBAction)performHerokuVisit:(id)sender {
    NSString *urlString = [NSString stringWithFormat:@"http://%@.herokuapp.com", self.herokuAppName];
    NSURL *url = [NSURL URLWithString:urlString];
    [[NSWorkspace sharedWorkspace] openURL:url];
}



- (IBAction)sync:(id)sender{
    //create configru
    [herokuUtil prepareHerokuUpload:_gitRepoPath];
    
    [gitUtil addAll];
    NSString *commitMessage = [JDDateTimeUtil stringForDate:[NSDate date] option:JDDateStringTimestampType];
    [gitUtil commit:commitMessage];
    
    [gitUtil herokuPush];
}

- (void)gitUtil:(JDGitUtil*)util pushMessageReceived:(NSString*)aMessage{
    [self addHerokuLog:aMessage];
}

- (void)gitUtilPushFinished:(JDGitUtil*)util{
    [self addHerokuLog:@"\n"];
    [self addHerokuLog:@"---- SYNC FINISHED ---\n"];
    //    [JDUIUtil hudAlert:@"Sync Success" second:3];
    //    [self.window.sheetParent c]
}



- (IBAction)pressCancel:(id)sender {
    [self.window.sheetParent endSheet:self.window];
}

- (void)cancelOperation:(id)sender{
    [self pressCancel:self];
}

- (void)addHerokuLog:(NSString*)str{
    if ([str length]) {

        NSAttributedString* attr = [[NSAttributedString alloc] initWithString:str];
        
        [[_herokuTV textStorage] appendAttributedString:attr];
        [_herokuTV scrollRangeToVisible:NSMakeRange([[_herokuTV string] length], 0)];
    }
}

@end
