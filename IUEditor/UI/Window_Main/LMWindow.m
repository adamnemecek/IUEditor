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

#import "BBCloseWC.h"
#import "JDMemoryCheck.h"

@implementation LMWindow{
    BBCloseWC *_closeWC;
}


#pragma mark -
#pragma mark mouse

- (void)awakeFromNib{
    
    NSButton *closeButton = [self standardWindowButton:NSWindowCloseButton];
    [closeButton setTarget:self];
    [closeButton setAction:@selector(performClose:)];
    

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
    
    if(_closeWC == nil){
        _closeWC = [[BBCloseWC alloc] initWithWindowNibName:[BBCloseWC className]];

    }
    
    [_closeWC setProjectName:[(BBWC *)[self windowController] projectName]];
    
    [self setAlphaValue:0.9];
    [self setIgnoresMouseEvents:YES];
    
    [self beginCriticalSheet:_closeWC.window completionHandler:^(NSModalResponse returnCode) {
        [_closeWC.window orderOut:nil];

        switch (returnCode) {
            case NSModalResponseOK:
                //save and close
                [self.windowController saveDocument:self];
                [self close];
                break;
            case NSModalResponseAbort:
                //don'tsave and close
                [self close];
                break;
            case NSModalResponseCancel:
                //cancel to close
                [self setIgnoresMouseEvents:NO];
                [self setAlphaValue:1.0];
            default:
                break;
        }
    }];
        
}

- (void)close{
    [IUIdentifierManager removeIdentifierManagerForWindow:self];
    [[JDMemoryChecker sharedChecker] fireMemoryCheckAfterDelay:5];
    [super close];
}


@end
