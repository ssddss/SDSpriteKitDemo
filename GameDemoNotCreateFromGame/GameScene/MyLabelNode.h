//
//  MyLabelNode.h
//  GameDemoNotCreateFromGame
//
//  Created by yurongde on 16/3/17.
//  Copyright © 2016年 yurongde. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@protocol MyLabelNodeDelegate <NSObject>
- (void)tapOnTryAgain;
@end
@interface MyLabelNode : SKLabelNode
@property (nonatomic, weak) id<MyLabelNodeDelegate> delegate;
@end
