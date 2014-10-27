//
//  MQShadowLayer.h
//  IUEditor
//
//  Created by seungmi on 2014. 10. 27..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface MQShadowLayer : CAShapeLayer

@property (nonatomic) NSInteger selectedFrameWidth;

- (void)updateMQLayer;

@end
