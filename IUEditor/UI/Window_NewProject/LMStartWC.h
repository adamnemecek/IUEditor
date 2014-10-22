//
//  LMStartWC.h
//  IUEditor
//
//  Created by jd on 4/25/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum{
    LMStartWCTypeTemplate,
    LMStartWCTypeDefault,
    LMStartWCTypeRecent,
}LMStartWCType;

@interface LMStartWC : NSWindowController

+ (LMStartWC *)sharedStartWindow;

- (IBAction)selectStartViewOfType:(LMStartWCType)type;

@end
