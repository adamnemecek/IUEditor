//
//  WPMenu.h
//  IUEditor
//
//  Created by jd on 2014. 7. 16..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUBox.h"
#import "IUProtocols.h"

@interface WPMenu : IUBox <IUPHPCodeProtocol, IUSampleHTMLProtocol>
@property (nonatomic) NSInteger itemCount;
@property (nonatomic) NSInteger leftRightPadding;
@property (nonatomic) IUAlign align;


- (NSString *)containerIdentifier;
- (NSString *)itemIdetnfier;

@end
