//
//  PointTextLayer.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 27..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "IUBox.h"

typedef enum{
    PointTextTypeOrigin,
    PointTextTypeSize,
}PointTextType;

@interface PointTextLayer : CATextLayer{
    PointTextType type;
    IUBox *iu;
    NSRect iuFrame;
}

- (id)initWithIU:(IUBox *)aIU withFrame:(NSRect)frame type:(PointTextType)aType;
- (void)updateFrame:(NSRect)frame;
- (IUBox *)iu;


@end
