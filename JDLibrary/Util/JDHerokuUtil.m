//
//  JDHerokuUtil.m
//  Mango
//
//  Created by JD on 13. 5. 17..
/// Copyright (c) 2004-2013, JDLab  / Yang Joodong
/// All rights reserved. Licensed under the GPL.
/// See the GNU General Public License for more details. (/LICENSE)

//

#import "JDHerokuUtil.h"
#import "NSString+JDExtension.h"
#import "JDLogUtil.h"
#import "JDShellUtil.h"

@implementation JDHerokuUtil
{
    BOOL _logined;
    BOOL _logging;
}


-(id)init{
    self = [super init];
    if (self) {
//        [self updateLoginInfo];;
    }
    return self;
}

- (BOOL)logging{
    return _logging;
}

+(NSString*)loginID{
    NSString *resPath = [[NSBundle mainBundle] pathForResource:@"heroku_auth" ofType:@"sh"];

    NSString *errLog, *log;
    NSInteger resultCode = [JDShellUtil execute:resPath atDirectory:@"/" arguments:nil stdOut:&log stdErr:&errLog];
    if (resultCode == 0) {
        return [[log stringByTrim] lastLine];
    }
    return nil;
}

-(BOOL)create:(NSString*)appName resultLog:(NSString**)resultLog{
    NSString *stdOut;
    NSString *stdErr;
    NSInteger returnCode = [JDShellUtil execute:@"/usr/bin/heroku" atDirectory:@"/" arguments:@[@"create",appName] stdOut:&stdOut stdErr:&stdErr];
    if (returnCode) {
        if (resultLog) {
            *resultLog = stdErr;
        }
        return NO;
    }
    if (resultLog) {
        *resultLog = stdOut;
    }
    return YES;
}

-(void)login:(NSString*)myid password:(NSString*)mypasswd{
    [self willChangeValueForKey:@"logging"];
    _logging = YES;
    [self didChangeValueForKey:@"logging"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *resPath = [[NSBundle mainBundle] pathForResource:@"heroku_login" ofType:@"sh"];

        NSInteger resultCode = [JDShellUtil execute:resPath atDirectory:@"/" arguments:@[myid, mypasswd] stdOut:nil stdErr:nil];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self willChangeValueForKey:@"logging"];
            _logging = NO;
            [self didChangeValueForKey:@"logging"];
            [self.loginDelegate herokuUtil:self loginProcessFinishedWithResultCode:resultCode];
        });
    });
}

-(void)logout{
    [self willChangeValueForKey:@"logging"];
    _logging = YES;
    [self didChangeValueForKey:@"logging"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        
        NSInteger resultCode = [JDShellUtil execute:@"heroku logout"];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self willChangeValueForKey:@"logging"];
            _logging = NO;
            [self didChangeValueForKey:@"logging"];
            [self.loginDelegate herokuUtil:self logoutProcessFinishedWithResultCode:resultCode];
        });
    });
}

-(BOOL)combineGitPath:(NSString*)path appName:(NSString*)appName{
    [JDShellUtil execute:@"/usr/bin/heroku" atDirectory:path arguments:@[@"git:remote", @"-a", appName] stdOut:nil stdErr:nil];
    return YES;
}

- (void)prepareHerokuUpload:(NSString*)path{
#if 0
    /* Folowing is for Ruby-Rack Upload */

    NSString *configRUPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"ru"];
    NSString *configRUUnitPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"ruunit"];
    NSMutableString *configRUContent = [NSMutableString stringWithContentsOfFile:configRUPath encoding:NSUTF8StringEncoding error:nil];
    NSMutableString *configRUUnitContent = [NSMutableString stringWithContentsOfFile:configRUUnitPath encoding:NSUTF8StringEncoding error:nil];
    
    //find all .html file */
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.html'"];
    NSArray *onlyHTMLs = [dirContents filteredArrayUsingPredicate:fltr];

    for (NSString *HTMLFile in onlyHTMLs) {
        NSMutableString *configRUUnitContent_m = [configRUUnitContent mutableCopy];
        [configRUUnitContent_m replaceOccurrencesOfString:@"_FILENAME_MAP_" withString:HTMLFile options:0 range:NSMakeRange(0, configRUUnitContent_m.length)];
        [configRUUnitContent_m replaceOccurrencesOfString:@"_FILENAME_SRC_" withString:HTMLFile options:0 range:NSMakeRange(0, configRUUnitContent_m.length)];
        [configRUContent appendString:configRUUnitContent_m];
        [configRUContent appendString:@"\n"];
    }
    
    //write file at path
    NSString *writeFilePath = [path stringByAppendingPathComponent:@"config.ru"];
    [configRUContent writeToFile:writeFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
#endif
    /* Folowing is for PHP-upload */
    //unzip composer.zip
    NSString *composerZipPath = [[NSBundle mainBundle] pathForResource:@"composer" ofType:@"zip"];
    [[JDFileUtil util] unzip:composerZipPath toDirectory:path createDirectory:NO];
    
    NSString* indexPhpPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"php"];
    NSString *indexPhpTargetPath = [path stringByAppendingPathComponent:@"index.php"];
    NSError *err;
    [[NSFileManager defaultManager] copyItemAtPath:indexPhpPath toPath:indexPhpTargetPath error:&err];
    NSLog([err description], nil);
    
    /* Add Heroku key */
    NSString *herokuKeyAddPath = [[NSBundle mainBundle] pathForResource:@"heroku_keysadd" ofType:@"sh"];
    [JDShellUtil execute:herokuKeyAddPath];
}

+ (NSString*)herokuAppNameAtPath:(NSString*)path{
    NSString *stdOut;
    NSString *stdErr;
    [JDShellUtil execute:@"/usr/bin/heroku" atDirectory:path arguments:@[@"config"] stdOut:&stdOut stdErr:&stdErr];
 
    if ([stdErr containsString:@"No app specified"]) {
        return nil;
    }
    else {
        return [[stdOut componentsSeparatedByString:@" "] firstObject];
    }
}

+(NSString*)configMessageForPath:(NSString*)path{
    NSString *stdOut;
    NSString *stdErr;
    [JDShellUtil execute:@"/usr/bin/heroku" atDirectory:path arguments:@[@"config"] stdOut:&stdOut stdErr:&stdErr];
    NSMutableString *retStr = [NSMutableString string];
    [retStr appendString:stdOut];
    [retStr appendString:stdErr];
    return [retStr copy];
}


@end
