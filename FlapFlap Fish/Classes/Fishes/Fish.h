//
//  Fish.h
//  floppyFish
//
//  Created by sh0gun on 2/13/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


// -----------------------------------------------------------------------
// Different Animation states of the Fish.
typedef NS_ENUM(NSInteger, AnimationState)
{
    AnimationStateFlopping,
    AnimationStateDiving,
    AnimationStateDead,
};


@interface Fish : CCSprite{
    CGPoint velocity;
    CGPoint acceleration;
    CGPoint gravity;
    
    BOOL falling;
    BOOL flopping;
    BOOL allowFlop;
    float targetY;
    float yThresh;
    
    CGSize winSize;
    
    
    BOOL wearingSkin;
    NSMutableDictionary *skinsOwned;
    NSString *equippedSkin;
    
    CCSprite *skin;
}

// -----------------------------------------------------------------------
//@property (nonatomic, readonly) CCSprite *fish;
@property(nonatomic, assign)float swimSpeed;
@property(nonatomic, strong)CCActionAnimate *deadAnim;
@property(nonatomic, strong)CCActionAnimate *floppingAnim;
@property(nonatomic, strong)CCActionAnimate *divingAnim;
@property(nonatomic, strong)CCActionRotateTo *jumpRotation;
@property(nonatomic, strong)CCActionRotateTo *fallAction;
@property(nonatomic)AnimationState state;
@property(nonatomic)BOOL alive;



// -----------------------------------------------------------------------

-(id)init;
-(void)flop;
-(void)updateMe:(CCTime)delta;
-(void)kill;
// -----------------------------------------------------------------------
-(void)tryOutFit:(NSString *)outfit;
// for Wally
-(void)tryOutFit:(NSString *)outfit
      isHornless:(BOOL)isHornless;

-(void)takeOffOutfit;
-(void)pose;
@end
