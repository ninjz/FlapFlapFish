//
//  StatsLayer.m
//  floppyFish
//
//  Created by sh0gun on 2/28/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import "StatsLayer.h"
#import "MenuScene.h"
#import "Fish.h"
#import "Angler.h"
#import "Narwhal.h"
#import "BlowFish.h"
#import "Angler.h"
#import "Piranha.h"
#import "Skelly.h"

@implementation StatsLayer
{
    CGSize winSize;
    CCSprite *frame;
    CCLabelBMFont *bestScore;
    CCLabelBMFont *bronze;
    CCLabelBMFont *silver;
    CCLabelBMFont *gold;
    Fish *fish;
    
}


-(id)init
{
    self = [super init];
    if (!self) return(nil);
    
    winSize = [[CCDirector sharedDirector] viewSize];
    
    [self updateTocurFish];
    
    
   
    // Create a Menu button
    CCButton *menuButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"button-menu.png"]];
    menuButton.scale = 2;
    [menuButton setPosition:ccp(winSize.width/2, frame.position.y - frame.contentSize.width)];
    [menuButton setTarget:[MenuScene sharedMenuScene] selector:@selector(transitionFromStatsToMain)];
    [self addChild:menuButton];
    
    return self;
}


-(void)updateTocurFish
{
    if([[self children] containsObject:frame]){
        [self removeChild:frame];
    }
    if([[self children] containsObject:bestScore]){
        [self removeChild:bestScore];
    }    if([[self children] containsObject:bronze]){
        [self removeChild:bronze];
    }
    if([[self children] containsObject:silver]){
        [self removeChild:silver];
    }
    if([[self children] containsObject:gold]){
        [self removeChild:gold];
    }
    if ([[self children] containsObject:fish]) {
        [self removeChild:fish];
    }
    
    // Create Frame image
    int curFish = [[GameState sharedGameState] curSelectedFish];
    NSString *curFishString;
    
    
    
    switch (curFish) {
        case 0: // main fish
            frame = [CCSprite spriteWithImageNamed:@"FishStats-Screen-1.png"];
            fish = [[BlowFish alloc] init];
            curFishString = @"Blowfish";
            break;
        case 1: // narwhal
            frame = [CCSprite spriteWithImageNamed:@"FishStats-Screen-2.png"];
            fish = [[Narwhal alloc] init];
            curFishString = @"Narwhal";
            break;
        case 2: // Piranha
            frame = [CCSprite spriteWithImageNamed:@"FishStats-Screen-3.png"];
            fish = [[Piranha alloc] init];
            curFishString = @"Piranha";
            break;
        case 3: // angler
            frame = [CCSprite spriteWithImageNamed:@"FishStats-Screen-4.png"];
            fish = [[Angler alloc] init];
            curFishString = @"Angler";
            break;
        case 4: // Skelly
            frame = [CCSprite spriteWithImageNamed:@"FishStats-Screen-5.png"];
            fish = [[Skelly alloc] init];
            curFishString = @"Zombie";
            break;
    }
    [frame setScale:2];
    [frame setPosition:ccp( winSize.width/2, winSize.height/2)];
    [self addChild:frame];
    
    // setup fish
    [fish setPhysicsBody:nil];
    [fish pose];
    [frame addChild:fish];
    [fish setScale:1];
    [fish setAnchorPoint:ccp(0.5f, 0.5f)];
    [fish setPosition:ccp(frame.contentSize.width/4, frame.contentSize.height*3.3/5)];
    
    bestScore = [[CCLabelBMFont alloc ] initWithFile:@"font.png" capacity:5];
    [bestScore setFntFile:@"font.fnt"];
    [bestScore setString:[NSString stringWithFormat:@"%i", [[[[GameState sharedGameState] highScore] objectAtIndex:curFish] integerValue]]];

    [self addChild:bestScore z:10];
    [bestScore setScale:2];
    [bestScore setAnchorPoint: ccp(0.5f, 0.5f)];
    [bestScore setPosition:(IS_IPAD) ? ccp(frame.position.x + frame.contentSize.width/5, frame.position.y + frame.contentSize.height/3) :
     ccp(frame.position.x + frame.contentSize.width/6, frame.position.y + frame.contentSize.height/3)];

    
    
    
    bronze = [[CCLabelBMFont alloc ] initWithFile:@"font.png" capacity:2];
    [bronze setFntFile:@"font.fnt"];
    [bronze setString:[NSString stringWithFormat:@"%i",
                        [[[[[GameState sharedGameState] currencyCollected] objectForKey:curFishString] objectAtIndex:0] integerValue]]];

    
    
    [self addChild:bronze z:10];
    [bronze setScale:2];
    [bronze setAnchorPoint: ccp(0.5f, 0.5f)];
    [bronze setPosition:(IS_IPAD) ? ccp(frame.position.x - frame.contentSize.width/4.43, frame.position.y - frame.contentSize.height/1.5) :
     ccp(frame.position.x - frame.contentSize.width/4.43, frame.position.y - frame.contentSize.height/1.55)];
    
    
    silver = [[CCLabelBMFont alloc ] initWithFile:@"font.png" capacity:2];
    [silver setFntFile:@"font.fnt"];
    [silver setString:[NSString stringWithFormat:@"%i",
                        [[[[[GameState sharedGameState] currencyCollected] objectForKey:curFishString] objectAtIndex:1] integerValue]]];
    [self addChild:silver z:10];
    [silver setScale:2];
    [silver setAnchorPoint: ccp(0.5f, 0.5f)];
    [silver setPosition:(IS_IPAD) ? ccp(frame.position.x + frame.contentSize.width/4.68, frame.position.y - frame.contentSize.height/1.5) :
     ccp(frame.position.x + frame.contentSize.width/4.68, frame.position.y - frame.contentSize.height/1.55) ];
    
    
    gold = [[CCLabelBMFont alloc ] initWithFile:@"font.png" capacity:2];
    [gold setFntFile:@"font.fnt"];
    [gold setString:[NSString stringWithFormat:@"%i",
                      [[[[[GameState sharedGameState] currencyCollected] objectForKey:curFishString] objectAtIndex:2] integerValue]]];
    
    [self addChild:gold z:10];
    [gold setScale:2];
    [gold setAnchorPoint: ccp(0.5f, 0.5f)];
    [gold setPosition:(IS_IPAD) ? ccp(frame.position.x + frame.contentSize.width/1.53, frame.position.y - frame.contentSize.height/1.5) :
     ccp(frame.position.x + frame.contentSize.width/1.53, frame.position.y - frame.contentSize.height/1.55)];
    
    
    
    
}


-(void) dealloc
{
    CCLOG(@"removing statslayer");
    
    [self removeAllChildrenWithCleanup:YES];
    [bestScore removeAllChildrenWithCleanup:YES];
    bestScore = nil;
    [bronze removeAllChildrenWithCleanup:YES];
    bronze = nil;
    [silver removeAllChildrenWithCleanup:YES];
    silver = nil;
    [gold removeAllChildrenWithCleanup:YES];
    gold = nil;
    frame = nil;
}




@end
