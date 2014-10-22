//
//  IUWebMovie.h
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 16..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUHTML.h"

typedef enum{
    IUWebMoviePlayTypeNone,
    IUWebMoviePlayTypeAutoplay,
    IUWebMoviePlayTypeJSAutoplay,
}IUWebMoviePlayType;

typedef enum{
    IUWebMovieTypeYoutube,
    IUWebMovieTypeVimeo,
    IUWebMovieTypeUnknown,
    
}IUWebMovieType;

@interface IUWebMovie : IUBox

@property BOOL      thumbnail;
@property NSString *thumbnailID;
@property  NSString *thumbnailPath;

//connect to VC

@property (nonatomic) NSString *movieLink, *movieID;
@property (nonatomic) IUWebMovieType movieType;
@property (nonatomic) IUWebMoviePlayType playType;
@property (nonatomic) BOOL enableLoop;

@end
