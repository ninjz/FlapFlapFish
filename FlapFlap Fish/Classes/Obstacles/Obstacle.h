//
//  Obstacle.h
//  floppyFish
//
//  Created by sh0gun on 2/16/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


// -----------------------------------------------------------------------
// Different Animation states of the Fish.
typedef NS_ENUM(NSInteger, ObstacleType)
{
    kUpDownStatic,
    kUpDownDynamic,
    kRotatedStatic,
    kRotatedDynamic,
};

typedef NS_ENUM(NSInteger, RotationDirection)
{
    kDirNE,
    kDirNW,
};



@interface Obstacle : CCSprite {
    RotationDirection rDir;
}

@property(nonatomic, assign) BOOL passed;
@property(nonatomic, assign) BOOL inPhysicsWorld;
@property(nonatomic, assign) BOOL isActive;
@property(nonatomic, assign) BOOL isGroup;
@property(nonatomic, assign) BOOL moveDown;      // for dynamic
@property(nonatomic) ObstacleType type;


// needed for when obstacle is dynamic
@property(nonatomic, assign) BOOL firstCalled;





-(id)init;
-(void)changeToType:(ObstacleType)type;
-(void)scroll:(CCTime)dt;
// Dynamic
-(void)movement:(CCTime)dt;

@end
