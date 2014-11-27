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
    titleBox.currentPositionStorage.position = @(IUPositionTypeAbsolute);
    
    titleBox.currentStyleStorage.width = @(140);
    titleBox.currentStyleStorage.height = @(34);
    titleBox.currentStyleStorage.fontSize = @(24);
    titleBox.currentStyleStorage.fontAlign = @(IUAlignCenter);
    titleBox.currentStyleStorage.fontColor = [NSColor rgbColorRed:153 green:153 blue:153 alpha:1];
    titleBox.currentStyleStorage.bgColor  = nil;
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
    //FIXME:
    //encodeObject  무한루프
    //encodeByRefObject 디코드 익셉션으로 빠짐
    
    _referenceImports = [aDecoder decodeObjectForKey:@"referenceImport"];
    
}
- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    //FIXME:
    [aCoder encodeObject:_referenceImports forKey:@"referenceImport"];
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    self =  [super awakeAfterUsingCoder:aDecoder];

    _referenceImports = [[aDecoder decodeObjectForKey:@"referenceImport"] mutableCopy];
    NSArray *copy = [_referenceImports copy];
    NSInteger index = [copy count] - 1;
    for (id object in [copy reverseObjectEnumerator]) {
        if ([_referenceImports indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) {
            [_referenceImports removeObjectAtIndex:index];
        }
        index--;
    }

    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_referenceImports forKey:@"referenceImport"];
}


-(BOOL)canChangeWidthByUserInput{
    return YES;
}

-(BOOL)canChangeHeightByUserInput{
    return YES;
}

- (void)addReference:(IUImport*)import{
    if([_referenceImports containsObject:import] == NO){
        [_referenceImports addObject:import];
    }
}
- (void)removeReference:(IUImport*)import{
    [_referenceImports removeObject:import];
}

- (NSArray*)references{
    return [_referenceImports copy];
}

- (void)updateCSS{
    [super updateCSS];
    for(IUImport *import in _referenceImports){
        [import updateCSS];
    }
}


@end
