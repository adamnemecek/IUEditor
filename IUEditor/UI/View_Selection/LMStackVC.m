//
//  LMStackVC.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMStackVC.h"
#import "IUController.h"
#import "IUItem.h"
#import "IUPageContent.h"
#import "IUSection.h"
#import "IUSheet.h"
#import "LMWC.h"
#import "IUPage.h"
#import "IUClass.h"
#import "IUHeader.h"
#import "IUImport.h"

@implementation LMStackOutlineView

- (void)keyDown:(NSEvent *)theEvent{
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if(key == NSDeleteCharacter && self.delegate)
    {
        [(LMStackVC *)self.delegate keyDown:theEvent];

    }
    else {
        [super keyDown:theEvent];
    }
}

- (IBAction)copy:(id)sender{
    if(self.delegate){
        [(LMStackVC *)self.delegate copy:sender];
    }
}

- (IBAction)paste:(id)sender{
    if(self.delegate){
        [(LMStackVC *)self.delegate paste:sender];
    }
}



@end


@interface LMStackVC ()

@property (weak) IBOutlet LMStackOutlineView *outlineV;

@end

@implementation LMStackVC{
    NSArray *_draggingIndexPaths;
    id _lastClickedItem;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        
        [self loadView];

        /*
        * warning - racing condition : 가끔죽음.
        * dealloced variable 삭제.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (dealloced == NO) {
                IUBox *deepBox = [_IUController firstDeepestBox];
                if (dealloced == NO) {
//                    [_IUController setSelectedObject:deepBox];
                }
            }
        });
         */

    }
    return self;
}

-(void)awakeFromNib{
    _outlineV.delegate = self;
    [_outlineV registerForDraggedTypes:@[@"stackVC", (id)kUTTypeIUType]];
}

- (void)connectWithEditor{
 //   self.view.window;
    NSAssert(_notificationSender, @"shoud have notificationSender");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(structureChanged:) name:IUNotificationStructureDidChange object:_notificationSender];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)structureChanged:(NSNotification *)notification{
    [JDLogUtil timeLogStart:@"StackVC"];
    [JDLogUtil timeLogStart:@"StackVC-rearrange"];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self.IUController selector:@selector(rearrangeObjects) object:nil];
    [self.IUController rearrangeObjects];
    [JDLogUtil timeLogEnd:@"StackVC-rearrange"];
    
    if ([[notification.userInfo objectForKey:IUNotificationStructureChangeType] isEqualTo: IUNotificationStructureAdding]) {
        IUBox *newOne = [notification.userInfo objectForKey:IUNotificationStructureChangedIU];
        if ([newOne canSelectedWhenOpenProject]) {
            [JDLogUtil timeLogStart:@"StackVC-setSelected"];
            [self.IUController setSelectedObject:newOne];
            [JDLogUtil timeLogEnd:@"StackVC-setSelected"];
        }
    }
    [JDLogUtil timeLogEnd:@"StackVC"];
    
    //we don't need this
    //[_outlineV reloadData];
}

-(void)keyDown:(NSEvent *)theEvent{
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    NSMutableArray *alternatedSelection = [NSMutableArray array];
    if (key == NSDeleteCharacter) {
        for(IUBox *box in [self.IUController selectedObjects]){
            //selected objects can contain removed object
            if([alternatedSelection containsObject:box.htmlID]){
                [alternatedSelection removeObject:box.htmlID];
            }
            
            //add parent or not to be removed objects add to alternated selection
            if([box canRemoveIUByUserInput]){
                [box.parent removeIU:box];
                [alternatedSelection addObject:box.parent.htmlID];
            }
            else{
                [alternatedSelection addObject:box.htmlID];
            }
        }
        [self.IUController setSelectedObjectsByIdentifiers:alternatedSelection];
        [self.IUController rearrangeObjects];
    }
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(NSTreeNode*)item {

    id representObject = [item representedObject];
    
    NSTableCellView *cell;
    if([representObject isKindOfClass:[IUPageContent class]]){
        cell= [outlineView makeViewWithIdentifier:@"pagecontentCell" owner:self];
    }
    //세로로 긴 아이콘이 들어가야 하는 경우.
    else if( item.indexPath.length < 3
            || [representObject isKindOfClass:[IUClass class]]){
        cell= [outlineView makeViewWithIdentifier:@"cell" owner:self];
    }
    else{
        cell= [outlineView makeViewWithIdentifier:@"node" owner:self];
    }
    [cell.textField setStringValue:((IUBox *)representObject).name];
    [cell.imageView setImage:[[representObject class] navigationImage]];
    [cell.imageView setImageScaling:NSImageScaleProportionallyDown];

    return cell;
}

- (IBAction)outlineViewClicked:(NSOutlineView *)sender{
    NSTreeNode* clickItem = [sender itemAtRow:[sender clickedRow]];
    BOOL extended = [sender isItemExpanded:clickItem];
    
    if (extended == NO) {
        [sender.animator expandItem:clickItem];
    }
    else if ( _lastClickedItem == clickItem){
        [sender.animator collapseItem:clickItem];
    }
    _lastClickedItem = clickItem;
}


#pragma mark -
#pragma mark drag and drop

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard{
    for (NSTreeNode *node in items) {
        IUBox *iu = node.representedObject;
        if ([iu canMoveToOtherParent] == NO) {
            return NO;
        }
    }
    
    
	[pboard declareTypes:[NSArray arrayWithObjects:@"stackVC", nil] owner:self];
    _draggingIndexPaths = [_IUController selectionIndexPaths];
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)ov validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)childIndex {
    
    NSPasteboard *pBoard = info.draggingPasteboard;
    if([[pBoard types] containsObject:@"stackVC"]){
        IUBox *newParent = [item representedObject];    
        if ([newParent canAddIUByUserInput] == NO) {
            return NSDragOperationNone;
        }
        

        NSArray *selections = [_IUController selectedObjects];
        //자기자신으로 갈 수 없음.
        if([selections containsObject:newParent]){
            return NSDragOperationNone;
        }
        //parent 가 자신의 child로 가면 안됨.
        for(IUBox *box in selections){
            if([box.allChildren containsObject:newParent]){
                return NSDragOperationNone;
            }
        }

        return NSDragOperationMove;
    }
    //newIU
    if(item){
        IUBox *newParent = [item representedObject];
        
        if([newParent canAddIUByUserInput] == NO){
            return NSDragOperationNone;
        }
        else{
            NSData *iuData = [pBoard dataForType:(id)kUTTypeIUType];
            if(iuData){
                return NSDragOperationMove;
            }
        }
    }
    
    return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index{
    NSPasteboard *pBoard = info.draggingPasteboard;
    if([[pBoard types] containsObject:@"stackVC"]){
        NSArray *selections = [_IUController selectedObjects];
        IUBox *oldParent = [(IUBox*)[selections firstObject] parent];
        IUBox *newParent = [item representedObject];
        if (oldParent == newParent) {
            for (IUBox *iu in selections) {
                if (index == -1) {
                    index = 0;
                }
                [newParent changeIUIndex:iu to:index error:nil];
            }
        }
        else {
            for (IUBox *iu in selections) {
                NSInteger newIndex= index;
                if(newIndex < 0){
                    newIndex = 0 ;
                }
                [iu.parent removeIU:iu];
                [self.sheet.project.identifierManager registerIUs:@[iu]];                
                //we remove position tag. if not, iu will be invisible to new position
                [iu.css eradicateTag:IUCSSTagPixelX];
                [iu.css eradicateTag:IUCSSTagPixelY];

                [iu.css setValue:@(0) forTag:IUCSSTagPixelX];
                [iu.css setValue:@(0) forTag:IUCSSTagPixelY];
                
                                
                [newParent insertIU:iu atIndex:newIndex error:nil];
            }
            [_IUController _setSelectedObjects:selections];
        }
        [_IUController rearrangeObjects];
        return YES;
    }
        
    //type1) newIU
    NSData *iuData = [pBoard dataForType:(id)kUTTypeIUType];
    if(iuData){
        LMWC *lmWC = [NSApp mainWindow].windowController;
        IUBox *newIU = lmWC.pastedNewIU;
        if(newIU){
            IUBox *newParent = [item representedObject];
            NSInteger newIndex= index;
            if(newIndex < 0){
                newIndex = 0 ;
            }
            [newIU.css setValue:@(10) forTag:IUCSSTagPixelX];
            [newIU.css setValue:@(10) forTag:IUCSSTagPixelY];

            [newParent insertIU:newIU atIndex:newIndex error:nil];
            
            NSIndexPath *path = [[item indexPath] indexPathByAddingIndex:newIndex];
            [_IUController setSelectionIndexPath:path];  
            
            [newIU confirmIdentifier];

            return YES;
        }
    }
    return NO;
    
}

#pragma mark - copy & paste
- (IBAction)copy:(id)sender{
    [_IUController copySelectedIUToPasteboard:self];
}

- (IBAction)paste:(id)sender{
    [_IUController pasteToSelectedIU:self];
}

#pragma mark - button

- (IBAction)addSectionBtn:(id)sender {
    IUBox *parent;
    
    for(IUBox *obj in _sheet.children){
        if([obj isKindOfClass:[IUPageContent class]]){
            parent = obj;
        }
    }
    if(parent == nil){
        return;
    }

    [_sheet.project.identifierManager resetUnconfirmedIUs];
    IUSection *newIU = [[IUSection alloc]  initWithProject:_sheet.project options:nil];
    [_sheet.project.identifierManager confirm];
    if (newIU == nil) {
        NSAssert(0, @"");
    }
    
    newIU.name = newIU.htmlID;
    
    [parent addIU:newIU error:nil];
    [_IUController rearrangeObjects];
    [_IUController setSelectedObjectsByIdentifiers:@[newIU.htmlID]];

}

#pragma mark - name change
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor{
    IUBox *currentBox = (IUBox *)_IUController.selectedObjects[0];
    NSString *currentName = [fieldEditor string];
    if([currentBox.name isEqualToString:currentName] == NO){
        return NO;
    }

    return YES;
}


- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    
    NSAssert(_sheet.project.identifierManager, @"");
    
    if([self.view hasSubview:control]){ 
        /* note */
        /* when return NO, set stringvalue as IU's name.
         If just return 'NO', next esc button will make field empty */

        IUBox *currentBox = (IUBox *)_IUController.selection;
        NSString *modifiedName = [control stringValue];
        if ([currentBox.name isEqualToString:modifiedName]) {
            return YES;
        }

        if([currentBox isKindOfClass:[IUHeader class]]){
            [JDUIUtil hudAlert:@"Header should not be changed" second:1];
            IUBox *currentBox = (IUBox *)_IUController.selectedObjects[0];
            [control setStringValue:currentBox.name];
            return NO;
        }
        
        if([modifiedName stringByTrim].length == 0){
            [JDUIUtil hudAlert:@"Name should not be empty" second:1];
            IUBox *currentBox = (IUBox *)_IUController.selectedObjects[0];
            [control setStringValue:currentBox.name];
            return NO;
        }
        if([definedIdentifers containsString:modifiedName]
           || [definedPrefixIdentifiers containsPrefix:modifiedName]){
            [JDUIUtil hudAlert:@"This name is a program keyword" second:1];
            IUBox *currentBox = (IUBox *)_IUController.selectedObjects[0];
            [control setStringValue:currentBox.name];
            return NO;
        }
        
        if([[modifiedName substringToIndex:1] rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound ){
            [JDUIUtil hudAlert:@"This name should not start with digit" second:1];
            IUBox *currentBox = (IUBox *)_IUController.selectedObjects[0];
            [control setStringValue:currentBox.name];
            return NO;
        }
        
        NSMutableCharacterSet *characterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"_-"];
        [characterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
        NSCharacterSet *allowedSet = [characterSet invertedSet];
        if([modifiedName rangeOfCharacterFromSet:allowedSet].location != NSNotFound){
            [JDUIUtil hudAlert:@"Name should be alphabet or digit" second:1];
            IUBox *currentBox = (IUBox *)_IUController.selectedObjects[0];
            [control setStringValue:currentBox.name];
            return NO;
        }
        
        currentBox.name = modifiedName;
        return YES;
    }
    return NO;
}


@end