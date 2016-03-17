//
//  MyLabelNode.m
//  GameDemoNotCreateFromGame
//
//  Created by yurongde on 16/3/17.
//  Copyright © 2016年 yurongde. All rights reserved.
//

#import "MyLabelNode.h"

@implementation MyLabelNode
- (instancetype)initWithFontNamed:(NSString *)fontName {
    self = [super initWithFontNamed:fontName];
    if (!self) {
        return nil;
    }
    
    self.userInteractionEnabled = YES;
    return self;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"点击了tryagain");
    [self.delegate tapOnTryAgain];
}
@end
