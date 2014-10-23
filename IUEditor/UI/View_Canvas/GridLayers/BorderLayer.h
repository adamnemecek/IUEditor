//
//  borderLayer.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 26..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "IUBox.h"

@interface BorderLayer : CAShapeLayer{
    IUBox *iu;
}

- (id)initWithIU:(IUBox *)aIU withFrame:(NSRect)frame;
- (IUBox *)iu;

@end
