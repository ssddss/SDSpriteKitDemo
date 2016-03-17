//
//  GameScene.m
//  OneCatGameDemo
//
//  Created by yurongde on 16/3/17.
//  Copyright (c) 2016年 yurongde. All rights reserved.
//

#import "GameScene.h"
#import "ResultScene.h"

@interface GameScene()
@property (nonatomic, strong) NSMutableArray *monsters;
@property (nonatomic, strong) NSMutableArray *projectiles;

@property (nonatomic, assign) int monstersDestroyed;/**< 消失的怪兽数*/

@end
@implementation GameScene

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (!self) {
        return nil;
    }
    
    self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    SKSpriteNode *player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
    
    player.position = CGPointMake(player.size.width/2, size.height/2);
    
    [self addChild:player];
    
    //5 Repeat add monster to the scene every 1 second.

    SKAction *actionAddMonster = [SKAction runBlock:^{
        [self addMonster];
    }];
    SKAction *actionWaitNextMonster = [SKAction waitForDuration:1];
    
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[actionAddMonster,actionWaitNextMonster]]]];
    
    return self;
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = @"Hello, World!";
    myLabel.fontSize = 45;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    myLabel.fontColor = [SKColor colorWithWhite:0.0 alpha:1.0];
    [self addChild:myLabel];
    
    SKLabelNode *myLabel1= [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel1.text = @"Hell0!";
    myLabel1.fontSize = 45;
    myLabel1.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame)+30);
    
    [self addChild:myLabel1];

    SKSpriteNode *player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
    
    player.position = CGPointMake(player.size.width/2 + 50, CGRectGetMidY(self.frame));
    
    
    SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
    
    [player runAction:[SKAction repeatActionForever:action]];
    
    [self addChild:player];
    
}

- (void)addMonster {
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    
    //1 Determine where to spawn the monster along the Y axis

    CGSize winSize = self.size;
    int minY = monster.size.height/2;
    int maxY = winSize.height - monster.size.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    //2 Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    
    monster.position = CGPointMake(winSize.width, actualY);
    [self addChild:monster];
    
    [self.monsters addObject:monster];
    
    //3 Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    //4 Create the actions. Move monster sprite across the screen and remove it from scene after finished.
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    
    SKAction *actiomMoveDone = [SKAction runBlock:^{
        [monster removeFromParent];
        [self.monsters removeObject:monster];
        [self changeToResultSceenWithWon:NO];
        //TODO: SHOW FAIL SCENE
    }];
    
    [monster runAction:[SKAction sequence:@[actionMove,actiomMoveDone]]];
    
}
- (void)changeToResultSceenWithWon:(BOOL)won {
    
    ResultScene *rs = [[ResultScene alloc]initWithSize:self.size won:won];
    SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionUp duration:1.0];
    [self.scene.view presentScene:rs transition:reveal];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        //1 Set up initial location of projectile
        CGSize winSize = self.size;
        SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile.png"];
        projectile.position = CGPointMake(projectile.size.width/2, winSize.height/2);
        
        //2 Get the touch location tn the scene and calculate offset
        CGPoint location = [touch locationInNode:self];
        CGPoint offset = CGPointMake(location.x - projectile.position.x, location.y - projectile.position.y);
        
        // Bail out if you are shooting down or backwards
        if (offset.x <= 0) return;
        // Ok to add now - we've double checked position
        [self addChild:projectile];
        
        [self.projectiles addObject:projectile];
        
        int realX = winSize.width + (projectile.size.width/2);
        float ratio = (float) offset.y / (float) offset.x;
        int realY = (realX * ratio) + projectile.position.y;
        CGPoint realDest = CGPointMake(realX, realY);
        
        //3 Determine the length of how far you're shooting
        int offRealX = realX - projectile.position.x;
        int offRealY = realY - projectile.position.y;
        float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
        float velocity = self.size.width/1; // projectile speed.
        float realMoveDuration = length/velocity;
        
        //4 Move projectile to actual endpoint
        [projectile runAction:[SKAction moveTo:realDest duration:realMoveDuration] completion:^{
            [projectile removeFromParent];
        }];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    NSMutableArray *projectilesToDelete = [NSMutableArray array];
    for (SKSpriteNode *projectile in self.projectiles) {
        
        NSMutableArray *monstersToDelete = [NSMutableArray array];
        
        for (SKSpriteNode *monster in self.monsters) {
            if (CGRectIntersectsRect(projectile.frame, monster.frame)) {
                [monstersToDelete addObject:monster];
            }
        }
        
        for (SKSpriteNode *monster in monstersToDelete) {
            [self.monsters removeObject:monster];
            [monster removeFromParent];
            self.monstersDestroyed++;
            if (self.monstersDestroyed > 10) {
                [self changeToResultSceenWithWon:YES];

            }
        }
        
        if (monstersToDelete.count > 0) {
            [projectilesToDelete addObject:projectile];
        }
        
    }
    
    for (SKSpriteNode *projectile in projectilesToDelete) {
        [self.projectiles removeObject:projectile];
        [projectile removeFromParent];
    }
    
}
#pragma mark - getters and setters
- (NSMutableArray *)monsters {
    if (!_monsters) {
        _monsters = [NSMutableArray array];
    }
    return _monsters;
}
- (NSMutableArray *)projectiles {
    if (!_projectiles) {
        _projectiles = [NSMutableArray array];
    }
    return _projectiles;
}
@end
