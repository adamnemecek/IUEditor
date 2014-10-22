//
//  WPSidebar.h
//  IUEditor
//
//  Created by jd on 8/14/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUBox.h"
#import "IUProtocols.h"

@interface WPSidebar : IUBox <IUPHPCodeProtocol, IUSampleHTMLProtocol>

@property (nonatomic) NSString *wordpressName;
//@property (nonatomic) NSInteger widgetCount;

@end
