//
//  LMResourceVC.m
//  IUEditor
//
//  Created by JD on 3/31/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMResourceVC.h"
#import "IUResourceFile.h"
#import "LMHelpPopover.h"

@interface LMResourceVC ()
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSCollectionView *collectionListV;
@property (weak) IBOutlet NSCollectionView *collectionIconV;

@property (weak) IBOutlet NSButton *resourceListB;
@property (weak) IBOutlet NSButton *resourceIconB;
@property (strong) IBOutlet NSArrayController *resourceArrayController;

@end

@implementation LMResourceVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)awakeFromNib{
    [_resourceArrayController bind:NSContentArrayBinding toObject:self withKeyPath:@"manager.imageAndVideoFiles" options:nil];
    [_collectionListV bind:NSContentBinding toObject:_resourceArrayController withKeyPath:@"arrangedObjects" options:nil];
    [_collectionIconV bind:NSContentBinding toObject:_resourceArrayController withKeyPath:@"arrangedObjects" options:nil];
}

#pragma mark - trash delegate
#if 0
- (void)draggingDropedForDragAndDropImageV:(LMDragAndDropButton *)v item:(id)item{
    IUResourceFile *file = [_manager resourceFileWithName:item];
    [self.manager removeResourceFile:file];
}
#endif


#pragma mark - collectionView Drag

- (BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard{
    if([indexes count] == 1){
        NSUInteger index = [indexes firstIndex];
        IUResourceFile *node = [[_resourceArrayController arrangedObjects] objectAtIndex:index];
        if(node.type == IUResourceTypeImage){
            [pasteboard setString:node.name forType:kUTTypeIUImageResource];
            return YES;
        }
        
        else if (node.type == IUResourceTypeVideo){
            [JDUIUtil hudAlert:@"Sorry, Movie File is not draggable" second:2];
        }
        else {
            NSAssert(0, @"");
        }
    }

    return NO;
}


- (NSImage *)collectionView:(NSCollectionView *)collectionView draggingImageForItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event offset:(NSPointPointer)dragImageOffset{
    
    NSUInteger index = [indexes firstIndex];
    IUResourceFile *node = [[_resourceArrayController arrangedObjects] objectAtIndex:index];
    
    return node.image;
}



#pragma mark -
#pragma mark click BTN

- (IBAction)clickListBtn:(id)sender {
    [_tabView selectTabViewItemAtIndex:0];
    [_resourceListB setEnabled:NO];
    [_resourceIconB setEnabled:YES];
}
- (IBAction)clickIconBtn:(id)sender {
    [_tabView selectTabViewItemAtIndex:1];
    [_resourceListB setEnabled:YES];
    [_resourceIconB setEnabled:NO];
}


- (IBAction)clickRefreshBtn:(id)sender {
    [_resourceArrayController rearrangeObjects];
}

- (IBAction)clickTrashBtn:(id)sender {
    NSCollectionView *collectionV = [self currentCollectionView];
    if(collectionV){
        
        NSMutableArray *removedFiles = [NSMutableArray array];
        NSUInteger index = [[collectionV selectionIndexes] firstIndex];
        NSUInteger lastIndex = index;
        while(index != NSNotFound && index < [collectionV content].count){
            IUResourceFile *resourceFile = [[collectionV itemAtIndex:index] representedObject];
            [removedFiles addObject:resourceFile];
            lastIndex = index;
            index = [[collectionV selectionIndexes] indexGreaterThanIndex:index];
            
        }
        
        for(IUResourceFile *resourceFile in removedFiles){
            [self.manager removeResourceFile:resourceFile];
        }
        if(lastIndex > 0 && lastIndex-1 < [collectionV content].count){
            [collectionV setSelectionIndexes:[NSIndexSet indexSetWithIndex:lastIndex-1]];
        }
        else if(lastIndex == 0 && [collectionV content].count > 0){
            [collectionV setSelectionIndexes:[NSIndexSet indexSetWithIndex:lastIndex]];
        }
    
    }

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


#pragma mark - 
#pragma mark addResource

- (IBAction)clickAddResourceBtn:(id)sender {
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setAllowsMultipleSelection:YES];
    openDlg.delegate = self;
    
    //FIXME : speed up!!!
    if([openDlg runModal]){
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg URLs];
        
        for(int i = 0; i < [files count]; i++ )
        {
            NSURL* filePath = [files objectAtIndex:i];
            NSString *filename = [filePath lastPathComponent];
            NSImage *image = [NSImage imageNamed:filename];
            if (image) {
                JDDebugLog(@"%@ is already existed", filename);
            }
            
            
            [_manager insertResourceWithContentOfPath:[filePath path]];
        }
    }
    
    [_resourceArrayController rearrangeObjects];
}

- (void)addResource:(NSURL *)url type:(IUResourceType)type{
    [_manager insertResourceWithContentOfPath:[url relativePath]];
}

#pragma mark - openpanel delegate
- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
    NSString *fileName = [url lastPathComponent];
    IUResourceFile *existedFile = [_manager resourceFileWithName:fileName];
    if (existedFile) {
        return NO;
    }
    
    return YES;
}

#pragma mark - mouse Event

- (void)doubleClick:(id)sender{
    
    NSView *targetView = (id)sender;
    NSCollectionView *currentCollectionView = (NSCollectionView *)[targetView superview];
    if([currentCollectionView isKindOfClass:[NSCollectionView class]]){
        
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
    }
    else{
        NSAssert(0, @"");
    }
    
}

- (void)rightMouseDown:(id)sender theEvent:(NSEvent *)theEvent{
    NSView *targetView = (id)sender;
    NSCollectionView *currentCollectionView = (NSCollectionView *)[targetView superview];
    if([currentCollectionView isKindOfClass:[NSCollectionView class]]){
        
        NSMenu *collectionMenu = [[NSMenu alloc] initWithTitle:@"collectionMenu"];
        NSMenuItem *removeMenu = [[NSMenuItem alloc] initWithTitle:@"Remove" action:@selector(removeResourceItem:) keyEquivalent:@""];
        [collectionMenu addItem:removeMenu];
        removeMenu.target = self;
        
        if([[currentCollectionView selectionIndexes] count] > 0){
            NSUInteger index = [[currentCollectionView selectionIndexes] firstIndex];
            IUResourceFile *resourceFile = [[currentCollectionView itemAtIndex:index] representedObject];
            removeMenu.representedObject = resourceFile;
            
            [NSMenu popUpContextMenu:collectionMenu withEvent:theEvent forView:sender];
        }
        
        
    }
    else{
        NSAssert(0, @"");
    }
}

- (void)removeResourceItem:(NSMenuItem *)sender{
    IUResourceFile *resourceFile = sender.representedObject;
    [self.manager removeResourceFile:resourceFile];
}

- (void)prepareDealloc{
    [_resourceArrayController unbind:NSContentArrayBinding];
}

- (void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"LMResourceVC"];
}

@end