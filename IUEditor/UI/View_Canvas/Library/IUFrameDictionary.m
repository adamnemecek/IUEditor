//
//  IUFrameDictionary.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 31..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "IUFrameDictionary.h"

@implementation PointLine

+(PointLine *)makePointLine:(NSPoint)startPoint endPoint:(NSPoint)endPoint{
    
    PointLine *line = [[PointLine alloc] init];
    line.start = NSMakePoint(round(startPoint.x), round(startPoint.y));
    line.end = NSMakePoint(round(endPoint.x), round(endPoint.y));
    return line;
}

@end

@implementation IUFrameDictionary

- (id)init{
    self = [super init];
    if(self){
        self.dict = [NSMutableDictionary dictionary];
    }
    return self;
}


- (NSArray *)lineToDrawSamePositionWithIU:(NSString *)IU{
    NSMutableArray *drawArray = [NSMutableArray array];
    
    //3. top line, 4. hc line, 5. bottom line
    for(int i=IUFrameLineTop; i<=IUFrameLineBottom; i++ ){
        PointLine *line =[self sameHorizontalLine:IU type:(IUFrameLine)i];
        if(line){
            [drawArray addObject:line];
        }
    }
    
    //6. left line, 7. v center line, 8. right line
    for(int i=IUFrameLineLeft; i<=IUFrameLineRight; i++ ){
        PointLine *line =[self sameVerticalLine:IU type:(IUFrameLine)i];
        if(line){
            [drawArray addObject:line];
        }
    }
    
    return drawArray;
}

#pragma mark -
#pragma mark common methods

- (BOOL)isSameFloat:(CGFloat)a b:(CGFloat)b{
    if(abs(a-b) < 1){//1 pixel 이하면 같은 라인에 있는걸로.
        return YES;
    }
    return NO;
}

- (NSArray *)allKeysExceptKey:(NSString *)key{
    
    NSMutableArray *allKeys =  [NSMutableArray arrayWithArray:[self.dict allKeys]];
    [allKeys removeObject:key];

    return allKeys;
}


- (CGFloat)floatValue:(NSRect)frame withType:(IUFrameLine)type{
    CGFloat value;
    switch (type) {
        case IUFrameLineTop:
            value = NSMinY(frame);
            break;
        case IUFrameLineHorizontalCenter:
            value = NSMidY(frame);
            break;
        case IUFrameLineBottom:
            value = NSMaxY(frame);
            break;
        case IUFrameLineLeft:
            value = NSMinX(frame);
            break;
        case IUFrameLineVerticalCenter:
            value = NSMidX(frame);
            break;
        case IUFrameLineRight:
            value = NSMaxX(frame);
            break;
        default:
            JDWarnLog( @"there is no type");
            break;
    }
    return value;
}

#pragma mark -
#pragma mark find same location

- (PointLine *)sameHorizontalLine:(NSString *)key type:(IUFrameLine)type {
    NSArray *allKeys = [self allKeysExceptKey:key];
    NSRect keyRect = [[self.dict objectForKey:key] rectValue];
    CGFloat minX = NSMinX(keyRect);
    CGFloat maxX = NSMaxX(keyRect);
    CGFloat typeY = [self floatValue:keyRect withType:type];
    BOOL isFind = NO;
    
    for(NSString *compareKey in allKeys){
        
        NSRect frame = [[self.dict objectForKey:compareKey] rectValue];
        CGFloat compareY = [self floatValue:frame withType:type];
        
        if( [self isSameFloat:typeY b:compareY]) {
            isFind = YES;
            
            if(minX > NSMinX(frame)){
                minX = NSMinX(frame);
            }
            if(maxX < NSMaxX(frame)){
                maxX = NSMaxX(frame);
            }

        }
        
    }
    
    if(isFind){
        NSPoint startPoint = NSMakePoint(minX, typeY);
        NSPoint endPoint = NSMakePoint(maxX, typeY);
        return [PointLine makePointLine:startPoint endPoint:endPoint];
        
    }
    else {
        return nil;
    }
}

- (PointLine *)sameVerticalLine:(NSString *)key type:(IUFrameLine)type {
    NSArray *allKeys = [self allKeysExceptKey:key];
    NSRect keyRect = [[self.dict objectForKey:key] rectValue];
    CGFloat minY = NSMinY(keyRect);
    CGFloat maxY = NSMaxY(keyRect);
    CGFloat typeX = [self floatValue:keyRect withType:type];
    BOOL isFind = NO;

    
    for(NSString *compareKey in allKeys){
        
        NSRect frame = [[self.dict objectForKey:compareKey] rectValue];
        CGFloat compareX = [self floatValue:frame withType:type];
        
        if( [self isSameFloat:typeX b:compareX]) {
            isFind = YES;
            if(minY > NSMinY(frame)){
                minY = NSMinY(frame);
            }
            if(maxY < NSMaxY(frame)){
                maxY = NSMaxY(frame);
            }
        }
        
    }
    
    if(isFind){
        NSPoint startPoint = NSMakePoint(typeX, minY);
        NSPoint endPoint = NSMakePoint(typeX, maxY);
        return [PointLine makePointLine:startPoint endPoint:endPoint];
        
    }
    else {
        return nil;
    }
}

- (NSRect)frameOfIU:(NSString *)IU{
    return [[_dict objectForKey:IU] rectValue];
}


@end
