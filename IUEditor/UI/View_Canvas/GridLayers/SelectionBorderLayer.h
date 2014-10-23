//
//  SelectionBorderLayer.h
//  IUEditor
//
//  Created by test on 2014. 7. 2..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "IUBox.h"

@interface SelectionBorderLayer : CAShapeLayer{
    IUBox *iu;
}

- (id)initWithIU:(IUBox *)aIU withFrame:(NSRect)frame;
- (IUBox *)iu;


@end
