//
//  LMMediaQueryVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 10. 29..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMMediaQueryVC.h"

@interface LMMediaQueryVC ()

@property (weak) IBOutlet NSButton *mqAddBtn;
@property (weak) IBOutlet NSPopUpButton *mqSelectPopUpButton;
@property (weak) IBOutlet NSPopover *addFramePopover;
@property (weak) IBOutlet NSTextField *addFrameSizeField;

@property (strong) IBOutlet NSArrayController *mqArrayController;

@end

@implementation LMMediaQueryVC{
    //mq
    NSInteger mqWidth;

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadView];
    }
    return self;
}

- (void)awakeFromNib{
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    [_mqArrayController setSortDescriptors:@[sort]];
}

- (NSWindowController *)currentWC{
    return [[self.view window] windowController];
}

- (void)loadWithMQWidths:(NSArray *)widthArray{
    [_mqArrayController addObjects:widthArray];
    //set default width as maximum width
    mqWidth = [[[_mqArrayController arrangedObjects] firstObject] integerValue];
    [_mqSelectPopUpButton selectItemAtIndex:0];
    [self selectMediaQueryWidth:mqWidth];
    [self changeMaxWidth];
}

#pragma mark - mq

- (IBAction)selectMediaQuery:(id)sender {
    NSInteger selectedWidth = [[[_mqSelectPopUpButton selectedItem] representedObject] integerValue];
    [self selectMediaQueryWidth:selectedWidth];
    
}
- (void)selectMediaQueryWidth:(NSInteger)width{
    NSInteger maxWidth = [[[_mqArrayController arrangedObjects] firstObject] integerValue];
    NSInteger largerWidth;
    if([_mqSelectPopUpButton indexOfSelectedItem] > 0){
        largerWidth = [[[_mqSelectPopUpButton itemAtIndex:[_mqSelectPopUpButton indexOfSelectedItem] -1] representedObject] integerValue];
    }
    else{
        largerWidth = maxWidth;
    }
    NSInteger oldSelectedWidth = mqWidth;
    mqWidth = width;
    [self.controller disableUpdateCSS:self];
    [self.controller disableUpdateJS:self];

    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQSelected object:[self currentWC] userInfo:@{IUNotificationMQSize:@(width), IUNotificationMQMaxSize:@(maxWidth)}];
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQSelectedWithInfo object:[self currentWC] userInfo:@{IUNotificationMQSize:@(width), IUNotificationMQMaxSize:@(maxWidth), IUNotificationMQLargerSize:@(largerWidth), IUNotificationMQOldSize:@(oldSelectedWidth)} ];
    
    [self.controller enableUpdateJS:self];
    [self.controller enableUpdateCSS:self];
}


- (IBAction)addMediaQuery:(id)sender {
    [self.addFramePopover showRelativeToRect:self.mqAddBtn.frame ofView:sender preferredEdge:NSMinYEdge];
}

- (IBAction)clickAddMqOkBtn:(id)sender {
    NSInteger newWidth = [self.addFrameSizeField integerValue];
    
    if(newWidth > 30000){
        [JDUIUtil hudAlert:@"It's too large, we support up to 30000px!" second:2];
        return ;
    }
    if(newWidth == 0){
        [JDUIUtil hudAlert:@"It's wrong size, input the positive number" second:2];
        return ;
    }
    
    [self addMQWidth:newWidth];
    
    

}


- (void)addMQWidth:(NSInteger)newWidth{
    NSNumber *widthNumber = [NSNumber numberWithInteger:newWidth];
    if([_mqSelectPopUpButton indexOfItemWithRepresentedObject:widthNumber] >= 0){
        [JDUIUtil hudAlert:@"Already Same Width, Here" second:2];
        return ;
    }
    
    [_mqArrayController addObject:@(newWidth)];
    [self.addFramePopover close];
    
    
    NSNumber *maxWidth = [[_mqArrayController arrangedObjects] firstObject];
    NSNumber *oldMaxWidth;
    BOOL isChangeMaxWidth = NO;
    
    if(newWidth == [maxWidth integerValue]){
        oldMaxWidth = [[_mqArrayController arrangedObjects] objectAtIndex:[_mqSelectPopUpButton numberOfItems]-2];
        isChangeMaxWidth = YES;
    }
    else{
        oldMaxWidth = maxWidth;
    }
    
    NSNumber *largerSize;
    NSInteger currentIndex = [_mqSelectPopUpButton indexOfItemWithRepresentedObject:@(mqWidth)];
    
    if(currentIndex != 0){
        largerSize = [[_mqSelectPopUpButton itemAtIndex:currentIndex-1] representedObject];
    }
    
    if(isChangeMaxWidth){
        [self changeMaxWidth];
    }
    
    //notification
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQAdded object:[self currentWC]
                                                      userInfo:@{IUNotificationMQSize:@(newWidth),
                                                                 IUNotificationMQOldMaxSize:oldMaxWidth,
                                                                 IUNotificationMQMaxSize:maxWidth,
                                                                 IUNotificationMQLargerSize:largerSize}];
}

- (void)changeMaxWidth{
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQMaxChanged object:[self currentWC] userInfo:@{IUNotificationMQSize:@(mqWidth), IUNotificationMQMaxSize:[[_mqArrayController arrangedObjects] firstObject]}];

}

@end
