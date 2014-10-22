//
//  LMStartPreviewWC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 6. 30..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMStartPreviewWC.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


static LMStartPreviewWC *gStartPreviewWindow = nil;

@interface LMStartPreviewWC ()

@property (weak) IBOutlet NSScrollView *imageScrollView;

@property (weak) IBOutlet NSTextField *nameTF;
@property (weak) IBOutlet NSTextField *descTF;
@property (weak) IBOutlet NSTextField *projectTypeTF;
@property (weak) IBOutlet NSTextField *sizeTF;
@property (weak) IBOutlet NSTextField *featureTF;

@property (weak) IBOutlet NSButton *prevBtn;
@property (weak) IBOutlet NSButton *nextBtn;
@property (weak) IBOutlet NSTextField *countTF;

@property (weak) IBOutlet NSTabView *tabView;
@property NSImageView *imageView;
@property (weak) IBOutlet AVPlayerView *videoView;

@end

@implementation LMStartPreviewWC{
    NSInteger currentCount;
    LMStartItem *currentItem;

}

+ (LMStartPreviewWC *)sharedStartPreviewWindow{
    if(gStartPreviewWindow ==  nil){
        gStartPreviewWindow = [[LMStartPreviewWC alloc] initWithWindowNibName:@"LMStartPreviewWC"];
    }
    
    return gStartPreviewWindow;
}

- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [_imageScrollView setDocumentView:_imageView];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self updateWindowValue];
}

- (void)awakeFromNib{

}

- (void)updateWindowValue{
    if(currentItem){
        
        [_nameTF setStringValue:currentItem.name];
        [_descTF setStringValue:currentItem.desc];
        
        switch (currentItem.projectType) {
            case IUProjectTypeDefault:
                [_projectTypeTF setStringValue:@"Default"];
                break;
            case IUProjectTypeDjango:
                [_projectTypeTF setStringValue:@"Django"];
                break;
            case IUProjectTypePresentation:
                [_projectTypeTF setStringValue:@"Presentation"];
                break;
            default:
                NSAssert(0, @"");
                break;
        }
        
        [_sizeTF setStringValue:currentItem.mqSizes];
        [_featureTF setStringValue:currentItem.feature];
        
        [self updatePreview];
    }
}


- (BOOL)loadStartItem:(LMStartItem *)item{
    if(item){
        currentItem = item;
        currentCount = 1;
        
        [self updateWindowValue];
        return YES;
    }
    return NO;

}
- (IBAction)clickNextBtn:(id)sender {
    if(currentCount <= currentItem.previewImageArray.count + currentItem.previewVideoArray.count){
        currentCount++;
    }
    [self updatePreview];
}

- (IBAction)clickPrevBtn:(id)sender {
    if(currentCount > 1){
        currentCount--;
    }
    [self updatePreview];
    
}

- (void)showWindow:(id)sender{
    [super showWindow:sender];
    
    [[_imageScrollView contentView] scrollToPoint:NSMakePoint(0, [[_imageView image] size].height)];
    [_imageScrollView reflectScrolledClipView:[_imageScrollView contentView]];

}

- (void)updatePreview{
    
    NSInteger totalCount = currentItem.previewVideoArray.count + currentItem.previewImageArray.count;
    [_countTF setStringValue:[NSString stringWithFormat:@"%ld/%ld", currentCount, totalCount]];

    
    if(currentCount <= currentItem.previewImageArray.count){
        [_tabView selectTabViewItemAtIndex:0];
        NSImage *image = [NSImage imageNamed:currentItem.previewImageArray[currentCount-1]];
        [_imageView setImage:image];
    }
    else if(currentCount <= totalCount){
        [_tabView selectTabViewItemAtIndex:1];
        NSInteger videoCount = currentCount - currentItem.previewImageArray.count-1;
        NSString *videoName = currentItem.previewVideoArray[videoCount];
        NSString *videoPath = [[NSBundle mainBundle] pathForResource:[videoName stringByDeletingPathExtension] ofType:[videoName pathExtension]];
        NSURL *url = [NSURL fileURLWithPath:videoPath];
        if(url){
            AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
            if(item){
                _videoView.player = [AVPlayer playerWithPlayerItem:item];
                [_videoView.player play];
            }
        }

    }

}





@end
