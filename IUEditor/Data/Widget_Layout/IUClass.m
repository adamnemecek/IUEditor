//
//  IUComponent.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUClass.h"
#import "IUProject.h"
#import "IUImport.h"
#import "IUText.h"

@implementation IUClass{
    NSMutableArray *_referenceImports;
}

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"ic_comp"];
}

#pragma mark - Initialize

- (id)initWithPreset{
    return [self initWithPreset:IUClassPresetTypeNone];
}

- (id)initWithPreset:(IUClassPresetType)classType{
    self = [super initWithPreset];
    
    _referenceImports = [NSMutableArray array];

    
    IUText *titleBox = [[IUText alloc] initWithPreset];
    titleBox.currentPositionStorage.y = @(43);
    titleBox.currentPositionStorage.firstPosition = @(IUFirstPositionTypeAbsolute);
    
    titleBox.currentStyleStorage.width = @(140);
    titleBox.currentStyleStorage.height = @(34);
    titleBox.currentStyleStorage.fontSize = @(24);
    titleBox.currentStyleStorage.fontAlign = @(IUAlignCenter);
    titleBox.currentStyleStorage.fontColor = [NSColor rgbColorRed:153 green:153 blue:153 alpha:1];
    titleBox.currentStyleStorage.bgColor1  = nil;
    titleBox.currentStyleStorage.fontName = @"Helvetica";
    
    titleBox.enableHCenter = YES;
    
    switch (classType) {
            
            
        case IUClassPresetTypeHeader:{
            [self.currentStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
            [self.currentStyleStorage setHeight:@(120) unit:@(IUFrameUnitPixel)];

            self.currentStyleStorage.fontColor = [NSColor rgbColorRed:50 green:50 blue:50 alpha:1];
            
            titleBox.textType = IUTextTypeH1;
            titleBox.currentPropertyStorage.innerHTML = @"Header Area";
            
            [self addIU:titleBox error:nil];

            break;
        }
        case IUClassPresetTypeSidebar:{
            [self.currentStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
            [self.currentStyleStorage setHeight:@(120) unit:@(IUFrameUnitPixel)];
            
            titleBox.currentStyleStorage.fontSize = @(12);
            titleBox.currentPropertyStorage.innerHTML = @"Sidebar Area";
            
            [self addIU:titleBox error:nil];

            break;
        }
        case IUClassPresetTypeFooter:{
            [self.currentStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
            [self.currentStyleStorage setHeight:@(100) unit:@(IUFrameUnitPercent)];
            
            titleBox.currentPropertyStorage.innerHTML = @"Footer Area";
            
            
            [self addIU:titleBox error:nil];
            
            break;
        }
        case IUClassPresetTypeNone:{
            
            break;
        }
            
        default:{
            NSAssert(0, @"Not yet coded");
        }
            break;
    }
    return self;
}

- (void)awakeAfterUsingJDCoder:(JDCoder *)aDecoder{
    [super awakeAfterUsingJDCoder:aDecoder];
    [self.undoManager disableUndoRegistration];
    
    
    //REVIEW: support weak references : load weak references from import
    _referenceImports = [NSMutableArray array];
    NSArray *references = [aDecoder decodeObjectForKey:@"referenceImport"];
    for(IUImport *import in references){
        [self addReference:import];
    }
    
    [self.undoManager enableUndoRegistration];
    
}
- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    
    //REVIEW: support weak references : save import from weak value object
    [aCoder encodeObject:self.references forKey:@"referenceImport"];
}

-(BOOL)canChangeWidthByUserInput{
    return YES;
}

-(BOOL)canChangeHeightByUserInput{
    return YES;
}

- (void)updateCSS{
    [super updateCSS];
    for(IUImport *import in self.references){
        [import updateCSS];
    }
}

- (void)addReference:(IUImport*)import{
    /**
     REVIEW : owner should be a weak object
     http://stackoverflow.com/questions/21797617/how-to-store-weak-reference-object-in-array-dictionary-in-objc
     */
    NSValue *weakObj = [NSValue valueWithNonretainedObject:import];
    if([_referenceImports containsObject:weakObj] == NO){
        [_referenceImports addObject:weakObj];
    }
}
- (void)removeReference:(IUImport*)import{
    NSValue *weakObj = [NSValue valueWithNonretainedObject:import];
    [_referenceImports removeObject:weakObj];
}

- (NSArray*)references{
    NSMutableArray *realReferences = [NSMutableArray array];
    for(NSValue *weakObj in _referenceImports){
        id box = [weakObj nonretainedObjectValue];
        [realReferences addObject:box];
    }
    return [realReferences copy];
}




@end
