//
//  JDClickBox.h
//  IUEditor
//
//  Created by seungmi on 2014. 8. 29..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol JDResponderBoxProtocol <NSObject>
- (void)doubleClick:(NSEvent *)event;
@end

@interface JDResponderBox : NSBox

@property IBOutlet id <JDResponderBoxProtocol> delegate;

@end
