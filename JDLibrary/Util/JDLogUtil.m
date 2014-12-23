//
//  JDLogUtil.m
//  Mango
//
//  Created by JD on 13. 2. 6..
/// Copyright (c) 2004-2013, JDLab  / Yang Joodong
/// All rights reserved. Licensed under the GPL.
/// See the GNU General Public License for more details. (/LICENSE)

//

#import "JDLogUtil.h"

//set level!
static JDLog_Level globalLogLevel = JDLog_Level_Trace;
static BOOL addLevel;
static BOOL addFileName;
static BOOL addFunctionName;
static BOOL addLineNumber;

const char *const _jd_level_names[] = {
	"Off",
	"Fatal",
	"Error",
	"Warning",
	"Info",
	"Debug",
	"Trace"
};

const char *const _jd_level_short_names[] = {
	"-",
	"F",
	"E",
	"W",
	"I",
	"D",
	"T"
};

static NSCountedSet *enableLogSection;

@implementation JDLogUtil

#if JDLOGGING

+(void)log:(int)atLevel fromFile:(NSString *)theFile fromFunction:(const char [])theFunction fromLine:(int)theLine withMessage:(NSString *)theMessage {

    if (globalLogLevel < atLevel || atLevel == JDLog_Off) {
		return;
	}
	
	NSMutableString *add = [[NSMutableString alloc] init];
	if(addLevel){
		[add appendString:[NSString stringWithFormat:@"[%s] ", _jd_level_names[atLevel]]];
	}
	
	if(addFileName){
		[add appendString:theFile];
		[add appendString:@":"];
	}
	
    if(addFunctionName){
        [add appendString:[NSString stringWithFormat:@"%s", theFunction]];
        [add appendString:@" "];
    }
    
	if(addLineNumber){
		[add appendString:[NSString stringWithFormat:@"%i ", theLine]];
	}
	
	if([add length] > 0){
		[add appendString:@"- "];
	}
    
	NSString *msg = [NSString stringWithFormat:@"%@%@", add, theMessage];
    
    char *xcode_colors = getenv("XcodeColors");
    if (xcode_colors && (strcmp(xcode_colors, "YES") == 0))
    {
        switch ((JDLog_Level)atLevel) {
            case JDLog_Level_Fatal://red bg
                NSLog(XCODE_COLORS_ESCAPE @"bg220,0,0;" @"%@" XCODE_COLORS_RESET, msg);
                break;
            case JDLog_Level_Error://red fg
                NSLog(XCODE_COLORS_ESCAPE @"fg220,0,0;" @"%@" XCODE_COLORS_RESET, msg);
                break;
            case JDLog_Level_Warn://green fg
                NSLog(XCODE_COLORS_ESCAPE @"fg0,255,0;" @"%@" XCODE_COLORS_RESET, msg);
                break;
            case JDLog_Level_Info://dark yellow
                NSLog(XCODE_COLORS_ESCAPE @"fg102,102,0;" @"%@" XCODE_COLORS_RESET, msg);
                break;
            case JDLog_Level_Debug://light gray fg
                NSLog(XCODE_COLORS_ESCAPE @"fg200,200,200;" @"%@" XCODE_COLORS_RESET, msg);
                break;
            case JDLog_Level_Trace:
                NSLog(@"%@", msg);
                break;
            default:
                break;
        }
    }
    else{
        NSLog(@"%@", msg);
    }
    
}

#pragma mark -
#pragma mark support logSection

+(void)sectionLog:(NSString *)section level:(int)atLevel fromFile:(NSString *)theFile fromFunction:(const char [])theFunction fromLine:(int)theLine withMessage:(NSString *)theMessage{
    
    if([enableLogSection containsObject:section]){
        NSString *sectionMessage = [NSString stringWithFormat:@"[%@] %ld : %@", section, [enableLogSection countForObject:section], theMessage];
        [self log:atLevel fromFile:theFile fromFunction:theFunction fromLine:theLine withMessage:sectionMessage];
        [enableLogSection addObject:section];
    }
    
}

#pragma mark direct call method 

+(void)enableLogSection:(NSString*)logSection{
    if (enableLogSection == nil) {
        enableLogSection = [NSCountedSet set];
    }
    [enableLogSection addObject:logSection];
}


+(void)log:(NSString*)logSection key:(NSString*)key string:(NSString*)log{
    if ([enableLogSection containsObject:logSection]) {
        
        JDInfoLog(@"[%@] %@ : %@", logSection, key, log);
    }
}

+(void)log:(NSString *)logSection string:(NSString *)string{
    if ([enableLogSection containsObject:logSection]) {
        JDInfoLog(@"[Log] %@ %ld : %@", logSection, [enableLogSection countForObject:logSection], string);
        [enableLogSection addObject:logSection];
    }
}

+(void)log:(NSString*)logSection key:(NSString*)key frame:(NSRect)frame{
    if ([enableLogSection containsObject:logSection]) {
        JDInfoLog(@"[%@] %@ : fr <%.2f,%.2f,%.2f,%.2f>", logSection, key, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    }
}

+(void)log:(NSString*)logSection key:(NSString*)key point:(NSPoint)point{
    if ([enableLogSection containsObject:logSection]) {
        JDInfoLog(@"[%@] %@ : pt: <%.1f, %.1f>", logSection, key, point.x, point.y);
    }
}

+(void)log:(NSString*)logSection key:(NSString*)key size:(NSSize)size{
    if ([enableLogSection containsObject:logSection]) {
        JDInfoLog(@"[%@] %@ : sz: <%.1f, %.1f>", logSection, key, size.width, size.height);
    }
}

+(void)log:(NSString*)key err:(NSError*)err{
        JDInfoLog(@"%@: ERR %@",key, err.localizedFailureReason);
}

+(void)alert:(NSString*)alertMsg{
    [self alert:alertMsg title:@"Alert"];
}

+(void)alert:(NSString*)alertMsg title:(NSString*)title{
    if ([alertMsg length] > 401) {
        alertMsg = [alertMsg substringToIndex:400];
    }

    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSAlert *alert = [NSAlert init];
        [alert setMessageText:title];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    });
}

+ (NSMutableDictionary *)watches {
    static NSMutableDictionary *Watches = nil;
    static dispatch_once_t OnceToken;
    dispatch_once(&OnceToken, ^{
        Watches = @{}.mutableCopy;
    });
    return Watches;
}

+ (double)secondsFromMachTime:(uint64_t)time {
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    return (double)time * (double)timebase.numer /
    (double)timebase.denom / 1e9;
    
}

+ (void)timeLogStart:(NSString *)name {
    uint64_t begin = mach_absolute_time();
    self.watches[name] = @(begin);
    JDTraceLog(@"timeLog Start %@", name);
    
}

+ (void)timeLogEnd:(NSString *)name {
    uint64_t end = mach_absolute_time();
    uint64_t begin = [self.watches[name] unsignedLongLongValue];
    double elapse = [self secondsFromMachTime:(end - begin)];
    if(elapse > 0.03){
        JDFatalLog(@"Time taken for %@ %g s",
                   name, elapse);
    }
    else{
        JDTraceLog(@"Time taken for %@ %g s",
                   name, elapse);
    }
    [self.watches removeObjectForKey:name];
}

#else

+(void)log:(int)atLevel fromFile:(NSString *)theFile fromFunction:(const char [])theFunction fromLine:(int)theLine withMessage:(NSString *)theMessage{}
+(void)sectionLog:(NSString *)section level:(int)atLevel fromFile:(NSString *)theFile fromFunction:(const char [])theFunction fromLine:(int)theLine withMessage:(NSString *)theMessage{}

+(void)enableLogSection:(NSString*)logSection{}
+(void)log:(NSString*)logSection key:(NSString*)key string:(NSString*)log{}
+(void)log:(NSString*)logSection key:(NSString*)key frame:(NSRect)frame{}
+(void)log:(NSString*)logSection key:(NSString*)key size:(NSSize)size{}
+(void)log:(NSString*)logSection key:(NSString*)key point:(NSPoint)point{}
+(void)log:(NSString*)key err:(NSError*)err{}
+(void)log:(NSString*)key string:(NSString *)string{}

+(void)alert:(NSString*)alertMsg{}
+(void)alert:(NSString*)alertMsg title:(NSString*)title{}
+(void)timeLogStart:(NSString *)name{}
+(void)timeLogEnd:(NSString *)name {}

#endif

+(void)setGlobalLevel:(JDLog_Level)level{
    globalLogLevel = level;
}


+(void)showLogLevel:(BOOL)showLevel andFileName:(BOOL)showFileName andFunctionName:(BOOL)showFunctionName  andLineNumber:(BOOL)showLineNumber{
	addLevel = showLevel;
	addFileName = showFileName;
    addFunctionName = showFunctionName;
	addLineNumber = showLineNumber;
}



@end
