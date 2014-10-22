//
//  IUTweetButton.h
//  IUEditor
//
//  Created by seungmi on 2014. 8. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUBox.h"

typedef enum{
    IUTweetButtonCountTypeNone,
    IUTweetButtonCountTypeHorizontal,
    IUTweetButtonCountTypeVertical,
}IUTweetButtonCountType;

typedef enum{
    IUTweetButtonSizeTypeMeidum,
    IUTweetButtonSizeTypeLarge,
    
}IUTweetButtonSizeType;

@interface IUTweetButton : IUBox

@property (nonatomic) NSString *urlToTweet, *tweetText;
@property (nonatomic) IUTweetButtonCountType countType;
@property (nonatomic) IUTweetButtonSizeType sizeType;


//not supported large_size & vertical mode by twitter
- (BOOL)enableLargeVertical;

@end
