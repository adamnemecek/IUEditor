//
//  BBJSManagerProtocol.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 10..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#ifndef IUEditor_BBJSManagerProtocol_h
#define IUEditor_BBJSManagerProtocol_h

@protocol BBJSManagerProtocol

@required
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;
- (id)evaluateWebScript:(NSString *)script;

@end;

#endif
