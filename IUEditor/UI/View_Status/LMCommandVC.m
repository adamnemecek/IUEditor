//
//  LMCommandVC.m
//  IUEditor
//
//  Created by jd on 5/20/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUSheetGroup.h"
#import "IUDjangoProject.h"
#import "IUWordPressProject.h"

#import "JDScreenRecorder.h"
#import "JDDateTimeUtil.h"
#import "LMHelpWC.h"
#import "LMCommandVC.h"

#import "JDNetworkUtil.h"

#import "IUSourceManager.h"

@interface LMCommandVC ()
@property (weak) IBOutlet NSButton *buildB;
@property (weak) IBOutlet NSButton *stopServerB;
@property (weak) IBOutlet NSPopUpButton *compilerB;


//menuItem
@property (weak) IBOutlet NSMenuItem *djangoMenuItem;
@property (weak) IBOutlet NSMenuItem *wpMenuItem;

@property NSString *serverState;
@end

@implementation LMCommandVC {
    NSTask *serverTask;
    __weak NSButton *_serverB;
    __weak NSPopUpButton *_compilerB;
    
    
    NSPipe *stdOutput;
    NSPipe *stdError;
    
    NSFileHandle *stdOutputHandle;
    NSFileHandle *stdErrorHandle;
    
    JDScreenRecorder *screenRecorder;
    JDShellUtil *debugServerShell;
    
    BOOL recording;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadView];
    }
    return self;
}

- (void)prepareDealloc{
//    [self removeObserver:self forKeyPath:@"docController.project.runnable"];
    [_compilerB unbind:NSSelectedIndexBinding];
}

- (void)setDocController:(IUSheetController *)docController{
    if (docController == nil) {
        return;
    }
    NSAssert(docController.project, @"Should have docController.project for KVO issue");
    _docController = docController;
//    [self addObserver:self forKeyPath:@"docController.project.runnable" options:NSKeyValueObservingOptionInitial context:nil];
#ifndef DEBUG
    //[_recordingB setHidden:YES];
#endif
    
    
    //disable compile rule
    IUProjectType type = [self.docController.project projectType];
    if(type != IUProjectTypeDjango){
        [_djangoMenuItem setEnabled:NO];
        [_djangoMenuItem setHidden:YES];
    }
    if(type != IUProjectTypeWordpress){
        [_wpMenuItem setEnabled:NO];
        [_wpMenuItem setHidden:YES];
    }
    
    
    //[_compilerB bind:NSSelectedIndexBinding toObject:self withKeyPath:@"docController.project.compiler.rule" options:nil];
    
}



-(void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"LMCommandVC"];
}

-(void)docController_project_runnableDidChange:(NSDictionary*)change{
    if (_docController.project.runnable == NO) {
        [_serverB setEnabled:NO];
        [[_compilerB itemAtIndex:1] setEnabled:NO];
        [_compilerB setAutoenablesItems:NO];
    }
    else {
        [_serverB setEnabled:YES];
        [[_compilerB itemAtIndex:1] setEnabled:YES];
        [_compilerB setAutoenablesItems:YES];
    }
}




- (IBAction)build:(id)sender {
    IUSourceManager *sourceManager = [[[NSApp mainWindow] windowController] performSelector:@selector(sourceManager)];

    NSString *rule = sourceManager.compilerRule;
    //FIXME : temp
    //rule = IUCompileRuleHTML;
    
    if ([rule isEqualToString:IUCompileRuleHTML]
        || [rule isEqualToString:IUCompileRuleWordpress]
        || [rule isEqualToString:IUCompileRulePresentation] ) {
        BOOL result = [sourceManager build:nil];

        if (result == NO) {
            NSAssert(0, @"");
        }
        IUSheet *doc = [[_docController selectedObjects] firstObject];
        if([doc isKindOfClass:[IUSheet class]] == NO){
            doc = _docController.project.pageGroup.childrenFileItems.firstObject;
        }
        if ([rule isEqualToString:IUCompileRuleHTML] || [rule isEqualToString:IUCompileRulePresentation]) {
            NSString *firstPath = [sourceManager absoluteBuildPathForSheet:doc];
            [[NSWorkspace sharedWorkspace] openFile:firstPath];
        }
        else if([rule isEqualToString:IUCompileRuleWordpress]){
            IUWordpressProject *wProject = (IUWordpressProject *) _docController.project;
            
            NSMutableString *path = [NSMutableString stringWithString:@"http://127.0.0.1"];
            if(wProject.port > 0){
                [path appendString:[NSString stringWithFormat:@":%ld", wProject.port]];
            }
            
            if(wProject.documentRoot){
                [path appendFormat:@"/%@", wProject.documentRoot];
            }
            
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:path]];
        }
    }
    else if ([rule isEqualToString:IUCompileRuleDjango]){
        IUDjangoProject *project = (IUDjangoProject *)_docController.project;
        
        //get port
        //run server
        if ([debugServerShell.task isRunning] == NO) {
            if ([JDNetworkUtil isPortAvailable:project.port]) {
                BOOL result = [self runServer:nil];
                if (result == NO) {
                    return;
                }
            }
        }
        
        [self refreshServerState];
        
        //compile
        BOOL result = [sourceManager build:nil];
        if (result == NO) {
            NSAssert(0, @"compile failed");
        }
        
        //open page
        IUSheet *node = [[_docController selectedObjects] firstObject];
        if([node isKindOfClass:[IUSheet class]] == NO){
            node = [project.pageGroup.childrenFileItems firstObject];
        }
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"http://127.0.0.1:%ld/%@", project.port, [node.name lowercaseString]]];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSWorkspace sharedWorkspace] openURL:url];
        });
    }
    else {
        NSAssert(0, @"not coded");
    }
    
    //save document after build
    [[[[NSApp mainWindow] windowController] document] saveDocument:self];
    
    
}

- (BOOL)runServer:(NSError **)error{
    //get port
    IUDjangoProject *djangoProj = (IUDjangoProject*)_docController.project;
    
    NSString *filePath = [djangoProj absoluteManagePyPath];

    if (filePath == nil) {
        //version control code
        [[_docController.project.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"manage.py"];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) {
        [JDUIUtil hudAlert:@"No manage.py" second:2];
        return NO;
    }
    IUDjangoProject *project = (IUDjangoProject *)_docController.project;
    if(project.port < 1024){
        [JDUIUtil hudAlert:@"You should be use port number larger than 1024" second:2];
        return NO;
    }
    
    NSString *shellFilePath = [filePath stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    NSString *command = [NSString stringWithFormat:@"%@ runserver %ld",shellFilePath , project.port];
    if ([debugServerShell.task isRunning] == NO) {
        debugServerShell = [[JDShellUtil alloc] init];
        [debugServerShell execute:command delegate:self];
    }
    [self refreshServerState];
    [[NSNotificationCenter defaultCenter] postNotificationName:IUConsoleDidStartNotification object:self.view.window];
    return YES;
}


- (IBAction)stopServer:(id)sender {
    // run server
    if (debugServerShell) {
        [debugServerShell stop];
        debugServerShell = nil;
    }
    
    if ([debugServerShell.task isRunning] == NO) {
        return;
    }
    
    IUDjangoProject *project = (IUDjangoProject *)_docController.project;
    NSInteger pid = [JDNetworkUtil pidOfPort:project.port];
    if (pid != NSNotFound) {
        //kill
        NSString *killCommand = [NSString stringWithFormat:@"kill %ld", pid];
        [JDShellUtil execute:killCommand];
    }
    [self refreshServerState];
    [[NSNotificationCenter defaultCenter] postNotificationName:IUConsoleDidEndNotification object:self.view.window];
}

- (void)refreshServerState{
    [self refreshServerStatePerform];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshServerStatePerform];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshServerStatePerform];
    });
    
}

- (void)refreshServerStatePerform{
    if(_docController.project.projectType == IUProjectTypeDjango){
        IUDjangoProject *project = (IUDjangoProject *)_docController.project;
        NSInteger port = project.port;
        NSInteger pid = [JDNetworkUtil pidOfPort:port];
        if (pid == NSNotFound) {
            self.serverState = nil;
            return;
        }
        NSString *processName = [JDNetworkUtil processNameOfPort:port];
        self.serverState = [NSString stringWithFormat:@"%@(%ld) is running", processName, pid];
    }
}

- (IBAction)changeCompilerRule:(id)sender {
#if 0
    _docController.project.compiler.rule = (int)[_compilerB indexOfSelectedItem];
    if (_docController.project.compiler.rule == IUCompileRuleDjango) {
        [self refreshServerState];
        [self.stopServerB setEnabled:YES];
    }
    else {
        self.serverState = nil;
        [self.stopServerB setEnabled:NO];
    }
#endif
}
/*
 Remove Recording feature at v0.3
 - (IBAction)toggleRecording:(id)sender{
 if (recording == NO) {
 recording = YES;
 [_recordingB setImage:[NSImage imageNamed:@"record_stop"]];
 [JDUIUtil hudAlert:@"Recording Start" second:3];
 screenRecorder = [[JDScreenRecorder alloc] init];
 
 NSString *fileName = [NSString stringWithFormat:@"%@/Desktop/%@.mp4", NSHomeDirectory(), [JDDateTimeUtil stringForDate:[NSDate date] option:JDDateStringTimestampType2]];
 [screenRecorder startRecord:[NSURL fileURLWithPath:fileName]];
 }
 else {
 recording = NO;
 [_recordingB setImage:[NSImage imageNamed:@"record"]];
 [screenRecorder finishRecord];
 [JDUIUtil hudAlert:@"Recording saved at Desktop" second:3];
 }
 }
 */

- (void)shellUtil:(JDShellUtil*)util standardOutputDataReceived:(NSData*)data{
    NSString *log = [[NSString alloc] initWithData:data encoding:4];
    [[NSNotificationCenter defaultCenter] postNotificationName:IUConsoleLogDidArriveNotification object:self.view.window userInfo:@{@"Log": log}];
}

- (void)shellUtil:(JDShellUtil*)util standardErrorDataReceived:(NSData*)data{
    NSString *log = [[NSString alloc] initWithData:data encoding:4];
    [[NSNotificationCenter defaultCenter] postNotificationName:IUConsoleLogDidArriveNotification object:self.view.window userInfo:@{@"Log": log}];
}


- (void)shellUtilExecutionFinished:(JDShellUtil *)util{
    if (util.name) {
        NSString *log = [NSString stringWithFormat:@" ------ %@ Ended -----", util.name];
        [[NSNotificationCenter defaultCenter] postNotificationName:IUConsoleLogDidArriveNotification object:self.view.window userInfo:@{IULogKey: log}];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:IUConsoleDidEndNotification object:self.view.window];
}

@end
