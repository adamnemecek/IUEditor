//
//  SelectionBorderLayer.h
//  IUEditor
//
//  Created by test on 2014. 7. 2..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface SelectionBorderLayer : CAShapeLayer{
    NSString *identifier;
}

- (id)initWithIdentifier:(NSString *)anIdentifier withFrame:(NSRect)frame;
- (NSString *)identifier;


@end
