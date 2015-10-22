//
//  OctoBoss.m
//  FlapFlap Fish
//
//  Created by sh0gun on 3/10/2014.
//  Copyright 2014 Krack Games. All rights reserved.
//

#import "OctoBoss.h"
#import "CCAnimation+Helper.h"


@implementation OctoBoss{
    CCActionRepeatForever *idle;
    CCActionRepeatForever *talk;
    CCActionRepeatForever *rage;
}

-(id)init
{
    if (self=[super initWithImageNamed:@"Character-TheBoss-Idle-1.png"]) {
        CCAnimation *idleAnim, *talkAnim, *rageAnim;
        
        self.scale = 2;
        
        idleAnim = [CCAnimation animationWithFrame:@"Character-TheBoss-Idle-" frameCount:4 delay:0.2f];
        talkAnim = [CCAnimation animationWithFrame:@"Character-TheBoss-Talk-" frameCount:2 delay:0.3f];
        rageAnim = [CCAnimation animationWithFrame:@"Character-TheBoss-Rage-" frameCount:2 delay:0.3f];
        
        idle = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:idleAnim]];
        talk = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:talkAnim]];
        rage = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:rageAnim]];
        
        [self runAction:idle];
    }
    return self;
}

-(void)idle
{
    [self stopAllActions];
    [self runAction:idle];
}


-(void)talk
{
    [self stopAllActions];
    [self runAction:talk];
}

-(void)rage
{
    [self stopAllActions];
    [self runAction:rage];
}


@end
