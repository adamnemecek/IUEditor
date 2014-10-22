//
//  WPPageLink.h
//  IUEditor
//
//  Created by jw on 7/15/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUBox.h"
#import "IUProtocols.h"

@interface WPPageLinks : IUBox <IUPHPCodeProtocol, IUSampleHTMLProtocol>

@property (nonatomic) NSInteger leftRightPadding;
@property (nonatomic) IUAlign align;

- (NSString *)containerIdentifier;


@end
