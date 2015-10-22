//
//  ObstacleCache.m
//  FlapFlap Fish
//
//  Created by sh0gun on 2/27/2014.
//  Copyright 2014 KRACK Games All rights reserved.
//

#import "ObstacleCache.h"




@implementation ObstacleCache

int numLeftInCache = CACHE_SIZE;
int freeIndex = 0;
int init = 0;

-(id)init
{
    if(self=[super init]){
        init = 0;
        freeIndex = 0;
        numLeftInCache = CACHE_SIZE;
        // make a bunch of Obstacles of each type.
        for (int i = 0; i < CACHE_SIZE; i++) {
            obstacles[i] = [Obstacle node];
        }

    }
    
    return self;
}


-(Obstacle *)getUpDownStatic;
{
    if(numLeftInCache > 0){
        Obstacle *obs = obstacles[freeIndex];
        obs.isActive = YES;
        
        numLeftInCache--;
        freeIndex++;
        
        if (freeIndex == CACHE_SIZE) {
            freeIndex = 0;
        }
        
        [obs changeToType:kUpDownStatic];
        return obs;
    } else {
        CCLOG(@"allocating new obstacle");
        Obstacle *newObs = [Obstacle node];
        [newObs changeToType:kUpDownStatic];
        return newObs;
    }
    
}


-(Obstacle *)getUpDownDynamic;
{
    if(numLeftInCache > 0){
        Obstacle *obs = obstacles[freeIndex];
        obs.isActive = YES;
        
        numLeftInCache--;
        freeIndex++;
        if (freeIndex == CACHE_SIZE) {
            freeIndex = 0;
        }
        
        [obs setFirstCalled:YES];
        [obs changeToType:kUpDownDynamic];
        return obs;
    } else {
        CCLOG(@"allocating new obstacle");
        Obstacle *newObs = [Obstacle node];
        [newObs changeToType:kUpDownDynamic];
        return newObs;
    }
    
}

-(Obstacle *)getRotatedStatic;
{
    if(numLeftInCache > 0){
        Obstacle *obs = obstacles[freeIndex];
        obs.isActive = YES;
        
        numLeftInCache--;
        freeIndex++;
        if (freeIndex == CACHE_SIZE) {
            freeIndex = 0;
        }
        
        [obs changeToType:kRotatedStatic];
        return obs;
    } else {
        CCLOG(@"allocating new obstacle");
        Obstacle *newObs = [Obstacle node];
        [newObs changeToType:kRotatedStatic];
        return newObs;
    }
    
}

-(Obstacle *)getRotatedDynamic;
{
    if(numLeftInCache > 0){
        Obstacle *obs = obstacles[freeIndex];
        obs.isActive = YES;
        
        numLeftInCache--;
        freeIndex++;
        if (freeIndex == CACHE_SIZE) {
            freeIndex = 0;
        }
        
        [obs setFirstCalled:YES];
        [obs changeToType:kRotatedDynamic];
        return obs;
    } else {
        CCLOG(@"allocating new obstacle");
        Obstacle *newObs = [Obstacle node];
        [newObs changeToType:kRotatedDynamic];
        return newObs;
    }
    
}

-(void)returnObstacle:(Obstacle *)obstacle
{
    obstacle.visible = NO;
    obstacle.passed = false;
    obstacle.isGroup = NO;
    obstacle.isActive = NO;
    numLeftInCache++;

}



-(Obstacle *)cacheInit
{
    Obstacle *obs = obstacles[init];
    init++;
    return obs;
}

-(void)clearCache
{
//    [_obstacles removeAllObjects];
//    obstacles = nil;
}

@end
