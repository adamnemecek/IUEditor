//
//  LMStartTemplateVC.m
//  IUEditor
//
//  Created by jd on 5/2/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMStartTemplateVC.h"
#import "JDFileUtil.h"
#import "IUProjectController.h"
#import "LMAppDelegate.h"
#import "LMWC.h"
#import "LMStartItem.h"
#import "LMStartPreviewWC.h"

@interface LMStartTemplateVC ()

@end

@implementation LMStartTemplateVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}


-(void)awakeFromNib{
    [super awakeFromNib];
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"sampleTemplate" ofType:@"plist"];
    NSArray *templateList = [NSArray arrayWithContentsOfFile:templatePath];
    
    for(NSDictionary *dict in templateList){
        BOOL isReady = [[dict objectForKey:@"isReady"] boolValue];
        if(isReady){
            LMStartItem *item = [[LMStartItem alloc] initWithDict:dict];
            [_templateAC addObject:item];
        }
    }
    
    
    [self.templateAC setSelectionIndex:0];
}
- (IBAction)pressSelectBtn:(id)sender {
    
    LMStartPreviewWC *preview = [LMStartPreviewWC sharedStartPreviewWindow];
    [preview close];

    if(self.templateAC.selectedObjects.count <=0){
     return;
    }
    
    NSArray *selectedProject = self.templateAC.selectedObjects;
    LMStartItem *item = selectedProject[0];
    
    NSURL *url = [[JDFileUtil util] openDirectoryByNSOpenPanelWithTitle:@"Select Directory"];
    if (url == nil) {
        return;
    }
    
    NSURL *targetURL = [url URLByAppendingPathComponent:item.fileName];
    NSString *targetPath = [targetURL path];
    if([[NSFileManager defaultManager] fileExistsAtPath:targetPath]){
        [JDUIUtil hudAlert:@"There is already same IU Document, Choose another directory" second:2];
        return;
    }
    
    
    [[JDFileUtil util] unzipResource:item.packagePath toDirectory:targetPath createDirectory:YES];
    
    NSURL *openURL = [[[NSURL fileURLWithPath:targetPath] URLByAppendingPathComponent:item.fileName ] URLByAppendingPathExtension:@"iu"];
    [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:openURL display:YES completionHandler:nil];
    [self.view.window close];

 }

- (void)pressPreviewBtn:(LMStartItem *)clickedItem {
    LMStartPreviewWC *preview = [LMStartPreviewWC sharedStartPreviewWindow];
    BOOL loaded = [preview loadStartItem:clickedItem];
    if(loaded){
        [preview showWindow:self];
    }
}

- (void)keyDown:(NSEvent *)theEvent{
    unsigned short keyCode = theEvent.keyCode;//keyCode is hardware-independent
    if(keyCode == IUKeyCodeEnter){
        [self pressSelectBtn:theEvent];
    }
    else if (keyCode >= IUKeyCodeOne && keyCode <= IUKeyCodeThree){
        [[self.view window] keyDown:theEvent];
    }
    
}


@end
