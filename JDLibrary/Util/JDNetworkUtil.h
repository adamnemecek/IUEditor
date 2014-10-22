//
//  JDNetworkUtil.h
//  IUEditor
//
//  Created by jd on 2014. 7. 9..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDNetworkUtil : NSObject

/**
 Chack port is available
 @return YES if port is not occupied, NO if not
 */
+ (BOOL) isPortAvailable:(NSInteger)port;

/**
 Chack port is available
 @return PID of port.
 @note if port is available, return NSNotFound.
 */
+ (NSInteger) pidOfPort:(NSInteger)port;

+ (NSString*) processNameOfPort:(NSInteger)port;
@end
