//
//  JDMemoryCheckVC.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 12. 22..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "JDMemoryCheck.h"

static JDMemoryChecker *memoryChecker;

@implementation JDMemoryChecker
@synthesize set;

- (id)init{
    self = [super init];
    set = [NSCountedSet set];
    return self;
}

+(JDMemoryChecker *)sharedChecker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        memoryChecker = [[JDMemoryChecker alloc] init];
    });
    return memoryChecker;
}

-(void)objDidAllocated:(NSString *)className {
    [set addObject:className];
}

-(void)objWillDeallocated:(NSString *)className {
    [set removeObject:className];
    [self.delegate memoryCheckerObjectWillDeallocated:className aliveObjectCount:set.count];
}

-(void)fireMemoryCheckAfterDelay:(NSTimeInterval)sec {
    [self performSelector:@selector(memoryCheck) withObject:nil afterDelay:sec];
}

-(void)memoryCheck {
    if (self.set.count == 0) {
        NSLog(@"[MemoryChecker] All released ");
    }
    else {
        NSLog(@"[MemoryChecker] ------- ");
        NSLog([)
        NSLog(@"------------------------");
    }
}

@end

@interface JDMemoryCheckVC ()

@end

@implementation JDMemoryCheckVC

- (id)init {
    self = [super init];
    [[JDMemoryChecker sharedChecker] objDidAllocated:self.className];
    return self;
}

- (id)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    [[JDMemoryChecker sharedChecker] objDidAllocated:self.className];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [[JDMemoryChecker sharedChecker] objDidAllocated:self.className];
    return self;
}


- (void)dealloc {
    [[JDMemoryChecker sharedChecker] objWillDeallocated:self.className];
}

@end
