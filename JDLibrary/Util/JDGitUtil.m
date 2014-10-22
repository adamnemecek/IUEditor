//
//  JDGitUtil.m
//  Mango
//
//  Created by JD on 13. 5. 16..
/// Copyright (c) 2004-2013, JDLab  / Yang Joodong
/// All rights reserved. Licensed under the GPL.
/// See the GNU General Public License for more details. (/LICENSE)

//

#import "JDGitUtil.h"
#import "JDShellUtil.h"

@interface JDGitUtil () <JDShellUtilPipeDelegate>
@end

@implementation JDGitUtil{
    NSString *filePath;
    JDShellUtil *shellUtil;
}

-(id)initWithGitRepoPath:(NSString*)_filePath{
    self = [super init];
    if (self) {
        filePath = [_filePath copy];
        shellUtil = [[JDShellUtil alloc] init];
    }
    return self;
}

-(BOOL)isGitRepo{
    NSString *stdOut;
    NSString *stdErr;
    NSString *gitPath = [[NSBundle mainBundle] pathForResource:@"git" ofType:@""];

    [JDShellUtil execute:gitPath atDirectory:filePath arguments:@[@"status"] stdOut:&stdOut stdErr:&stdErr];
    if ([stdErr containsString:@"fatal"]) {
        return NO;
    }
    return YES;
}


-(BOOL)gitInit{
    NSString *gitPath = [[NSBundle mainBundle] pathForResource:@"git" ofType:@""];
    NSString *log, *errLog;
    NSInteger result = [JDShellUtil execute:gitPath atDirectory:filePath arguments:@[@"init"] stdOut:&log stdErr:&errLog];
    JDInfoLog(@"git init returned:\n%@ + %@", log, errLog);
    return !result;
}

-(BOOL)addAll{
    NSString *gitPath = [[NSBundle mainBundle] pathForResource:@"git" ofType:@""];
    NSString *log, *errLog;
    NSInteger resultCode = [JDShellUtil execute:gitPath atDirectory:filePath arguments:@[@"add", @"."] stdOut:&log stdErr:&errLog];
    JDInfoLog(@"git init returned:\n%@ + %@", log, errLog);
    return !resultCode;
}

-(BOOL)commit:(NSString*)commitMsg{
    NSString *gitPath = [[NSBundle mainBundle] pathForResource:@"git" ofType:@""];
    NSString *msg = [NSString stringWithFormat:@"'%@'", commitMsg];
    NSString *log, *errLog;
    NSInteger resultCode = [JDShellUtil execute:gitPath atDirectory:filePath arguments:@[@"commit", @"-a", @"-m",msg] stdOut:&log stdErr:&errLog];
    JDInfoLog(@"git commit returned:\n%@ + %@", log, errLog);
    return !resultCode;

}

-(void)push:(NSString*)remote branch:(NSString*)branch force:(BOOL)force{
    NSString *gitPath = [[NSBundle mainBundle] pathForResource:@"git" ofType:@""];
    NSMutableArray *arguments = [@[@"push", @"--force", remote, branch] mutableCopy];
    if (force == NO) {
        [arguments removeObjectAtIndex:1];
    }
    [shellUtil execute:gitPath atDirectory:filePath arguments:arguments delegate:self];
}

- (void)herokuPush{
    NSString *herokuPushScriptPath = [[NSBundle mainBundle] pathForResource:@"heroku_push" ofType:@"sh"];
    NSString *gitPath = [[NSBundle mainBundle] pathForResource:@"git" ofType:@""];
    
    [shellUtil execute:herokuPushScriptPath atDirectory:filePath arguments:@[gitPath] delegate:self];
}



- (void)shellUtil:(JDShellUtil*)util standardOutputDataReceived:(NSData*)data{
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([message length]) {
        [self.delegate gitUtil:self pushMessageReceived:message];
    }
}

- (void)shellUtil:(JDShellUtil*)util standardErrorDataReceived:(NSData*)data{
    [self.delegate gitUtil:self pushMessageReceived:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}

- (void)shellUtilExecutionFinished:(JDShellUtil*)util{
    [self.delegate gitUtilPushFinished:self];
}

@end
