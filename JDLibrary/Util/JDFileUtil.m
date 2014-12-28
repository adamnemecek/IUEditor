//
//  JDFileUtil.m
//  Mango
//
//  Created by JD on 13. 2. 6..
/// Copyright (c) 2004-2013, JDLab  / Yang Joodong
/// All rights reserved. Licensed under the GPL.
/// See the GNU General Public License for more details. (/LICENSE)

//

#import "JDFileUtil.h"
#import "JDShellUtil.h"

static JDFileUtil *sharedJDFileUtill;

@implementation JDFileUtil

+(JDFileUtil*)util{
    if (sharedJDFileUtill == nil){
        sharedJDFileUtill = [[JDFileUtil alloc] init];
    }
    return sharedJDFileUtill;
}


-(id)init{
    self = [super init];
    if (self) {
        shellCommandDict = [NSMutableDictionary dictionary];
    }
    return self;
}



+(BOOL)isFileImage:(NSURL*)url{
    NSString *file = [url absoluteString];
    CFStringRef fileExtension = (__bridge CFStringRef) [file pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
    if (UTTypeConformsTo(fileUTI, kUTTypeImage)){
        CFRelease(fileUTI);
        return YES;
    }
    CFRelease(fileUTI);
    return NO;
} 


+(void)rmDirPath:(NSString*)path{
    [JDShellUtil execute:@"/bin/mv" atDirectory:@"/" arguments:@[path, [@"~/.Trash" stringByExpandingTildeInPath]] stdOut:nil stdErr:nil];
}

+(BOOL)touch:(NSString*)filePath{
    NSInteger resultCode = [JDShellUtil execute:@"/usr/bin/touch" atDirectory:@"/" arguments:@[filePath] stdOut:nil stdErr:nil];
    return !resultCode;
}



-(NSURL*)openFileByNSOpenPanel{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanCreateDirectories:YES];

    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [panel runModal] == NSModalResponseOK ){
        return [[panel URLs] objectAtIndex:0];
    }
    
    return nil;

}

-(NSURL*)openFileByNSOpenPanel:(NSString*)title withExt:(NSArray*)extensions{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanCreateDirectories:YES];
    if (title != nil) {
        [panel setTitle:title];
    }
    [panel setAllowedFileTypes:extensions];

    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [panel runModal] == NSModalResponseOK ){
        return [[panel URLs] objectAtIndex:0];
    }
        
    return nil;
}


-(NSURL*)openDirectoryByNSOpenPanelWithTitle:(NSString*)title{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanCreateDirectories:YES];
    
    if (title != nil) {
        [openDlg setTitle:title];
    }
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    //openDlg.directoryURL = nil;
    //openDlg.nameFieldStringValue = @"";
    if ( [openDlg runModal] == NSModalResponseOK ){
        return [[openDlg URLs] objectAtIndex:0];
    }
    return nil;
}


-(NSURL*)openDirectoryByNSOpenPanel{
    return [self openDirectoryByNSOpenPanelWithTitle:nil];
}

- (NSURL *)openSavePanelWithAllowFileTypes:(NSArray *)fileTypes withTitle:(NSString *)title{
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    [savePanel setAllowsOtherFileTypes:NO];
    [savePanel setCanSelectHiddenExtension:YES];
    [savePanel setAllowedFileTypes:fileTypes];
    [savePanel setCanCreateDirectories:YES];
    
    if(title){
        [savePanel setTitle:title];
    }
    
    if([savePanel runModal] == NSModalResponseOK){
        return [savePanel URL];
    }
    return nil;
}





-(BOOL) appendToFile:(NSString*)path content:(NSString*)content{
    NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    if (myHandle == nil){
        JDErrorLog(@"Failed to open file");
        return NO;
    }

    NSData *theData = [content dataUsingEncoding:NSUTF8StringEncoding];
    [myHandle seekToEndOfFile];
    [myHandle writeData:theData];
    [myHandle closeFile];
    return YES;
}

-(BOOL)overwriteBundleItem:(NSString *)filename toDirectory:(NSString *)directoryPath error:(NSError **)error{
    NSError *result;
    NSString *resourceFilePath =[[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]];
    NSString *newFilePath      =[directoryPath stringByAppendingFormat:@"/%@",filename];
    if([[NSFileManager defaultManager] fileExistsAtPath:newFilePath]){
        [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:&result];
    }
    [[NSFileManager defaultManager] copyItemAtPath:resourceFilePath toPath:newFilePath error:&result];
    if (result) {
        JDErrorLog(@"%@", [result description]);
        return NO;
    }
    return YES;
}

-(BOOL)copyBundleItem:(NSString *)filename toDirectory:(NSString *)directoryPath{
    NSError *result;
    
    NSString *resourceFilePath =[[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]];
    NSString *newFilePath      =[directoryPath stringByAppendingFormat:@"/%@",filename];
    [[NSFileManager defaultManager] copyItemAtPath:resourceFilePath toPath:newFilePath error:&result];
    if (result) {
        JDErrorLog(@"%@", [result description]);
        return NO;
    }
    return YES;
}

- (BOOL) unzipResource:(NSString*)resource toDirectory:(NSString*)path createDirectory:(BOOL)createDirectory{
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:[resource stringByDeletingPathExtension] ofType:[resource pathExtension]];
    if (resourcePath == nil) {
        return NO;
    }
    [self unzip:resourcePath toDirectory:path createDirectory:createDirectory];
    return YES;
}


- (BOOL) unzip:(NSString*)filePath toDirectory:(NSString*)path createDirectory:(BOOL)createDirectory{
    //directory create
    if (createDirectory) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                                   attributes:nil error:NULL];
    }

    //now create a unzip-task
    NSArray *arguments = @[@"-o", filePath];
    NSTask *unzipTask = [[NSTask alloc] init];
    [unzipTask setLaunchPath:@"/usr/bin/unzip"];
    [unzipTask setCurrentDirectoryPath:path];
    [unzipTask setArguments:arguments];
    [unzipTask launch];
    [unzipTask waitUntilExit];
    return YES;
}


+(BOOL)isImageFileExtension:(NSString*)extension{
    NSString *lowerExtension = [extension lowercaseString];
    if ([lowerExtension isEqualToString:@"gif"] || [lowerExtension isEqualToString:@"jpg"] || [lowerExtension isEqualToString:@"jpeg"] || [lowerExtension isEqualToString:@"png"] || [lowerExtension isEqualToString:@"ico"]) {
        return YES;
    }
    return NO;
}

+(BOOL)isMovieFileExtension:(NSString*)extension{
    NSString *lowerExtension = [extension lowercaseString];
    if ([lowerExtension isEqualToString:@"mp4"] || [lowerExtension isEqualToString:@"mov"]) {
        return YES;
    }
    return NO;
}



@end
