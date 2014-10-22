//
//  LMClipArtVC.m
//  IUEditor
//
//  Created by G on 2014. 7. 23..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMClipArtVC.h"
#import "LMHelpPopover.h"
#import "ClipArt.h"

@interface LMClipArtVC ()


@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSCollectionView *collectionListV;
@property (weak) IBOutlet NSCollectionView *collectionIconV;

@property (weak) IBOutlet NSButton *clipartListB;
@property (weak) IBOutlet NSButton *clipartIconB;
@property (strong) IBOutlet NSArrayController *clipArtArrayController;


@end

@implementation LMClipArtVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}


-(void)awakeFromNib{
    [self initClipArtInfo];
}

- (void)initClipArtInfo{
    
    //get the path of plist file
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"clipArtList" ofType:@"plist"];
    NSDictionary *clipArtDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];

    for(NSDictionary *dict in clipArtDict.allValues){
        ClipArt *clip = [[ClipArt alloc] init];
        clip.title = [dict objectForKey:@"title"];
        clip.tag = [dict objectForKey:@"tag"];
        clip.image = [NSImage imageNamed:clip.title];
        [self.clipArtArrayController addObject:clip];
    }
    //sort the clipArts
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject: sorter];
    [self.clipArtArrayController setSortDescriptors:sortDescriptors];
}


#pragma mark - collectionView Drag

- (BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard{
    
    //get copy from selected item
    if([self.clipArtArrayController selectedObjects].count > 1 ){
        return NO;
    }
    ClipArt *copiedClip = [[self.clipArtArrayController selectedObjects] objectAtIndex:0];
    NSString * titleWithDir = [@"clipArt" stringByAppendingPathComponent:copiedClip.title];

    [pasteboard setString:titleWithDir forType:kUTTypeIUImageResource];
    
    return YES;
}

-(BOOL) collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event {
    return YES;
}

- (NSImage *)collectionView:(NSCollectionView *)collectionView draggingImageForItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event offset:(NSPointPointer)dragImageOffset{
    
    ClipArt *copiedClip = [[self.clipArtArrayController selectedObjects] objectAtIndex:0];
    return copiedClip.image;
}



#pragma mark -
#pragma mark click BTN

- (IBAction)clickListBtn:(id)sender {
    [_tabView selectTabViewItemAtIndex:0];
    [_clipartListB setEnabled:NO];
    [_clipartIconB setEnabled:YES];
}
- (IBAction)clickIconBtn:(id)sender {
    [_tabView selectTabViewItemAtIndex:1];
    [_clipartListB setEnabled:YES];
    [_clipartIconB setEnabled:NO];
}

- (NSCollectionView *)currentCollectionView{
    NSInteger selectedIndex = [_tabView indexOfTabViewItem:[_tabView selectedTabViewItem]];
    
    if(selectedIndex == 0){
        return _collectionListV;
    }
    else if(selectedIndex ==1){
        return _collectionIconV;
    }
    return nil;
}


#pragma mark - mouse Event

- (void)doubleClick:(id)sender{
    
    NSView *targetView = (id)sender;
    NSCollectionView *currentCollectionView = (NSCollectionView *)[targetView superview];
    if([currentCollectionView isKindOfClass:[NSCollectionView class]]){
     /*
        NSUInteger index = [[currentCollectionView selectionIndexes] firstIndex];
        IUResourceFile *resourceFile = [[currentCollectionView itemAtIndex:index] representedObject];
        
        
        if(resourceFile.type == IUResourceTypeImage){
            
            
            LMHelpPopover *popover = [LMHelpPopover sharedHelpPopover];
            [popover setType:LMPopoverTypeText];
            NSString *imageSize = [NSString stringWithFormat:@"Size : %.1f x %.1f", resourceFile.image.size.width, resourceFile.image.size.height];
            [popover setTitle:resourceFile.name text:imageSize];
            [popover showRelativeToRect:[targetView bounds] ofView:sender preferredEdge:NSMinXEdge];
        }
        else if(resourceFile.type == IUResourceTypeVideo){
            LMHelpPopover *popover = [LMHelpPopover sharedHelpPopover];
            [popover setType:LMPopoverTypeTextAndVideo];
            [popover setVideoName:resourceFile.name title:resourceFile.name rtfFileName:nil];
            [popover showRelativeToRect:[targetView bounds] ofView:sender preferredEdge:NSMinXEdge];
            
        }
      */
    }
    else{
        NSAssert(0, @"");
    }
    
}

@end
