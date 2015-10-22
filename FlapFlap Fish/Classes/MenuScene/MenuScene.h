//
//  MenuScene.h
//  floppyFish
//
//  Created by sh0gun on 2/15/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "Fish.h"

#import "MainMenuLayer.h"
#import "StatsLayer.h"
#import "CharSelectLayer.h"

typedef NS_ENUM(NSInteger, BGSceneMode)
{
    FLAPFLAPFISH_BG,
    FLAPPYBIRD_BG,
};

#define BG_TRANSITION_TIME 1.15f

@interface MenuScene : CCScene

@property(nonatomic) MainMenuLayer *mainMenu;
@property(nonatomic) CharSelectLayer *charSelectMenu;
@property(nonatomic) StatsLayer *statsMenu;

@property(nonatomic, assign) BOOL allowClick;


+ (MenuScene *) sharedMenuScene;
+ (MenuScene *)scene;
- (id)init;

- (void)onStartClicked;
- (void)transitionFromCharSelectToMain;
- (void)transitionFromStatsToMain;
- (void)transitionFromMainToStats;
- (void)transitionFromMainToCharSelect;
- (void)selectNewFish:(Fish *)newFish;
- (void)purchaseRemoveAds;
- (void)to8Armory;


@end
