//
//  BBExpandableView.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBExpandableView.h"

@implementation BBExpandableView{
    BOOL _isExpanded;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)setClosureButton:(NSButton *)closureButton{
    _closureButton = closureButton;
    _isExpanded = [closureButton state];
}

- (IBAction)clickExpandableButton:(id)sender{
    _isExpanded = !_isExpanded;
    
    NSButton *expandableButton = sender;
    [expandableButton setState:_isExpanded];
    
    if([self.delegate respondsToSelector:@selector(reloadData)]){
        [self.delegate performSelector:@selector(reloadData)];
    }
}

- (CGFloat)currentHeight{
    if(_isExpanded){
        return _parentView.frame.size.height + _childView.frame.size.height;
    }
    else{
        return _parentView.frame.size.height;
    }
}

@end
