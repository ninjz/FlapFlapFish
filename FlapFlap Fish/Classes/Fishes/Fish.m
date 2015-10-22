//
//  Fish.m
//  floppyFish
//
//  Created by sh0gun on 2/13/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import "Fish.h"
#import "GameScene.h"
#import "CCAnimation+Helper.h"
#import "OALSimpleAudio.h"
#import "BlowFish.h"


@implementation Fish

-(id)init{
    self = [super init];
    if (!self) return(nil);
    return self;
}



-(void)kill
{
    allowFlop = false;
    _alive = false;
    flopping = false;
    falling = true;
    
    
}

-(void)dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    self.jumpRotation = nil;
    self.fallAction = nil;
    self.floppingAnim = nil;
    self.divingAnim = nil;
    
}

-(void)flop{}

-(void)updateMe:(CCTime)delta{}

-(void)pose
{
    if ([self isKindOfClass:[BlowFish class]]) {
        [(BlowFish *)self idle];
    } else {
        [self stopAction:_floppingAnim];
    }
    
    
    [skin stopAllActions];
    
}

@end
