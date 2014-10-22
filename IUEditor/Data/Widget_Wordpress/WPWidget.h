//
//  WPWidget.h
//  IUEditor
//
//  Created by jd on 8/16/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUBox.h"
#import "IUProtocols.h"

#import "WPWidgetTitle.h"
#import "WPWidgetBody.h"


@interface WPWidget : IUBox

-(NSString*)sampleHTML;

@property WPWidgetTitle *titleWidget;
@property WPWidgetBody  *bodyWidget;
@end
