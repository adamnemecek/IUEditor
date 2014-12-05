//
//  BBStructureToolBarVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBStructureToolBarVC.h"

@interface BBStructureToolBarVC ()

@property (weak) IBOutlet NSPathControl *iuPathControl;

@end

@implementation BBStructureToolBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_iuPathControl setDoubleAction:@selector(doubleClickIUPathControl:)];
    
    //change path control when iuselection is changed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iuSelectionChanged:) name:IUNotificationSelectionDidChange object:nil];

}

- (void)iuSelectionChanged:(NSNotificationCenter *)notification{
    if(self.iuController.selectedObjects.count > 0){
        [self.iuPathControl setPathComponentCells:[self pathComponentArray]];
    }
}

#pragma mark - PathControl action

- (IBAction)clickIUPathControl:(id)sender {
    NSEvent *currentEvent = [NSApp currentEvent];
    NSPoint eventPoint = [currentEvent locationInWindow];
    NSPoint location = [_iuPathControl convertPoint:eventPoint fromView:nil];

    IUBox *iu = [[_iuPathControl clickedPathComponentCell] representedObject];
    NSMenu *clickedPathMenu = [self menuForIU:iu];
    NSInteger iuIndex = [iu.parent.children indexOfObject:iu];
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
    [pathComponentArray addObject:[self componentCellForIU:box]];
    IUBox *parent = box.parent;
    while (parent != nil) {
        [pathComponentArray insertObject:[self componentCellForIU:parent] atIndex:0];
        parent  = parent.parent;
    }
    
    return [pathComponentArray copy];
}

- (NSPathComponentCell *)componentCellForIU:(IUBox *)iu{
    NSPathComponentCell *componentCell = [[NSPathComponentCell alloc] init];
    [componentCell setTextColor:[NSColor whiteColor]];

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
    if(iu.parent.children.count > 1){
        //sibling이 존재
        NSMenu *popupMenu = [[NSMenu alloc] init];
        for(IUBox *child in iu.parent.children){
#if DEBUG
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:child.htmlID action:@selector(clickForMenuItem:) keyEquivalent:@""];
#else
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:child.name action:@selector(clickForMenuItem:) keyEquivalent:@""];
#endif
            [menuItem setTarget:self];
            [menuItem setImage:[[child class] navigationImage]];
            [menuItem setRepresentedObject:child];
            [popupMenu addItem:menuItem];
        }
        return popupMenu;
        
    }
    
    return nil;
}

#pragma mark - selection

- (void)clickForMenuItem:(id)sender{
    if([sender isKindOfClass:[NSMenuItem class]]){
        IUBox *iu = [sender representedObject];
        [self.iuController setSelectedObject:iu];
    }
}

@end


