//
//  NarwhalGameScene.m
//  floppyFish
//
//  Created by sh0gun on 2/21/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import "NarwhalGameScene.h"
#import "Narwhal.h"
#import "CCAnimation+Helper.h"


@implementation NarwhalGameScene{
    int nextTap; // 1:right 0:left
}

+ (NarwhalGameScene *)scene
{
    return [[self alloc] init];
}

-(id)init
{
    if(self = [super init])
    {
        self.fish = [[Narwhal alloc] init];
        [_physicsWorld addChild:_fish z:20];
        
        _fish.position = ccp(winSize.width/3, winSize.height/2);
        
        
        
        // Tap prompt
        CCAnimation *tapAnim;
        CCActionAnimate *tap;
        tapPrompt = [CCSprite spriteWithImageNamed:@"Tutorial-Narwhal-1.png"];
        
        tapAnim = [CCAnimation animationWithFrame:@"Tutorial-Narwhal-"
                                       frameCount:2
                                            delay:0.2f];
        
        if (FLAPPYMODE_ON) {
            self.spaceBetweenObstacles = 215;
        } else {
            self.spaceBetweenObstacles = 220;
        }
        
        
        tap = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:tapAnim]];
        [tapPrompt runAction:tap];
        
        
        [self addChild:tapPrompt z:20];
        [tapPrompt setScale:2];
        [tapPrompt setPosition:ccp(winSize.width/2 + tapPrompt.contentSize.width/2, winSize.height/2 ) ];
        
        
         [self initObstacles];
    }
    return self;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    // regular flop movement
    if (!self.isGameStarted) {
        [tapPrompt runAction:[CCActionSequence actionOne:[CCActionFadeOut actionWithDuration:0.2f] two:[CCActionCallBlock actionWithBlock:^{
            [tapPrompt setVisible:NO];
        }]]];
        
        [getReady runAction:[CCActionSequence actionOne:[CCActionFadeOut actionWithDuration:0.2f] two:[CCActionCallBlock actionWithBlock:^{
            [getReady setVisible:NO];
        }]]];
        
        self.isGameStarted = YES;
    }
    
    [_fish flop];

}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    //    if (!isGameStarted) {
    //        [tapPrompt runAction:[CCActionFadeOut actionWithDuration:0.2f]];
    //        isGameStarted = YES;
    //
    //    }
    //
    //    [_fish flop];
    
}

@end
