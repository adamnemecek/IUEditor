//
//  BBResourceLibraryVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBResourceLibraryVC.h"
#import "IUDocumentProtocol.h"

@interface BBResourceLibraryVC ()

@property (strong) IBOutlet NSTreeController *resourceTreeController;


@end

@implementation BBResourceLibraryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
}

#pragma mark - button action

- (IBAction)clickImportResourceButton:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:YES];

    if([openDlg runModal]){
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg URLs];
        NSMutableArray *validFilePaths = [NSMutableArray array];
        
        for(int i = 0; i < [files count]; i++ )
        {
            NSURL* filePath = [files objectAtIndex:i];
            NSString *filename = [filePath lastPathComponent];
            NSImage *image = [NSImage imageNamed:filename];
            if (image) {
                JDDebugLog(@"%@ is already existed", filename);
            }
            
            [validFilePaths addObject:[filePath path]];

        }
        
        [[self iuProjectDocument] addResourceFileItemPaths:validFilePaths];
    }
    
}


- (id<IUDocumentProtocol>)iuProjectDocument{
    return [[[NSApp mainWindow] windowController] document];
}

#pragma mark - ibaction

- (IBAction)clickRemoveResourceFileItem:(id)sender {
    for(IUResourceFileItem * fileItem in [_resourceTreeController selectedObjects]){
        [[self iuProjectDocument] removeResourceFileItem:fileItem];
    }
}

#pragma mark - outlineView delegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    
    IUResourceFileItem *resourceFile = [item representedObject];
    
    if([resourceFile isKindOfClass:[IUResourceGroupItem class]]){
        NSTableCellView *groupView = [outlineView makeViewWithIdentifier:@"resourceFolder" owner:self];
        if(resourceFile.name){
            [groupView.textField setStringValue:resourceFile.name];
        }
        return groupView;
    }
    else{
        NSTableCellView *imageView = [outlineView makeViewWithIdentifier:@"resourceImage" owner:self];
        [imageView.textField setStringValue:resourceFile.name];
        return imageView;
        
    }
    
}

@end
