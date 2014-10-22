//
//  JDReponderCollectionView.h
//  IUEditor
//
//  Created by seungmi on 2014. 9. 15..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol JDReponderCollectionViewProtocol <NSObject>
- (void)keyDown:(NSEvent *)event;
@end

@interface JDReponderCollectionView : NSCollectionView{
    IBOutlet  NSViewController <JDReponderCollectionViewProtocol> *viewController;
}

@end
