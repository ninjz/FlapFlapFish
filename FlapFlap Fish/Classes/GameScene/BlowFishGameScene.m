//
//  BlowFishGameScene.m
//  floppyFish
//
//  Created by sh0gun on 2/20/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import "BlowFishGameScene.h"
#import "BlowFish.h"
#import "CCAnimation+Helper.h"



@implementation BlowFishGameScene

+ (BlowFishGameScene *)scene
{
    return [[self alloc] init];
}


-(id)init
{
    if(self = [super init])
    {
        self.fish = [[BlowFish alloc] init];
        [_physicsWorld addChild:_fish z:3];
        _fish.position = ccp(winSize.width/3, winSize.height/2);
        
        // Tap prompt
        CCAnimation *tapAnim;
        CCActionAnimate *tap;
        tapPrompt = [CCSprite spriteWithImageNamed:@"Tutorial-Puffer-1.png"];
        
        tapAnim = [CCAnimation animationWithFrame:@"Tutorial-Puffer-"
                                       frameCount:3
                                            delay:0.4f];
        
        if (FLAPPYMODE_ON) {
            self.spaceBetweenObstacles = 198;
        } else {
            self.spaceBetweenObstacles = 220;
        }
        
        
        
        tap = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:tapAnim]];
        [tapPrompt runAction:tap];
        
        [self addChild:tapPrompt z:4];
        [tapPrompt setScale:2];
        [tapPrompt setPosition:ccp(winSize.width/2 + tapPrompt.contentSize.width/2, winSize.height/2 ) ];

        [self initObstacles];
        
        
    }
    return self;
}

- (BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
                monsterCollision:(CCNode *)monster
             projectileCollision:(CCNode *)projectile
{
    __autoreleasing CCPhysicsShape *a;
    __autoreleasing CCPhysicsShape *b;
    
    [pair shapeA:&a shapeB:&b];
    
    if ([_fish state] == AnimationStateDiving) {
        if([[a collisionGroup] isEqualToString:@"uninflated"] || [[b collisionGroup] isEqualToString:@"uninflated"]){
            goto ack;
        } else {
            return NO;
        }
    } else if ([_fish state] == AnimationStateFlopping){
        if([[a collisionGroup] isEqualToString:@"inflated"] || [[b collisionGroup] isEqualToString:@"inflated"]){
            goto ack;
        } else {
            return NO;
        }
    }
    
ack:
    
    
    // anything in here will only get called once on death b/c this gets called multiple times somtimes
    if([_fish alive]){
        
        [super gameOver];
    }
    
    return YES;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!self.isGameStarted) {
        [tapPrompt runAction:[CCActionSequence actionOne:[CCActionFadeOut actionWithDuration:0.2f] two:[CCActionCallBlock actionWithBlock:^{
            [tapPrompt setVisible:NO];
        }]]];
        
        [getReady runAction:[CCActionSequence actionOne:[CCActionFadeOut actionWithDuration:0.2f] two:[CCActionCallBlock actionWithBlock:^{
            [getReady setVisible:NO];
        }]]];
        
        
        self.isGameStarted = YES;
        
    }
    
    [(BlowFish*)_fish stopDive];
    
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [(BlowFish*)_fish dive];
    
}


@end
