//
//  IUMovie.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 21..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUBox.h"

@interface IUMovie : IUBox

@property (nonatomic) NSString *videoPath;
@property NSString  *posterPath;
@property (nonatomic) NSString  *altText;

@property (nonatomic) BOOL enableControl, enableLoop, enableAutoPlay, enableMute;
@property (nonatomic) BOOL cover;

@end
