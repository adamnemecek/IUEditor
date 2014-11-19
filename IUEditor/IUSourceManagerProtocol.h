//
//  IUSourceManagerProtocol.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#ifndef IUEditor_IUSourceManagerProtocol_h
#define IUEditor_IUSourceManagerProtocol_h


@protocol IUSourceManagerProtocol

-(void)setNeedsUpdateHTML:(id)obj;
-(void)setNeedsUpdateCSS:(id)obj;
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;
- (id)evaluateWebScript:(NSString *)script;

@end


#endif
