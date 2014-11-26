//
//  LMFileNaviVC.m
//  IUEditor
//
//  Created by JD on 3/24/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMFileNaviVC.h"
#import "IUSheetGroup.h"
#import "IUResourceFile.h"
#import "IUPage.h"
#import "IUBackground.h"
#import "IUClass.h"
#import "LMWC.h"
#import "IUProject.h"
#import "IUWordpressProject.h"
#import "LMWordpressCreateFileWC.h"

#import "LMNewPageWC.h"

@interface LMFileNaviVC ()
@property (weak) IBOutlet NSOutlineView *outlineV;
@end

@implementation LMFileNaviVC{
    BOOL    viewLoadedOK;
    BOOL    loaded;
    id      _lastClickedItem;
    NSArray *_draggingIndexPaths;
    IUSheet  *_draggingItem;
    LMWordpressCreateFileWC *wpWC;
    LMNewPageWC *pageWC;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadView];
        [_outlineV registerForDraggedTypes:@[@"IUFileNavi"]];
    }
    return self;
}

- (void)setDocumentController:(IUSheetController *)documentController{
    _documentController = documentController;
    [_documentController addObserver:self forKeyPath:@"selection" options:0 context:nil];
    [_documentController bind:NSContentBinding toObject:self withKeyPath:@"project" options:nil];
}

-(void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"FileNavi"];
    [_documentController removeObserver:self forKeyPath:@"selection"];
}

#pragma mark -selection


-(void)selectionDidChange:(NSDictionary*)dict{
    [self willChangeValueForKey:@"selection"];
    _selection = [_documentController.selectedObjects firstObject];
    [self didChangeValueForKey:@"selection"];
}

-(void)selectFirstDocument{
    //find first document
    [_documentController setSelectedObject:_project.pageSheets.firstObject];
}

- (void)reloadNavigation{
    [_outlineV reloadData];
}

#pragma mark - outlineView

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(NSTreeNode*)item {
    //folder
    if ( [item.representedObject isKindOfClass:[IUProject class]] ||
        [item.representedObject isKindOfClass:[IUResourceGroup class]]){
        
        IUSheetGroup *doc = (IUSheetGroup*) item.representedObject;
        NSTableCellView *folder = [outlineView makeViewWithIdentifier:@"folderNoAdd" owner:self];
        [folder.textField setStringValue:doc.name];
        
        return folder;
    }
    else if ([item.representedObject isKindOfClass:[IUSheetGroup class]])
    {
        NSTableCellView *folder;
        
        IUSheetGroup *doc = (IUSheetGroup*) item.representedObject;
        if ([doc isKindOfClass:[IUSheetGroup class]]) {
            folder = [outlineView makeViewWithIdentifier:@"folder" owner:self];

        }
    
        [folder.textField setStringValue:doc.name];
        
        return folder;
    }
    //file
    else{
        NSString *cellIdentifier, *nodeName;
        if ([[item representedObject] isKindOfClass:[IUSheet class]]){
            IUSheet *node = [item representedObject];
            if([node.group.name isEqualToString:IUPageGroupName]){
                cellIdentifier = @"pageFile";
            }
            else if ([node.group.name isEqualToString:IUClassGroupName]){
                cellIdentifier = @"classFile";
            }
            else {
                NSAssert(0, @"");
            }
            nodeName = node.name;
        }
        else if( [[item representedObject] isKindOfClass:[IUResourceFile class]] ){
            IUResourceFile *node = [item representedObject];
            
            if( node.type == IUResourceTypeImage ){
                cellIdentifier = @"imageFile";
            }
            else if(node.type == IUResourceTypeVideo){
                cellIdentifier = @"videoFile";
            }
            else if(node.type == IUResourceTypeCSS){
                cellIdentifier = @"cssFile";
            }
            else if(node.type == IUResourceTypeJS){
                cellIdentifier = @"JSFile";
            }
            else {
                NSAssert(0, @"");
            }
            nodeName = node.name;
        }
        
        NSTableCellView *cell = [outlineView makeViewWithIdentifier:cellIdentifier owner:self];
        [cell.textField setStringValue:nodeName];

        return cell;
    }
    return nil;
}

#pragma mark -

- (IBAction)outlineViewClicked:(NSOutlineView *)sender{
    NSTreeNode* clickItem = [sender itemAtRow:[sender clickedRow]];
    if (clickItem == nil) {
        return;
    }
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
#pragma mark rightmenu


- (NSMenu *)defaultMenuForRow:(NSInteger)row{
    NSTreeNode *item = [_outlineV itemAtRow:row];
    id node = [item representedObject];

    if( [node isKindOfClass:[IUSheet class]]){
        NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Document"];
        NSMenuItem *openItem = [[NSMenuItem alloc] initWithTitle:@"Show in Finder" action:@selector(openProject:) keyEquivalent:@""];
        openItem.tag = row;
        openItem.target = self;
        [menu addItem:openItem];
        

        NSMenuItem *removeItem = [[NSMenuItem alloc] initWithTitle:@"Remove Document" action:@selector(removeDocument:) keyEquivalent:@""];
        removeItem.tag = row;
        removeItem.target = self;
        [menu addItem:removeItem];
        
        
        if([node isKindOfClass:[IUClass class]] || [node isKindOfClass:[IUPage class]]){
            NSMenuItem *copyItem = [[NSMenuItem alloc] initWithTitle:@"Copy Document" action:@selector(copyDocument:) keyEquivalent:@""];
            copyItem.tag = row;
            copyItem.target = self;
            [menu addItem:copyItem];
        }
        

        return menu;
    }

    else {
    }
    return nil;
    
}


- (void)openProject:(id)sender {
    [[NSWorkspace sharedWorkspace] openFile:[_project.path stringByDeletingLastPathComponent]];
}

- (void)copyDocument:(NSMenuItem*)sender{
    NSTreeNode *item = [_outlineV itemAtRow:sender.tag];
    IUSheet * node = [item representedObject];
    IUSheet * newNode = [node copy];
    [self.project addItem:newNode toSheetGroup:node.group];
    [self.project.identifierManager registerIUs:@[newNode]];
    [self.documentController rearrangeObjects];
}

- (void)removeDocument:(NSMenuItem*)sender{
    NSTreeNode *item = [_outlineV itemAtRow:sender.tag];
    IUSheet * node = [item representedObject];
    IUSheetGroup *parent = node.group;
    if (node.group.childrenFiles.count == 1) {
        NSBeep();
        [JDUIUtil hudAlert:@"Each document folder should have at least one document" second:2];
        return;
    }
    [self.project removeItem:node toSheetGroup:node.group];
    [self.project.identifierManager unregisterIUs:@[node]];
    [_documentController setSelectedObject:[[parent childrenFiles] firstObject]];
    [_documentController rearrangeObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationStructureDidChange object:self.project userInfo:@{IUNotificationStructureChangeType:IUNotificationStructureChangeRemoving, IUNotificationStructureChangedIU:node}];

}


#pragma mark - cell specivfic action (add, name editing)

- (void)makeNewPageWithlayoutCode:(IUPageLayout)layoutCode{
 
    [[self.project identifierManager] resetUnconfirmedIUs];
    
    //FIXME: code에 맞는거 찾아서 넣기.? 
    IUPage *newDoc = [[IUPage alloc] initWithPresetWithLayout:layoutCode header:nil footer:nil sidebar:nil];
    [self.project addItem:newDoc toSheetGroup:self.project.pageGroup];
    [self.project.identifierManager registerIUs:@[newDoc]];
    
    
    if(newDoc){
        [self.documentController rearrangeObjects];
        [self.documentController setSelectedObject:newDoc];
    }
    [newDoc connectWithEditor];
    [newDoc setIsConnectedWithEditor];
    [[self.project identifierManager] confirm];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationStructureDidChange object:self.project userInfo:@{IUNotificationStructureChangeType:IUNotificationStructureAdding, IUNotificationStructureChangedIU:newDoc}];
}


- (void)makeNewClass{
    
    [[self.project identifierManager] resetUnconfirmedIUs];

    IUClass *newDoc = [[IUClass alloc] initWithPreset];
    [self.project addItem:newDoc toSheetGroup:self.project.classGroup];
    [self.project.identifierManager registerIUs:@[newDoc]];
    
    if(newDoc){
        [self.documentController rearrangeObjects];
        [self.documentController setSelectedObject:newDoc];
    }
    [newDoc connectWithEditor];
    [newDoc setIsConnectedWithEditor];
    [[self.project identifierManager] confirm];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationStructureDidChange object:self.project userInfo:@{IUNotificationStructureChangeType:IUNotificationStructureAdding, IUNotificationStructureChangedIU:newDoc}];
}
- (IBAction)performaddItem:(id)sender{
    
    NSTableCellView *cellView = (NSTableCellView *)[sender superview];
    NSString *groupName =  cellView.textField.stringValue;
    [[self.project identifierManager] resetUnconfirmedIUs];
    if([groupName isEqualToString:IUPageGroupName]){
        
        if(pageWC == nil){
            pageWC = [[LMNewPageWC alloc] initWithWindowNibName:[LMNewPageWC class].className];
        }
        
        [self.view.window beginSheet:pageWC.window completionHandler:^(NSModalResponse returnCode) {
            if(returnCode == NSModalResponseCancel){
                return ;
            }
            
            IUPageLayout layoutCode = (int)returnCode - NSModalResponseOK;
            
            
            if ([self.project isKindOfClass:[IUWordpressProject class]]) {
                if(wpWC == nil){
                    wpWC = [[LMWordpressCreateFileWC alloc] initWithWindowNibName:@"LMWordpressCreateFileWC"];
                }
                wpWC.project = (IUWordpressProject*) self.project;
                wpWC.sheetController = self.documentController;
                [self.view.window beginSheet:wpWC.window completionHandler:^(NSModalResponse returnCode) {
                    if (returnCode == NSModalResponseContinue) {
                        [self makeNewPageWithlayoutCode:layoutCode];
                    }
                }];
            }
            else {
                [self makeNewPageWithlayoutCode:layoutCode];
            }
            
        }];
        
    }
    else if([groupName isEqualToString:IUClassGroupName]){
        [self makeNewClass];
    }
    
}

#pragma mark - name change
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor{
    IUSheet *sheet = (IUSheet *)self.selection;
    NSString *currentName = [fieldEditor string];
    if([sheet.name isEqualToString:currentName] == NO){
        return NO;
    }
    
    return YES;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    NSAssert(_project.identifierManager, @"");
    
    
    if([self.view hasSubview:control]){
        IUSheet *sheet = (IUSheet *)self.selection;
        NSString *modifiedName = fieldEditor.string;
        if ([sheet.name isEqualToString:modifiedName]){
            return YES;
        }
        
        if([modifiedName stringByTrim].length == 0){
            IUBox *currentBox = (IUBox *)self.selection;
            [control setStringValue:currentBox.name];

            [JDUIUtil hudAlert:@"Name should not be empty" second:2];
            return NO;
        }
        
        if([definedIdentifers containsString:modifiedName]
           || [definedPrefixIdentifiers containsPrefix:modifiedName]){
            IUBox *currentBox = (IUBox *)self.selection;
            [control setStringValue:currentBox.name];

            [JDUIUtil hudAlert:@"This name is a program keyword" second:2];
            return NO;
        }
        
        if([[modifiedName substringToIndex:1] rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound ){
            [JDUIUtil hudAlert:@"This name should not start with digit" second:1];
            IUBox *currentBox = (IUBox *)self.selection;
            [control setStringValue:currentBox.name];
            return NO;
        }
        
        NSMutableCharacterSet *characterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"_-"];
        [characterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
        NSCharacterSet *allowedSet = [characterSet invertedSet];
        if([modifiedName rangeOfCharacterFromSet:allowedSet].location != NSNotFound){
            IUBox *currentBox = (IUBox *)self.selection;
            [control setStringValue:currentBox.name];
            [JDUIUtil hudAlert:@"Name should be alphabet or digit" second:2];
            return NO;
        }
        
        IUBox *box = [_project.identifierManager IUWithIdentifier:modifiedName];
        if (box != nil) {
            IUBox *currentBox = (IUBox *)self.selection;
            [control setStringValue:currentBox.name];

            [JDUIUtil hudAlert:@"IU with same name exists" second:1];
            return NO;
        }
        
        [_project.identifierManager unregisterIUs:@[sheet]];
        sheet.htmlID = modifiedName;
        [_project.identifierManager registerIUs:@[sheet]];
        sheet.name = modifiedName;
        
        /* class의 경우 pagecontent부분이 없기 때문에 htmlid를 바꾸고 나면 class 
          하나 밖에 없는 경우에 iu selection이 안됨.
         */
        if([sheet isKindOfClass:[IUClass class]]){
            [((LMWC *)[[[self view] window] windowController]) reloadCurrentDocument:self];
        }
        
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark drag and drop
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard{
    id item = [items firstObject];
    if ([[item representedObject] isKindOfClass:[IUSheet class]]){
        [pboard declareTypes:@[@"IUFileNavi"] owner:self];
        _draggingIndexPaths = [_documentController selectionIndexPaths];
        _draggingItem = [[_documentController selectedObjects] firstObject];
        return YES;
    }
    return NO;
}

- (NSDragOperation)outlineView:(NSOutlineView *)ov validateDrop:(id <NSDraggingInfo>)info proposedItem:(NSTreeNode*)item proposedChildIndex:(NSInteger)childIndex {
    id itemRepresented = [item representedObject];
    if ([itemRepresented isKindOfClass:[IUSheetGroup class]]) {
        if ((IUSheetGroup*)itemRepresented == [_draggingItem group] ) {
            return NSDragOperationMove;
        }
    }
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index{
    //rearrange
    IUSheetGroup *group = [item representedObject];
    NSIndexPath *originalIndexPath = [_draggingIndexPaths lastObject];
    NSInteger lastIndexPath = [originalIndexPath indexAtPosition:originalIndexPath.length-1];
    if (index > lastIndexPath) {
        index --;
    }
    [group changeIndex:_draggingItem toIndex:index];
    [_documentController rearrangeObjects];
    return YES;
}


@end
