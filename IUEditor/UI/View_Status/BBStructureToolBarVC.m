//
//  BBStructureToolBarVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBStructureToolBarVC.h"
#import "IUProject.h"
#import "IUPage.h"
#import "IUClass.h"

@interface BBStructureToolBarVC ()

@property (weak) IBOutlet NSPathControl *iuPathControl;

@end

@implementation BBStructureToolBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_iuPathControl setDoubleAction:@selector(doubleClickIUPathControl:)];
    
    //change path control when iuselection is changed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iuSelectionChanged:) name:IUNotificationSelectionDidChange object:self.iuController.project];

}

- (void)iuSelectionChanged:(NSNotificationCenter *)notification{
    if(self.iuController.selectedObjects.count > 0){
        [self.iuPathControl setPathComponentCells:[self pathComponentArray]];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    JDSectionInfoLog(IULogDealloc, @"");

}


#pragma mark - PathControl action

- (IBAction)clickIUPathControl:(id)sender {
    //get current event
    NSEvent *currentEvent = [NSApp currentEvent];
    NSPoint eventPoint = [currentEvent locationInWindow];
    NSPoint location = [_iuPathControl convertPoint:eventPoint fromView:nil];

    //path control을 클릭하면 같은 depth의 iu들을 메뉴로 보여준다.
    IUBox *iu = [[_iuPathControl clickedPathComponentCell] representedObject];
    NSMenu *clickedPathMenu = [self menuForIU:iu];
    NSInteger iuIndex = 0;
    
    if([iu isKindOfClass:[IUSheet class]]){
       iuIndex =  [_pageController.project.allSheets indexOfObject:iu];
    }
    else{
        iuIndex = [iu.parent.children indexOfObject:iu];
    }
    
    [clickedPathMenu popUpMenuPositioningItem:[clickedPathMenu itemAtIndex:iuIndex] atLocation:location inView:_iuPathControl];
}

- (IBAction)doubleClickIUPathControl:(id)sender{
    IUBox *iu = [[_iuPathControl clickedPathComponentCell] representedObject];
    [self.iuController setSelectedObject:iu];
}

#pragma mark - PathControl Cell

- (NSArray *)pathComponentArray{
    NSMutableArray *pathComponentArray = [[NSMutableArray alloc] init];
    
    IUBox *box = self.iuController.selectedObjects[0];
    [pathComponentArray addObject:[self componentCellForIU:box isSelected:YES]];
    
    //add ancestor
    IUBox *parent = box.parent;
    while (parent != nil) {
        [pathComponentArray insertObject:[self componentCellForIU:parent isSelected:NO] atIndex:0];
        parent  = parent.parent;
    }
    
    //add descendant
    if(box.children.count > 0){
        IUBox *child = [box.children objectAtIndex:0];
        while (child != nil) {
            [pathComponentArray addObject:[self componentCellForIU:child isSelected:NO]];
            if(child.children.count > 0){
                child = [child.children objectAtIndex:0];
            }
            else{
                child = nil;
            }
        }
    }
    
    return [pathComponentArray copy];
}

- (NSPathComponentCell *)componentCellForIU:(IUBox *)iu isSelected:(BOOL)isSelected{
    NSPathComponentCell *componentCell = [[NSPathComponentCell alloc] init];
    if(isSelected){
        [componentCell setTextColor:[NSColor rgbColorRed:20 green:140 blue:210 alpha:1.0]];
    }
    else{
        [componentCell setTextColor:[NSColor grayColor]];
    }


    [componentCell setImage:[[iu class] navigationImage]];
#if DEBUG
    [componentCell setTitle:iu.htmlID];
#else
    [componentCell setTitle:iu.name];
#endif
    [componentCell setRepresentedObject:iu];

    return componentCell;
}

- (NSMenu *)menuForIU:(IUBox *)iu{
    
    if([iu isKindOfClass:[IUSheet class]]){//IUSheet class는 allSheet
    
        NSMenu *popupMenu = [[NSMenu alloc] init];
        for(IUSheet *sheet in _pageController.project.allSheets){
            NSMenuItem *menuItem = [self menuItemForIU:sheet];
            [popupMenu addItem:menuItem];
        }
        return popupMenu;
    }
    else{
        NSMenu *popupMenu = [[NSMenu alloc] init];
        for(IUBox *child in iu.parent.children){
            NSMenuItem *menuItem = [self menuItemForIU:child];
            [popupMenu addItem:menuItem];
        }
        
        return popupMenu;
        
    }
    
    return nil;
}
- (NSMenuItem *)menuItemForIU:(IUBox *)iu{
    
#if DEBUG
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:iu.htmlID action:@selector(clickForMenuItem:) keyEquivalent:@""];
#else
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:iu.name action:@selector(clickForMenuItem:) keyEquivalent:@""];
#endif
    [menuItem setTarget:self];
    [menuItem setImage:[[iu class] navigationImage]];
    [menuItem setRepresentedObject:iu];
    
    return  menuItem;
}


#pragma mark - selection

- (void)clickForMenuItem:(id)sender{
    if([sender isKindOfClass:[NSMenuItem class]]){
        IUBox *iu = [sender representedObject];
        if([iu isKindOfClass:[IUPage class]]){
            [self.pageController setSelectedObject:iu];
        }
        else if([iu isKindOfClass:[IUClass class]]){
            [self.classController setSelectedObject:iu];
        }
        else{
            [self.iuController setSelectedObject:iu];
        }
    }
}

@end


