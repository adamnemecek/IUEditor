//
//  borderLayer.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 26..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface BorderLayer : CAShapeLayer{
    NSString *identifier;
}

- (id)initWithIdentifier:(NSString *)anIdentifier withFrame:(NSRect)frame;
- (NSString *)identifier;

@end
