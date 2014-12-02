
//
//  LMPropertyIUMovieVC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyIUMovieVC.h"
#import <AVFoundation/AVFoundation.h>
#import "IUImageUtil.h"


@interface LMPropertyIUMovieVC ()
@property (weak) IBOutlet NSComboBox *fileNameComboBox;
@property (weak) IBOutlet NSTextField *altTextTF;

@property (weak) IBOutlet NSButton *controlBtn;
@property (weak) IBOutlet NSButton *loopBtn;
@property (weak) IBOutlet NSButton *autoplayBtn;
@property (weak) IBOutlet NSButton *coverBtn;
@property (weak) IBOutlet NSButton *muteBtn;

@end

@implementation LMPropertyIUMovieVC{
    BOOL gettingInfo;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadView];
    }
    return self;
}


- (void)setController:(IUController *)controller{
    [super setController:controller];
    
//    [_fileNameComboBox bind:NSContentBinding toObject:self withKeyPath:@"resourceManager.videoFiles" options:IUBindingDictNotRaisesApplicable];
    [self outlet:_altTextTF bind:NSValueBinding property:@"altText"];
    [self outlet:_controlBtn bind:NSValueBinding property:@"enableControl"];
    [self outlet:_loopBtn bind:NSValueBinding property:@"enableLoop"];
    [self outlet:_autoplayBtn bind:NSValueBinding property:@"enableAutoPlay"];
    [self outlet:_coverBtn bind:NSValueBinding property:@"cover"];
    [self outlet:_muteBtn bind:NSValueBinding property:@"enableMute"];
    
    
    _fileNameComboBox.delegate = self;
    
    [self addObserver:self forKeyPath:@"controller.selectedObjects"
              options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:@"selection"];

}

- (void)prepareDealloc{
    [_fileNameComboBox unbind:NSContentBinding];
}

- (void)dealloc{
    if (self.controller) {
        _fileNameComboBox.delegate = nil;
        [self removeObserver:self forKeyPath:@"controller.selectedObjects" context:@"selection"];
    }
}

- (void)selectionContextDidChange:(NSDictionary *)change{
    id videoPath = [self valueForProperty:@"videoPath"];
    
    if(videoPath == nil || videoPath == NSNoSelectionMarker){
        [_fileNameComboBox setStringValue:@""];
    }
    else if(videoPath){
        NSString *videoFileName = [videoPath lastPathComponent];
        NSInteger index = [_fileNameComboBox indexOfItemWithObjectValue:videoFileName];
        if(index >= 0 && index < [_fileNameComboBox numberOfItems]){
            [_fileNameComboBox selectItemAtIndex:index];
        }
        else{
            [_fileNameComboBox setStringValue:videoPath];
        }
    }
}


- (void)controlTextDidChange:(NSNotification *)obj{
    NSComboBox *currentComboBox = obj.object;
    if([currentComboBox isEqualTo:_fileNameComboBox]){
        [self updateVideoFileName:[_fileNameComboBox stringValue]];
    }
}


- (void)comboBoxSelectionDidChange:(NSNotification *)notification{
    NSComboBox *currentComboBox = notification.object;
    if([currentComboBox isEqualTo:_fileNameComboBox]){
        [self updateVideoFileName:[_fileNameComboBox objectValueOfSelectedItem]];
    }
}
- (void)updateVideoFileName:(NSString *)videoFileName{
    JDErrorLog(@"update video file name not working");
    /*
    gettingInfo = YES;
    if(videoFileName.length == 0){
        [self setValue:nil forIUProperty:@"posterPath"];
        [self setValue:nil forIUProperty:@"videoPath"];
    }
    else if(videoFileName && videoFileName.length > 0
            && [JDFileUtil isMovieFileExtension:[videoFileName pathExtension]]){
        
        //get thumbnail from video file
        NSURL *moviefileURL;
        if ([videoFileName isHTTPURL]) {
            moviefileURL = [NSURL URLWithString:videoFileName];
            [self setValue:moviefileURL.absoluteString forIUProperty:@"videoPath"];
        }
        else{
            IUResourceFile *videoFile = [self.resourceManager resourceFileWithName:videoFileName];
            if (videoFile == nil) {
                
                [self setValue:nil forIUProperty:@"videoPath"];
                return;
            }
            moviefileURL = [NSURL fileURLWithPath:videoFile.absolutePath];
            
            NSString *relativePath = videoFile.relativePath;
            [self setValue:relativePath forIUProperty:@"videoPath"];
        }
        NSImage *thumbnail = [self thumbnailOfVideo:moviefileURL];
        
        if(thumbnail){
            //save thumbnail
            NSString *videoname = [[videoFileName lastPathComponent] stringByDeletingPathExtension];
            NSString *thumbFileName = [[NSString alloc] initWithFormat:@"%@_thumbnail.png", videoname];

            NSString *imageTmpAbsolutePath = NSTemporaryDirectory();

            thumbFileName = [IUImageUtil writeToFile:thumbnail filePath:imageTmpAbsolutePath fileName:thumbFileName checkFileName:NO];
            
            
            IUResourceFile *thumbFile = [_resourceManager resourceFileWithName:thumbFileName];
            if(thumbFile == nil){
                //save image resourceNode
                thumbFile = [_resourceManager insertResourceWithContentOfPath:[imageTmpAbsolutePath stringByAppendingPathComponent:thumbFileName]];
            }
            else{
                //overwirte image
                thumbFile = [_resourceManager overwriteResourceWithContentOfPath:[imageTmpAbsolutePath stringByAppendingPathComponent:thumbFileName]];
                
            }
            
            [self setValue:thumbFile.relativePath forIUProperty:@"posterPath"];
            
            
            
            
            [self setValue:@(thumbnail.size.width) forCSSTag:IUCSSTagPixelWidth];
            [self setValue:@(thumbnail.size.height) forCSSTag:IUCSSTagPixelHeight];
        }
        
    }
    */
}


-(NSImage *)thumbnailOfVideo:(NSURL *)url{
    
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url options:nil];
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
    CMTime actualTime;
    NSImage *thumbImg;
    
    CGImageRef halfWayImage = [generator copyCGImageAtTime:thumbTime actualTime:&actualTime error:nil];
    if(halfWayImage != NULL){
        thumbImg =[[NSImage alloc] initWithCGImage:halfWayImage size:NSZeroSize];
        CGImageRelease(halfWayImage);
        return thumbImg;
        
    }
    
    
    return nil;
    
}

@end
