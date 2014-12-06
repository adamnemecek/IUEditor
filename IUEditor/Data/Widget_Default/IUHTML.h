//
//  IUHTML.h
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 15..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUBox.h"

/**
 IUHTML cannot have children. It draws HTML directly. 
 */
@interface IUHTML : IUBox

@property (nonatomic) NSString *innerHTML;
-(BOOL)hasInnerHTML;


@end
