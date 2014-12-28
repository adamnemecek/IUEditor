//
//  IUHTML.h
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 15..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUBox.h"

#define IUInnerHTMLKey @"IUInnerHTML"

/**
 @description insert HTML code directly.
 As converting to storage mode, 'innerHTML' will saved at default data storage, with IUInnerHTMLKey.
 @note You should save innerHTML to defaultPropertyStorage.
 */
@interface IUHTML : IUBox

@property (nonatomic) NSString *innerHTML;
-(BOOL)hasInnerHTML;


@end
