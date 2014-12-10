//
//  CanvasWindow.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 24..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "LMWindow.h"
#import "BBWC.h"
#import "LMCanvasView.h"

#import "JDUIUtil.h"
#import "JDLogUtil.h"
#import "LMCloseWC.h"


@implementation LMWindow{
    LMCloseWC *closeWC;
}


#pragma mark -
#pragma mark mouse

- (void)awakeFromNib{
    
    NSButton *closeButton = [self standardWindowButton:NSWindowCloseButton];
    [closeButton setTarget:self];
    [closeButton setAction:@selector(performClose:)];
    
     closeWC = [[LMCloseWC alloc] initWithWindowNibName:[LMCloseWC class].className];

}

- (BOOL)isMouseEvent:(NSEvent *)theEvent{
    if(theEvent.type == NSLeftMouseDown ||
       theEvent.type == NSRightMouseDown ||
       theEvent.type == NSLeftMouseDragged ||
       theEvent.type == NSLeftMouseUp
       ){
        return YES;
    }
    return NO;
}

- (BOOL)isKeyEvent:(NSEvent *)theEvent{
    if(theEvent.type == NSKeyDown){
        return YES;
    }
    return NO;
}

-(void)sendEvent:(NSEvent *)theEvent{
    
    BOOL callSuper = YES;
    
    if([self isMouseEvent:theEvent]){
        [(LMCanvasView *)self.canvasVC.view receiveMouseEvent:theEvent];
    }
    if([self isKeyEvent:theEvent]){
        callSuper = [(LMCanvasView *)self.canvasVC.view receiveKeyEvent:theEvent];
    }
    
    if(callSuper){
        [super sendEvent:theEvent];
    }

}


#pragma mark - close

- (void)performClose:(id)sender{

    if([[self.windowController document] isDocumentEdited] == NO){
        [self close];
        return;
    }
    
    [closeWC setProjectName:[(BBWC *)[self windowController] projectName]];
    
    [self setAlphaValue:0.9];
    [self setIgnoresMouseEvents:YES];
    
    [self beginCriticalSheet:closeWC.window completionHandler:^(NSModalResponse returnCode) {
        [closeWC.window orderOut:nil];

        switch (returnCode) {
            case NSModalResponseOK:
                [self close];
                break;
            case NSModalResponseCancel:
                [self setIgnoresMouseEvents:NO];
                [self setAlphaValue:1.0];
            default:
                break;
        }
    }];
        
}


@end
