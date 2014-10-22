//
//  IUProtocols.h
//  IUEditor
//
//  Created by jd on 2014. 8. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IUSampleHTMLProtocol
/* An Object which conform IUSampleHTMLProtocol should have one of following functions */
@optional
- (NSString*)sampleInnerHTML;
- (NSString*)sampleHTML;
@end

/**
 IUCode Protocol Coding Order
 
 (NSString*)code
 [children]
 (NSString*)codeAfterChildren
 */
@protocol IUPHPCodeProtocol

@optional
- (NSString*)code;
- (NSString*)codeAfterChildren;
@end

@protocol IUWordpressCodeProtocol
@optional
- (NSString*)functionCode;
@end