//
//  LMAppDelegate.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"

#import "LMAppDelegate.h"

#import "BBStartWarningWC.h"


/////////////////////////////

#import "JDLogUtil.h"

#import "IUDjangoProject.h"
#import "IUWordpressProject.h"

#import "LMPreferenceWC.h"
#import "IUProjectController.h"
#import "LMNotiManager.h"
#import "JDEnvUtil.h"
#import "LMHelpWC.h"

@implementation LMAppDelegate{
    BBStartWarningWC *_startWarningWC;
    
    ///////////////////////
    LMPreferenceWC *preferenceWC;
    LMNotiManager *notiManager;
    
    
}

+ (void)initialize{
    //user default setting
    NSString *defaultsFilename = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
    // initialize a dictionary with contents of it
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:defaultsFilename];
    // register the stuff
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

/**
@brief check network connection
@return YES is succefully connected.
 */
- (BOOL)isConnected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    /* check network connection */
    if([self isConnected] == NO){
        /* network is disconnected */
        
        [NSApp activateIgnoringOtherApps:YES];
        
        //import warning
        if(_startWarningWC == nil){
            _startWarningWC = [[BBStartWarningWC alloc] initWithWindowNibName:[BBStartWarningWC className]];
        }
        
        [_startWarningWC showWindow:self];
        [_startWarningWC.window center];
        [_startWarningWC.window makeKeyAndOrderFront:self];
    }
    
#if DEBUG
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenuItem *debugItem = [[NSMenuItem alloc] init];
    debugItem.title = @"Debug";
    [mainMenu addItem:debugItem];
    
    NSMenu *debugMenu = [[NSMenu alloc] init];
    debugMenu.title = @"Debug";
    [debugItem setSubmenu:debugMenu];
    [debugMenu addItem:[[NSMenuItem alloc] initWithTitle:@"Stress Test" action:@selector(debug_stressTest) keyEquivalent:@""]];

    /*
     [JDLogUtil enableLogSection:IULogSource];
     [JDLogUtil enableLogSection:IULogJS];
     [JDLogUtil enableLogSection:IULogAction];
     [JDLogUtil enableLogSection:IULogText];
     [JDLogUtil enableLogSection:IULogDealloc];
     */
    
    [JDLogUtil showLogLevel:YES andFileName:YES andFunctionName:YES andLineNumber:YES];
    [JDLogUtil setGlobalLevel:JDLog_Level_Info];
#else
    if ([JDEnvUtil isFirstExecution:@"IUEditor"]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://server.iueditor.org/download.php"]];
        [NSURLConnection connectionWithRequest:request delegate:nil];
        
        //google group
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://groups.google.com/forum/#!forum/iueditor"]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://server.iueditor.org/use.php"]];
    [NSURLConnection connectionWithRequest:request delegate:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];

    //if there is no opend document,
    if([[[NSDocumentController sharedDocumentController] documents] count] < 1){
//        [self showStartTemplate:self];
    }
    
    notiManager = [[LMNotiManager alloc] init];
    [notiManager connectWithServerAfterDelay:0];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"iututorial"] == NO) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"iututorial"];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guide.iueditor.org/"]];

    }
    
#endif

    
 
    //default menu에서 쓰지 않는 메뉴 삭제.
    NSMenu* edit = [[[[NSApplication sharedApplication] mainMenu] itemWithTitle: @"Edit"] submenu];
    if ([[edit itemAtIndex: [edit numberOfItems] - 1] action] == NSSelectorFromString(@"orderFrontCharacterPalette:")
        )
        [edit removeItemAtIndex: [edit numberOfItems] - 1];
    
    if ([[edit itemAtIndex: [edit numberOfItems] - 1] action] == NSSelectorFromString(@"startDictation:"))
        [edit removeItemAtIndex: [edit numberOfItems] - 1];
    
    if ([[edit itemAtIndex: [edit numberOfItems] - 1] isSeparatorItem])
        [edit removeItemAtIndex: [edit numberOfItems] - 1];
}


- (void)debug_stressTest {
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"stressTest"];
    [[NSDocumentController sharedDocumentController] newDocument:@{IUProjectModeKey:IUProjectModeStress}];
}


- (IBAction)openPreference:(id)sender {
     preferenceWC = [[LMPreferenceWC alloc] initWithWindowNibName:@"LMPreferenceWC"];
    [preferenceWC showWindow:self];
}



- (IBAction)performHelp:(NSMenuItem *)sender{
    if (sender.tag == 1) {
        NSString *tutorial = @"http://www.iueditor.org";
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:tutorial]];
    }
    else if (sender.tag == 2){
        NSString *forum = @"https://groups.google.com/forum/#!topic/iueditor";
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:forum]];
    }
    else {
        NSString *tutorial = @"http://guide.iueditor.org";
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:tutorial]];
    }
    /*
    LMHelpWC *hWC = [LMHelpWC sharedHelpWC];
    switch (sender.tag) {
        case 0:
            //Documentation
            [hWC showFirstItem];
            break;
        case 1:
            //Release Notes
            
            break;
        case 2:
            //Tutorial
            [hWC showHelpWindowWithKey:@"tutorial"];
            break;
        
        case 3:{
            //IUEditor Homepage
            NSString *tutorial = @"http://www.iueditor.org";
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:tutorial]];
            break;
        }
        default:
            break;
    }
 */
    
}


#pragma mark - application delegate

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender{
    return YES;
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    if(flag == NO) {
#if DEBUG
        
        //open last document
        NSArray *recents = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
        if ([recents count]){
            NSURL *lastURL = [recents objectAtIndex:0];
            [(IUProjectController *)[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:lastURL display:YES completionHandler:nil];
            
            
        }
#else
        //cmd + N 화면
        //https://developer.apple.com/library/mac/documentation/cocoa/reference/NSApplicationDelegate_Protocol/Reference/Reference.html#//apple_ref/occ/intfm/NSApplicationDelegate/applicationOpenUntitledFile:
        
//        [self showStartTemplate:self];
        
#endif
        return NO;
    }
    return YES;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename{
    if([[NSFileManager defaultManager] fileExistsAtPath:filename]){
        NSURL *url = [NSURL fileURLWithPath:filename];
        [(IUProjectController *)[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:url display:YES completionHandler:nil];
        return YES;
    }
    return NO;
}


@end