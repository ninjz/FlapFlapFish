//
//  GameScene.h
//  floppyFish
//
//  Created by sh0gun on 2/13/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "ScoreBoardLayer.h"
#import "Fish.h"
#import "Obstacle.h"

@interface GameScene : CCScene  <CCPhysicsCollisionDelegate>
{
    Fish *_fish;
    CCSprite *_bg1;
    CCSprite *_bg2;
    CGSize winSize;
    CCLabelBMFont *_scoreDisplay;
    CCPhysicsNode *_physicsWorld;
    CCSpriteBatchNode *batchDraw;
    
    ScoreBoardLayer *scoreboard;
    CCSprite *tapPrompt;
    CCSprite *getReady;
    
    int obstacleMaxHeight;// for base of top obstacle
    int obstacleMinHeight;
    //    int spaceBetweenTopBottom;
    //    int spaceBetweenObstacles;
    BOOL flashed;
    
    
    Obstacle *obstacles[CACHE_SIZE];
}

@property (nonatomic, readonly)int score;
@property (nonatomic, readonly)int max;
@property (nonatomic, assign)int spaceBetweenObstacles;
@property (nonatomic, readonly)int min;
@property (nonatomic, strong) Fish *fish;
@property (nonatomic) CCSprite *bg1;
@property (nonatomic) CCSprite *bg2;
@property (nonatomic) CCSprite *ground1;
@property (nonatomic) CCSprite *ground2;
@property (nonatomic) CCSprite *farBack;
@property (nonatomic) BOOL gameState;
@property (nonatomic) BOOL isGameStarted;
@property (nonatomic) BOOL newUnlock;


@property (nonatomic, assign) BOOL isGameover;


+(GameScene *) sharedGameScene;
// -----------------------------------------------------------------------

+ (GameScene *)scene;
- (id)init;
-(void) initObstacles;
-(void) flashWhite;
-(void)moveScoreBoardUp;
-(void) moveScoreBoardDown;
- (void)showTopBannerAd;
- (void)showBottomBannerAd;
- (void)hideBannerAd;
-(void) gameOver;
// -----------------------------------------------------------------------

@end
