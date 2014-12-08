//
//  IUTestWC.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "IUSourceManager.h"

@protocol IUTestWCDelegate <NSObject>

- (void)testWCReturned:(BOOL)result;

@end

@interface IUTestWC : NSWindowController <IUSourceManagerDelegate>

@property NSString *testModule;
@property int       testNumber;
@property NSString *log;
@property (weak) IBOutlet NSView *testView;

@property __weak id <IUTestWCDelegate>  delegate;
@property (weak) IBOutlet WebView *webView;
- (IUSourceManager *)sourceManager;

@end
