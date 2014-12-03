//
//  BBCommandVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBCommandVC.h"

#import "JDNetworkUtil.h"

#import "IUWordpressProject.h"
#import "IUDjangoProject.h"


@interface BBCommandVC ()

@property (weak) IBOutlet NSPopUpButton *buildTypePopupButton;


//django server view
@property (weak) IBOutlet NSBox *serverBox;

@property (weak) IBOutlet NSTextField *serverStateTextField;
@property (weak) IBOutlet NSImageView *serverStateImageView;

@property (weak) IBOutlet NSMenuItem *serverStopMenuItem;
@property NSString *serverState;

@end

@implementation BBCommandVC{
    JDShellUtil *_debugServerShell;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //binding
    [_buildTypePopupButton bind:NSContentBinding toObject:self withKeyPath:@"sourceManager.availableCompilerRule" options:IUBindingDictNotRaisesApplicable];
    [_buildTypePopupButton bind:NSSelectedValueBinding toObject:self withKeyPath:@"sourceManager.compilerRule" options:IUBindingDictNotRaisesApplicable];
    [_serverStateTextField bind:NSValueBinding toObject:self withKeyPath:@"serverState" options:IUBindingDictNotRaisesApplicable];
    
    
    //initialize
    [self setServerViewForType:self.sourceManager.compilerRule];
    
}



- (IBAction)build:(id)sender {
    
    NSString *rule = self.sourceManager.compilerRule;

    if ([rule isEqualToString:kIUCompileRuleHTML]
        || [rule isEqualToString:kIUCompileRuleWordpress]
        || [rule isEqualToString:kIUCompileRulePresentation] ) {
        
        BOOL result = [self.sourceManager build:nil];
        
        if (result == NO) {
            NSAssert(0, @"");
        }
        IUSheet *doc = [[_docController selectedObjects] firstObject];
        if([doc isKindOfClass:[IUSheet class]] == NO){
            doc = _docController.project.pageGroup.childrenFileItems.firstObject;
        }
        if ([rule isEqualToString:kIUCompileRuleHTML] || [rule isEqualToString:kIUCompileRulePresentation]) {
            NSString *firstPath = [self.sourceManager absoluteBuildPathForSheet:doc];
            [[NSWorkspace sharedWorkspace] openFile:firstPath];
        }
        else if([rule isEqualToString:kIUCompileRuleWordpress]){
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
    else if ([rule isEqualToString:kIUCompileRuleDjango]){
        IUDjangoProject *project = (IUDjangoProject *)_docController.project;
        
        //get port
        //run server
        if ([_debugServerShell.task isRunning] == NO) {
            if ([JDNetworkUtil isPortAvailable:project.port]) {
                BOOL result = [self runServer:nil];
                if (result == NO) {
                    return;
                }
            }
        }
        
        [self refreshServerState];
        
        //compile
        BOOL result = [self.sourceManager build:nil];
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

- (IBAction)clickBuildTypePopupButton:(id)sender {
    NSString *selectedType = [[_buildTypePopupButton selectedItem] representedObject];
    [self setServerViewForType:selectedType];
}


#pragma mark - django server

- (void)setServerViewForType:(NSString *)type{
    if([type isEqualToString:kIUCompileRuleDjango]){
        [_serverBox setHidden:NO];
    }
    else{
        [_serverBox setHidden:YES];
    }
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
    if ([_debugServerShell.task isRunning] == NO) {
        _debugServerShell = [[JDShellUtil alloc] init];
        [_debugServerShell execute:command delegate:self];
    }
    [self refreshServerState];
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleStart object:self.view.window];
    return YES;
}


- (IBAction)stopServer:(id)sender {
    // run server
    if (_debugServerShell) {
        [_debugServerShell stop];
        _debugServerShell = nil;
    }
    
    if ([_debugServerShell.task isRunning] == NO) {
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
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleEnd object:self.view.window];
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
            [_serverStateImageView setImage:[NSImage imageNamed:@"NSStatusNone"]];
            [_serverStopMenuItem setEnabled:NO];
            return;
        }
        NSString *processName = [JDNetworkUtil processNameOfPort:port];
        self.serverState = [NSString stringWithFormat:@"%@(%ld) is running", processName, pid];
        [_serverStateImageView setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
        [_serverStopMenuItem setEnabled:YES];

    }
}

- (void)shellUtil:(JDShellUtil*)util standardOutputDataReceived:(NSData*)data{
    NSString *log = [[NSString alloc] initWithData:data encoding:4];
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleLog object:self.view.window userInfo:@{@"Log": log}];
}

- (void)shellUtil:(JDShellUtil*)util standardErrorDataReceived:(NSData*)data{
    NSString *log = [[NSString alloc] initWithData:data encoding:4];
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleLog object:self.view.window userInfo:@{@"Log": log}];
}


- (void)shellUtilExecutionFinished:(JDShellUtil *)util{
    if (util.name) {
        NSString *log = [NSString stringWithFormat:@" ------ %@ Ended -----", util.name];
        [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleLog object:self.view.window userInfo:@{IUNotificationConsoleLogText: log}];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationConsoleEnd object:self.view.window];
}

@end
