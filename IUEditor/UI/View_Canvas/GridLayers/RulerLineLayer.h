//
//  RulerLineLayer.h
//  IUEditor
//
//  Created by seungmi on 2014. 10. 28..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface RulerLineLayer : CAShapeLayer

-(id)initWithOrientation:(NSRulerOrientation)anOrientation;

@property NSString *markerIdentifer;
@property (nonatomic) CGFloat location;

@end
