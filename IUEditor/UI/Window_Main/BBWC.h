//
//  BBWC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BBWindowProtocol.h"
#import "IUProjectDocument.h"
#import "IUResource.h"

typedef enum{
    BBPropertyTabTypeWidget,
    BBPropertyTabTypeProperty,
    BBPropertyTabTypeImage,
    BBPropertyTabTypeStyle,
    BBPropertyTabTypeAction,
    BBPropertyTabTypeEvent,
    BBPropertyTabTypeLibrary,
    BBPropertyTabTypeTracing,
    BBPropertyTabTypeStructure,
    BBPropertyTabTypeBackEnd,
    BBPropertyTabTypeNone,
    
}BBPropertyTabType;

@interface BBWC : NSWindowController <BBWindowProtocol>


/**
 @brief sourceManager connects between iubox(iudata) and canvasVC
 @code
 
 */
@property IUSourceManager *sourceManager;
@property IUSheetController *pageController;
@property IUSheetController *classController;
@property IUController *iuController;

/**
 @note project will be retained
 */
- (void)setProject:(IUProject *)project;

/**
 @note resourceItem will be retained
 */
- (void)setResourceRootItem:(IUResourceRootItem *)rootItem;

/**
 @note undomanager will be retained
 */
- (void)setUndoManager:(NSUndoManager *)undoManager;
- (NSUndoManager *)undoManager;

/**
 Set IUProjectDocument to Window Controller
 setDoccument will set project, resourceManager, undomanager.
 */
- (void)setDocument:(IUProjectDocument *)document;

- (void)reloadCurrentSheet:(id)sender;
- (void)reloadCurrentSheet:(id)sender viewport:(NSInteger)viewport;

- (NSString *)projectName;

@end
