//
//  SizeView.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 4. 1..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "SizeView.h"
#import "JDUIUtil.h"
#import "LMCanvasVC.h"
#import "LMRulerView.h"
#import "LMWC.h"
#if 0

@implementation SizeImageView : NSImageView
-(id)init{
    self = [super init];
    if(self){
        self.imageScaling = NSImageScaleProportionallyUpOrDown;
    }
    return self;
}

- (NSView *)hitTest:(NSPoint)aPoint{
    return nil;
}

@end

@implementation SizeTextField : NSTextField
- (id)init{
    self = [super init];
    if (self){
        [self setBezeled:NO];
        [self setDrawsBackground:NO];
        [self setEditable:NO];
        [self setSelectable:NO];
        [self setAlignment:NSCenterTextAlignment];

    }
    return self;
}

-(id)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if(self){
        [self setBezeled:NO];
        [self setDrawsBackground:NO];
        [self setEditable:NO];
        [self setSelectable:NO];
        [self setAlignment:NSCenterTextAlignment];
    }
    return self;
}


- (NSView *)hitTest:(NSPoint)aPoint{
    return nil;
}

@end

@interface SizeView(){
    
    NSUInteger selectIndex;
    NSUInteger selectedWidth;
    SizeTextField *sizeTextField;
    NSPopover *framePopover;
    
    NSView *boxManageView;
    LMRulerView *rulerView;
    
}

@end


@implementation SizeView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _sizeArray = [NSMutableArray array];
        selectIndex = 0;
        selectedWidth = 0;
    }
    return self;
}

-(void)awakeFromNib{

    //sizeBox
    boxManageView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 0, 30)];
    rulerView = [[LMRulerView alloc] init];
    
    /*
     * hierarchy
     rulerview
     addBtn
     boxManageView
     
     */
    [self addSubview:boxManageView positioned:NSWindowBelow relativeTo:self.addBtn];
    [self addSubviewFullFrame:rulerView withLeft:30 positioned:NSWindowBelow relativeTo:self.addBtn];
    
}

- (void)resetCursorRects{
    [super resetCursorRects];
    if (boxManageView.subviews.count == 0) {
        return;
    }
    InnerSizeBox *maxBox = (InnerSizeBox *)boxManageView.subviews[0];
    [self addCursorRect:[maxBox frame] cursor:[NSCursor pointingHandCursor]];
}

//call from scroll view

- (void)moveSizeView:(NSPoint)point withWidth:(CGFloat)width{
    NSPoint movePoint = NSMakePoint(point.x, 0);
    [boxManageView setBoundsOrigin:movePoint];
}

#pragma mark -

- (NSArray *)sortedArray{
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
    return [_sizeArray sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
}

#pragma mark -
#pragma mark select

- (void)setColorBox:(InnerSizeBox *)sizeBox{
    if(sizeBox.frameWidth <= selectedWidth){
        [sizeBox setSmallerColor];
    }else{
        [sizeBox setLargerColor];
    }
}

- (void)selectBox:(InnerSizeBox *)selectBox{
    
    NSUInteger newSelectIndex = [boxManageView.subviews indexOfObject:selectBox];
    
    if(newSelectIndex != selectIndex){

        selectIndex = newSelectIndex;
    }
    
    NSInteger oldSelectedWidth = selectedWidth;
    selectedWidth = selectBox.frameWidth;
    
    for(InnerSizeBox *sizeBox in boxManageView.subviews){
        [self setColorBox:sizeBox];
        
    }
    [self.controller disableUpdateCSS:self];
    

    //notification
    NSInteger maxSize = [[self sortedArray][0] integerValue];
    NSInteger largeSize = maxSize;
    if(selectIndex != 0){
        largeSize = [[self sortedArray][selectIndex -1] integerValue];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQSelected object:self userInfo:@{IUNotificationMQSize:@(selectedWidth), IUNotificationMQMaxSize:@(maxSize)}];
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQSelectedWithInfo object:self userInfo:@{IUNotificationMQSize:@(selectedWidth), IUNotificationMQMaxSize:@(maxSize), IUNotificationMQLargerSize:@(largeSize), IUNotificationMQOldSize:@(oldSelectedWidth)} ];
    
    [self.controller enableUpdateCSS:self];
        
}

#pragma mark -
#pragma mark add, remove width
- (NSInteger)nextSmallSize:(NSInteger)size{
    NSNumber *sizeNumber = [NSNumber numberWithInteger:size];
    NSInteger index = [[self sortedArray] indexOfObject:sizeNumber]+1;
    
    if(index < boxManageView.subviews.count){
        InnerSizeBox *nextBox = (InnerSizeBox *)boxManageView.subviews[index];
        return nextBox.frameWidth;
    }
    else{
        return 0;
    }
}
- (void)setMaxWidthWithChange:(BOOL)isChange{
    InnerSizeBox *maxBox = (InnerSizeBox *)boxManageView.subviews[0];
    if(maxBox){
        if(maxBox.frameWidth > boxManageView.frame.size.width){
            [boxManageView setWidth:maxBox.frameWidth];
        }
    }
    if(isChange){
        [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQMaxChanged object:self userInfo:@{IUNotificationMQSize:@(selectedWidth), IUNotificationMQMaxSize:@(maxBox.frameWidth)}];
    }
}

- (void)addFrame:(NSInteger)width{
    NSNumber *widthNumber = [NSNumber numberWithInteger:width];
    if([_sizeArray containsObject:widthNumber]){
        JDFatalLog(@"It is something wrong");
        return ;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] removeFrame:width];
    
    
    [_sizeArray addObject:widthNumber];
    NSRect boxFrame = NSMakeRect(0, 0, width, self.frame.size.height);
    InnerSizeBox *newBox = [[InnerSizeBox alloc] initWithFrame:boxFrame width:width];
    newBox.boxDelegate = self;
    NSInteger index = [[self sortedArray] indexOfObject:widthNumber];
    BOOL isMaxChanged = NO;
    
    if(index > 0){
        //view가 중간에 들어갈때
        //size 큰것보다 하나 위로 들어감
        NSView *preView = boxManageView.subviews[index-1];
        [boxManageView addSubviewMiddleInFrameWithFrame:newBox positioned:NSWindowAbove relativeTo:preView];
    }
    else if(boxManageView.subviews.count == 0){
        //make first
        isMaxChanged = YES;
        [boxManageView addSubviewMiddleInFrameWithFrame:newBox];
        [newBox select];
    }
    else{
        //maximumsize임
        isMaxChanged = YES;
        NSView *frontView = boxManageView.subviews[0];
        [boxManageView addSubviewMiddleInFrameWithFrame:newBox positioned:NSWindowBelow relativeTo:frontView];
    }
    
    [self setMaxWidthWithChange:isMaxChanged];
    if(isMaxChanged){
        [self selectBox:newBox];
    }
    [self setColorBox:newBox];
    

}
- (void)removeFrame:(NSInteger)width{
    if(_sizeArray.count == 1){
        JDWarnLog(@"last width : can't remove it");
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] addFrame:width];
    

    NSNumber *widthNumber = [NSNumber numberWithInteger:width];
    NSInteger index = [[self sortedArray] indexOfObject:widthNumber];
    
    BOOL isMaxChanged = NO;
    InnerSizeBox *removeView = boxManageView.subviews[index];
    if(index==0){
        //it is largest box-select smallerbox
        InnerSizeBox *nextBox = boxManageView.subviews[index+1];
        [nextBox select];
        isMaxChanged = YES;
    }
    else if(selectIndex == index){
        //select next larger box
        InnerSizeBox *nextBox = boxManageView.subviews[index-1];
        [nextBox select];
    }
    
    //remove css & view & array
    [removeView removeFromSuperview];
    [_sizeArray removeObject:widthNumber];
    
    //set maxWidth in case of removing maxWidth 
    [self setMaxWidthWithChange:isMaxChanged];
    

    //notification
    InnerSizeBox *maxBox = (InnerSizeBox *)boxManageView.subviews[0];
     [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQRemoved object:self userInfo:@{IUNotificationMQSize:@(width), IUNotificationMQMaxSize:@(maxBox.frameWidth)}];

}

#pragma mark popover

- (IBAction)addSizeBtnClick:(id)sender {
    [self.addFramePopover showRelativeToRect:self.addBtn.frame ofView:sender preferredEdge:NSMinYEdge];
}

- (IBAction)addSizeOKBtn:(id)sender {
    NSInteger newWidth = [self.addFrameSizeField integerValue];
    
    if(newWidth > 30000){
        [JDUIUtil hudAlert:@"It's too large, we support up to 30000px!" second:2];
        return ;
    }
    if(newWidth == 0){
        [JDUIUtil hudAlert:@"It's wrong size, input the positive number" second:2];
        return ;
    }
    
    NSNumber *widthNumber = [NSNumber numberWithInteger:newWidth];
    if([_sizeArray containsObject:widthNumber]){
        [JDUIUtil hudAlert:@"Already Same Width, Here" second:2];
        return ;
    }
    
    [self addFrame:newWidth];
    [self.addFramePopover close];
    
    NSInteger currentIndex = [[self sortedArray] indexOfObject:widthNumber];
    
    NSNumber *max = [self.sortedArray firstObject];
    NSNumber *oldMax = [self.sortedArray objectAfterObject:max];
    NSNumber *largerSize;
    
    if(currentIndex != 0){
        largerSize = [self.sortedArray objectAtIndex:currentIndex-1];
    }
    
//notification
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationMQAdded object:self
                                                      userInfo:@{IUNotificationMQSize:@(newWidth),
                                                                 IUNotificationMQOldMaxSize:oldMax,
                                                                 IUNotificationMQMaxSize:max,
                                                                 IUNotificationMQLargerSize:largerSize}];
    
}

#pragma mark - Undo Manager
- (NSUndoManager *)undoManager{
    return [[[[NSApp mainWindow] windowController] document] undoManager];
}




@end

#endif

