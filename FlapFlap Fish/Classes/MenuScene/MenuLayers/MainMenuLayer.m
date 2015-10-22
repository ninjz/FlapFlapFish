//
//  MainMenuLayer.m
//  floppyFish
//
//  Created by sh0gun on 2/15/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import "MainMenuLayer.h"
#import "FFFishIAPHelper.h"
#import "MenuScene.h"
#import "GameScene.h"
#import "The8Armory.h"
#import "CCAnimation+Helper.h"



@implementation MainMenuLayer{
    CGSize winSize;
    CCButton *IAPButton;
    CCButton *restoreButton;
}



-(id)init
{
    self = [super init];
    if (!self) return(nil);
    
    winSize = [[CCDirector sharedDirector] viewSize];
    
    
    
    // Create a start button
    CCButton *startButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"button-startgame.png"]];
    startButton.scale = 2;
    [startButton setPosition:(IS_IPAD) ? ccp(winSize.width/2, winSize.height - winSize.height/1.9) : ccp(winSize.width/2, winSize.height - winSize.height/2)];
    [startButton setTarget:[MenuScene sharedMenuScene] selector:@selector(onStartClicked)];
    [self addChild:startButton];
    
    // Create a charSelect button
    CCButton *charSelectButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"button-selectfish.png"]];
    charSelectButton.scale = 2;
    [charSelectButton setPosition:ccp(winSize.width/2, startButton.position.y  - startButton.contentSize.height*2.5)];
    [charSelectButton setTarget:[MenuScene sharedMenuScene] selector:@selector(transitionFromMainToCharSelect)];
    [self addChild:charSelectButton];
    
    // Create a score button
    CCButton *statsButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Button-Stats.png"]];
    statsButton.scale = 2;
    [statsButton setPosition:ccp(winSize.width/2, charSelectButton.position.y - charSelectButton.contentSize.height*2.5)];
    [statsButton setTarget:[MenuScene sharedMenuScene] selector:@selector(transitionFromMainToStats)];
    [self addChild:statsButton];
    
    // The 8 Armory store
    CCButton *the8Armory = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Button-Armory.png"]];
    the8Armory.scale = 2;
    [the8Armory setPosition:ccp(the8Armory.contentSize.width*1.5, winSize.height - the8Armory.contentSize.height*1.5)];
    [the8Armory setTarget:[MenuScene sharedMenuScene] selector:@selector(to8Armory)];
    [self addChild:the8Armory];
    
    
    
    IAPButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Button-RemoveAds-1.png"]];
    IAPButton.scale = 2;
    [IAPButton setPosition:ccp(winSize.width/2, statsButton.position.y  - statsButton.contentSize.height*2.5)];
    [IAPButton setTarget:[MenuScene sharedMenuScene] selector:@selector(purchaseRemoveAds)];
    [self addChild:IAPButton z:30];
    [IAPButton setVisible:NO];
    
    
    
    restoreButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Buttons-Restore-1.png"]];
    restoreButton.scale = 2;
    [restoreButton setPosition:ccp(winSize.width/2, IAPButton.position.y  - IAPButton.contentSize.height*2.5)];
    [restoreButton setTarget:[FFFishIAPHelper sharedInstance] selector:@selector(restoreCompletedTransactions)];
    [self addChild:restoreButton z:30];
    [restoreButton setVisible:NO];
    
    [self addIAP];
    
    CCButton *fbButton = [[CCButton alloc] initWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Button-Facebook-Like.png" ]];
    [fbButton setScale:2];
    [fbButton setPosition:ccp(fbButton.contentSize.width * 1.5, fbButton.contentSize.width *1.5)];
    [fbButton setTarget:self selector:@selector(fbButtonTap)];
    [self addChild:fbButton];
    
    
    
    
    return self;
}

-(void)addIAP
{
    if(![[GameState sharedGameState] adsRemoved]){
        [IAPButton setVisible:YES];
        [restoreButton setVisible:YES];
        
        [IAPButton.background runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:[CCAnimation animationWithFrame:@"Button-RemoveAds-" frameCount:2 delay:0.2f]]]];
        
        [restoreButton.background runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:[CCAnimation animationWithFrame:@"Buttons-Restore-" frameCount:2 delay:0.2f]]]];
    }
}

- (void)removeIAP
{
    [restoreButton setVisible:NO];
    [IAPButton setVisible:NO];
}

-(void)fbButtonTap {
    NSURL *fbURL = [[NSURL alloc] initWithString:@"fb://profile/255316494646803"];
    // check if app is installed
    if ( ! [[UIApplication sharedApplication] canOpenURL:fbURL] ) {
        // if we get here, we can't open the FB app.
        fbURL = [[NSURL alloc] initWithString:@"https://www.facebook.com/FlapFlapFish"]; // direct URL on FB website to open in safari
    }
    [[UIApplication sharedApplication] openURL:fbURL];
}


-(void)dealloc
{
    [IAPButton removeAllChildrenWithCleanup:YES];
    IAPButton = nil;
}


@end
