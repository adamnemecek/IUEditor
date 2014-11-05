//
//  IUSourceController.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUSourceManager.h"
#import "IUCompiler.h"
#import "IUBox.h"

@implementation IUSourceManager

- (void)setCanvasVC:(id <IUSourceManagerDelegate>)canvasVC{
    
}

- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args{
    return nil;
}

- (void)setNeedsUpdateHTML:(IUBox *)box{
    return;
}

- (void)setNeedsUpdateCSS:(IUBox*)box{
    
}

- (void)beginTransaction:(id)sender{
    
}
- (void)commitTransaction:(id)sender{
    
}

- (void)setCompiler:(IUCompiler *)compiler{
    
}

@end
