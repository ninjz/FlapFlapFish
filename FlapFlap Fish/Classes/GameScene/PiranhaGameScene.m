//
//  PiranhaGameScene.m
//  floppyFish
//
//  Created by sh0gun on 2/23/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import "PiranhaGameScene.h"
#import "Piranha.h"
#import "CCAnimation+helper.h"


@implementation PiranhaGameScene
{
    int nextTap; // 1:right 0:left
}

+ (PiranhaGameScene *)scene
{
    return [[self alloc] init];
}


-(id)init
{
    if(self = [super init])
    {
        self.fish = [[Piranha alloc] init];
        [_physicsWorld addChild:_fish z:20];
        _fish.position = ccp(winSize.width/3, winSize.height/2);
        
        if (FLAPPYMODE_ON) {
            self.spaceBetweenObstacles = 225;
        } else {
            self.spaceBetweenObstacles = 230;
        }
        
        // Tap prompt
        CCAnimation *tapAnim;
        CCActionAnimate *tap;
        tapPrompt = [CCSprite spriteWithImageNamed:@"Tutorial-Piranha-1.png"];
        
        tapAnim = [CCAnimation animationWithFrame:@"Tutorial-Piranha-"
                                       frameCount:4
                                            delay:0.4f];
        
        
        
        
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
    // left-right touch movement
    CGPoint point = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    if (!self.isGameStarted) {
        [tapPrompt runAction:[CCActionSequence actionOne:[CCActionFadeOut actionWithDuration:0.2f] two:[CCActionCallBlock actionWithBlock:^{
            [tapPrompt setVisible:NO];
        }]]];
        
        [getReady runAction:[CCActionSequence actionOne:[CCActionFadeOut actionWithDuration:0.2f] two:[CCActionCallBlock actionWithBlock:^{
            [getReady setVisible:NO];
        }]]];
        
        self.isGameStarted = YES;
        if(point.x < winSize.width/2){
            nextTap = 1;
            [_fish flop];
        } else if (point.x >= winSize.width/2){
            nextTap = 0;
            [_fish flop];
        }
    } else{
        
        if(point.x < winSize.width/2 && nextTap == 0){
            nextTap = 1;
            [_fish flop];
        } else if (point.x >= winSize.width/2 && nextTap == 1){
            nextTap = 0;
            [_fish flop];
        }
    }
    
    
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
