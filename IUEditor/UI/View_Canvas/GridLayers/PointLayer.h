//
//  PointLayer.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 25..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#define IUInnerPointLayerCount 8
#define IUPointSize 6

typedef enum{
    IUPointLayerPositionLeftUp,
    IUPointLayerPositionLeftMiddle,
    IUPointLayerPositionLeftDown,
    IUPointLayerPositionUp,
    IUPointLayerPositionDown,
    IUPointLayerPositionRightUp,
    IUPointLayerPositionRightMiddle,
    IUPointLayerPositionRightDown,
    
} IUPointLayerPosition;


@interface InnerPointLayer : CALayer{
    IUPointLayerPosition type;
}

- (IUPointLayerPosition)type;

@end

@interface PointLayer : CALayer{
    NSString *identifier;
    NSRect iuFrame;
    
}

- (id)initWithIdentifier:(NSString *)anIdentifier withFrame:(NSRect)frame;
- (NSString *)identifier;

- (NSRect)diffPointAndSizeWithType:(IUPointLayerPosition)type withDiffPoint:(NSPoint)diffPoint;
- (void)updateFrame:(NSRect)frame;
- (NSMutableArray *)cursorArray;
@end
