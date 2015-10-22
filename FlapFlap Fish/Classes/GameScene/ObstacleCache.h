//
//  ObstacleCache.h
//  floppyFish
//
//  Created by sh0gun on 2/27/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Obstacle.h"

@interface ObstacleCache : NSObject {
    Obstacle *obstacles[CACHE_SIZE];
}

//@property(nonatomic, strong) NSMutableArray *obstacles;


-(Obstacle *)getUpDownStatic;
-(Obstacle *)getUpDownDynamic;
-(Obstacle *)getRotatedStatic;
-(Obstacle *)getRotatedDynamic;
-(void)returnObstacle:(Obstacle *)obstacle;
-(void)clearCache;

-(Obstacle *)cacheInit;

@end
