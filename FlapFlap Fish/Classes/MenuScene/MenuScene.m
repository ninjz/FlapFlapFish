//
//  MenuScene.m
//  floppyFish
//
//  Created by sh0gun on 2/15/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import "CCAnimation+Helper.h"
#import "MenuScene.h"
#import "GameScene.h"
#import "AnglerGameScene.h"
#import "BlowFishGameScene.h"
#import "NarwhalGameScene.h"
#import "PiranhaGameScene.h"
#import "SkellyGameScene.h"


//#import "CCTextureCache.h"
#import "CCNode+Scaling.h"
#import "Fish.h"
#import "Angler.h"
#import "Narwhal.h"
#import "BlowFish.h"
#import "Angler.h"
#import "Piranha.h"
#import "Skelly.h"

#import "AppDelegate.h"
#import "FFFishIAPHelper.h"
#import "the8Armory.h"
#import "The8ArmoryStockManager.h"
#import <StoreKit/StoreKit.h>


@implementation MenuScene
{
    BGSceneMode currentBG;
    
    // BACKGROUND FARTHEST BACK
    CCAnimation *bgAnim;
    CCActionAnimate *bgFlicker;
    // Set background image
    CCSprite *farBack;
    CCSprite *title;
    CCSprite *_bg1;
    CCSprite *_bg2;
    CCSprite *_ground1;
    CCSprite *_ground2;
    Fish *fish;
    CGSize winSize;
    CCPhysicsNode *_physicsWorld;
    Fish *nextFish;
    
    CCButton *muteButton;
    
//    CCActionRepeatForever *fishIdle;
    BOOL fishIdle;
    BOOL up;
    
}

static MenuScene *sharedMenuScene;

+(MenuScene *) sharedMenuScene;
{
    NSAssert(sharedMenuScene != nil, @"instance not yet initialized");
    return sharedMenuScene;
}

+ (MenuScene *)scene
{
    return [[self alloc] init];
}

-(id)init
{
    sharedMenuScene = self;
    
    self = [super init];
    if (!self) return(nil);
    
    winSize = [[CCDirector sharedDirector] viewSize];
    
    _allowClick = YES;
    
    // IAP $$$$$$$
    __block RequestProductsCompletionHandler req = ^(BOOL success, NSArray *products){
        if (success) {
            [[The8ArmoryStockManager sharedStockManager] setProducts:products];
            
        }
    };
    
    [[FFFishIAPHelper sharedInstance] requestProductsWithCompletionHandler:req];
    
    
    // Create a mute button
    muteButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Speaker-ON.png"]
                    highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Speaker-OFF.png"]
                       disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Speaker-ON.png"]
                  ];
    [muteButton setTogglesSelectedState:true];
    [muteButton setBackgroundSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Speaker-OFF.png"] forState:CCControlStateSelected];
    muteButton.positionType = CCPositionTypeNormalized;
    muteButton.position = (IS_IPAD_AD) ? ccp(0.90f, 0.90f) : ccp(0.90f, 0.95f); // Top Right of screen
    [muteButton setTarget:self selector:@selector(onMuteClicked:)];
    [muteButton setScale:2.5];
    [muteButton setHitAreaExpansion:10];
    [self addChild:muteButton z:50];
    
    if (![[GameState sharedGameState] soundON]) {
        [muteButton setSelected:YES];
    }
    
    
    
    // set title image
    
    title = [CCSprite spriteWithImageNamed:@"FlapFlapFish-Logo.png"];
    [title setScale:2];
    [title setPosition:(IS_IPAD_AD) ? ccp(winSize.width/2, winSize.height - winSize.height/4.5) : ccp(winSize.width/2, winSize.height - winSize.height/3.3)];  //iphone 4: ccp(winSize.width/2, winSize.height - winSize.height/4)
    [self addChild:title z:10];
    
    CCSprite *copyright = [CCSprite spriteWithImageNamed:@"KrackGamesText.png"];
    [copyright setScale:2];
    [copyright setPosition:([[GameState sharedGameState] adsRemoved]) ? ccp(winSize.width/2, winSize.height/11) : ccp(winSize.width/2, (IS_IPAD_AD)? copyright.contentSize.height * 6 : copyright.contentSize.height * 2.5)]; //9
    [self addChild:copyright z:11];
    
    //physics layer to add fishes -_-
    _physicsWorld = [CCPhysicsNode node];
    _physicsWorld.debugDraw         = NO;
    
    [self addChild:_physicsWorld z: 10];
    
    int curFish = [[GameState sharedGameState] curSelectedFish];
    
    
    
    switch (curFish) {
        case 0: // main fish
            fish = [[BlowFish alloc] init];
            fish.position = ccp(winSize.width/2, title.position.y - (title.contentSize.height*1.2));
            [_physicsWorld addChild:fish];
            [(BlowFish *)fish idle];
            
            break;
        case 1: // narwhal
            fish = [[Narwhal alloc] init];
            fish.position = ccp(winSize.width/2, title.position.y - (title.contentSize.height*1.2));
            [_physicsWorld addChild:fish];
            break;
        case 2:
            fish = [[Piranha alloc] init];
            fish.position = ccp(winSize.width/2, title.position.y - (title.contentSize.height*1.2));
            [_physicsWorld addChild:fish];
            break;
            
        case 3: //angler
            fish = [[Angler alloc] init];
            fish.position = ccp(winSize.width/2, title.position.y - (title.contentSize.height*1.2));
            [_physicsWorld addChild:fish];
            break;
        case 4:
            fish = [[Skelly alloc] init];
            fish.position = ccp(winSize.width/2, title.position.y - (title.contentSize.height*1.2));
            [_physicsWorld addChild:fish];
            
            break;
    }
    
    fishIdle = YES;
    up = YES;
    
    if (FLAPPYMODE_ON) {
        farBack = [CCSprite spriteWithImageNamed:@"Background-FB.png"];
    } else {
        farBack = [CCSprite spriteWithImageNamed:@"Background-1.png"];
        
        bgAnim = [CCAnimation animationWithFrame:@"Background-"
                                      frameCount:2
                                           delay:0.8f];
        
        bgFlicker = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:bgAnim]];
        [farBack runAction:bgFlicker];
    }
    
    [self addChild:farBack];
    [farBack scaleToSize:winSize fitType:CCScaleFitAspectFill];
    [farBack setPosition:ccp(winSize.width/2, winSize.height/2)];
    
    
    if (FLAPPYMODE_ON) {
        _bg1 = [CCSprite spriteWithImageNamed:@"Midground-FB.png"];
        _bg2 = [CCSprite spriteWithImageNamed:@"Midground-FB.png"];
        // set ground image
        _ground1 = [CCSprite spriteWithImageNamed:@"Foreground-FB.png"];
        _ground2 = [CCSprite spriteWithImageNamed:@"Foreground-FB.png"];
        
        currentBG = FLAPPYBIRD_BG;
    } else {
        _bg1 = [CCSprite spriteWithImageNamed:@"Midground-1.png"];
        _bg2 = [CCSprite spriteWithImageNamed:@"Midground-1.png"];
        // set ground image
        _ground1 = [CCSprite spriteWithImageNamed:@"Foreground-1.png"];
        _ground2 = [CCSprite spriteWithImageNamed:@"Foreground-2.png"];
        
        currentBG = FLAPFLAPFISH_BG;
    }
    
    
    [self addChild:_bg1];
    [_bg1 scaleToSize:winSize fitType:CCScaleFitAspectFit];
    [_bg1 setPosition:ccp(winSize.width/2, winSize.height/4)];
    
    
    
    [self addChild:_bg2];
    [_bg2 scaleToSize:winSize fitType:CCScaleFitAspectFit];
    [_bg2 setPosition:ccp(winSize.width/2 + winSize.width, winSize.height/4)];
    
    
    
    [self addChild:_ground1 z:1];
    [_ground1 scaleToSize:winSize fitType:CCScaleFitAspectFit];
    [_ground1 setPosition:ccp(winSize.width/2, 40)];
    
    
    
    [self addChild:_ground2 z:1];
    [_ground2 scaleToSize:winSize fitType:CCScaleFitAspectFit];
    [_ground2 setPosition:ccp(winSize.width/2 + winSize.width, 40)];
    
    
    _mainMenu = [[MainMenuLayer alloc] init];
    [self addChild:_mainMenu z: 2];
    
    (IS_IPAD_AD) ? [_mainMenu setPosition:ccp(0, title.position.y - title.contentSize.height*7.8)]: nil;
    
    
    
    _charSelectMenu = [[CharSelectLayer alloc] init];
    //    charSelectMenu.position = ccp(0, winSize.height);
    _charSelectMenu.position = ccp(winSize.width, 0);
    [self addChild:_charSelectMenu z: 20];
    
    
    _statsMenu =[[StatsLayer alloc] init];
    _statsMenu.position = ccp(-winSize.width, 0);
    [self addChild:_statsMenu z: 20];
    
    return self;
}



- (void)onMuteClicked:(id)sender
{
    if ([[GameState sharedGameState] soundON]){
        [[OALSimpleAudio sharedInstance] setMuted:YES];
        [[GameState sharedGameState] setSoundON:NO];
        [[GameState sharedGameState] saveState];
    } else {
        [[OALSimpleAudio sharedInstance] setMuted:NO];
        [[GameState sharedGameState] setSoundON:YES];
        [[GameState sharedGameState] saveState];
    }
    
}


-(void)scrollBackground:(CCTime)dt
{
    
    // bg movement
    CGPoint pos1 = _bg1.position;
    CGPoint pos2 = _bg2.position;
    
    pos1.x -= MM_BG_SPEED_DUR;
    pos2.x -= MM_BG_SPEED_DUR;
    
    if(pos1.x <= -(winSize.width*0.5f)){
        pos2.x = winSize.width/2;
        pos1.x = pos2.x + winSize.width;
    }
    
    if(pos2.x <= -(winSize.width*0.5f)){
        pos1.x = winSize.width/2;
        pos2.x = pos1.x + winSize.width;
    }
    
    _bg1.position = pos1;
    _bg2.position = pos2;
    
    // ground movement
    pos1 = _ground1.position;
    pos2 = _ground2.position;
    
    pos1.x -= MM_GR_SPEED_DUR;
    pos2.x -= MM_GR_SPEED_DUR;
    
    if(pos1.x <= -(winSize.width*0.5f)){
        pos2.x = winSize.width/2;
        pos1.x = pos2.x + winSize.width;
    }
    
    if(pos2.x <= -(winSize.width*0.5f)){
        pos1.x = winSize.width/2;;
        pos2.x = pos1.x + winSize.width;
    }
    
    _ground1.position = pos1;
    _ground2.position = pos2;
    
}



-(void)switchToFlappyBG
{
    [_bg1 runAction:[CCActionSequence actionWithArray:@[[CCActionFadeOut actionWithDuration:BG_TRANSITION_TIME],
                                                        [CCActionCallBlock actionWithBlock:^{
        [_bg1 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Midground-FB.png"]];
    }],
                                                        [CCActionFadeIn actionWithDuration:BG_TRANSITION_TIME]]]];
    [_bg2 runAction:[CCActionSequence actionWithArray:@[[CCActionFadeOut actionWithDuration:BG_TRANSITION_TIME],
                                                        [CCActionCallBlock actionWithBlock:^{
        [_bg2 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Midground-FB.png"]];
    }],
                                                        [CCActionFadeIn actionWithDuration:BG_TRANSITION_TIME]]]];
    
    [_ground1 runAction:[CCActionSequence actionWithArray:@[[CCActionFadeOut actionWithDuration:BG_TRANSITION_TIME],
                                                        [CCActionCallBlock actionWithBlock:^{
        [_ground1 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Foreground-FB.png"]];
    }],
                                                        [CCActionFadeIn actionWithDuration:BG_TRANSITION_TIME]]]];
    
    [_ground2 runAction:[CCActionSequence actionWithArray:@[[CCActionFadeOut actionWithDuration:BG_TRANSITION_TIME],
                                                        [CCActionCallBlock actionWithBlock:^{
        [_ground2 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Foreground-FB.png"]];
    }],
                                                        [CCActionFadeIn actionWithDuration:BG_TRANSITION_TIME]]]];
    
    [farBack stopAllActions];
    [farBack runAction:[CCActionSequence actionWithArray:@[[CCActionFadeOut actionWithDuration:BG_TRANSITION_TIME],
                                                            [CCActionCallBlock actionWithBlock:^{
        [farBack setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Background-FB.png"]];
    }],
                                                            [CCActionFadeIn actionWithDuration:BG_TRANSITION_TIME]]]];
    
    currentBG = FLAPPYBIRD_BG;
}

-(void)switchToFFFishBG
{
    [_bg1 runAction:[CCActionSequence actionWithArray:@[[CCActionFadeOut actionWithDuration:BG_TRANSITION_TIME],
                                                        [CCActionCallBlock actionWithBlock:^{
        [_bg1 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Midground-1.png"]];
    }],
                                                        [CCActionFadeIn actionWithDuration:BG_TRANSITION_TIME]]]];
    [_bg2 runAction:[CCActionSequence actionWithArray:@[[CCActionFadeOut actionWithDuration:BG_TRANSITION_TIME],
                                                        [CCActionCallBlock actionWithBlock:^{
        [_bg2 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Midground-1.png"]];
    }],
                                                        [CCActionFadeIn actionWithDuration:BG_TRANSITION_TIME]]]];
    
    [_ground1 runAction:[CCActionSequence actionWithArray:@[[CCActionFadeOut actionWithDuration:BG_TRANSITION_TIME],
                                                            [CCActionCallBlock actionWithBlock:^{
        [_ground1 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Foreground-1.png"]];
    }],
                                                            [CCActionFadeIn actionWithDuration:BG_TRANSITION_TIME]]]];
    
    [_ground2 runAction:[CCActionSequence actionWithArray:@[[CCActionFadeOut actionWithDuration:BG_TRANSITION_TIME],
                                                            [CCActionCallBlock actionWithBlock:^{
        [_ground2 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Foreground-2.png"]];
    }],
                                                            [CCActionFadeIn actionWithDuration:BG_TRANSITION_TIME]]]];
    
    [farBack runAction:[CCActionSequence actionWithArray:@[[CCActionFadeOut actionWithDuration:BG_TRANSITION_TIME],
                                                           [CCActionCallBlock actionWithBlock:^{
        [farBack setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Background-1.png"]];
    }],
                                                           [CCActionFadeIn actionWithDuration:BG_TRANSITION_TIME]]]];
    
    bgAnim = [CCAnimation animationWithFrame:@"Background-"
                                  frameCount:2
                                       delay:0.8f];
    
    bgFlicker = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:bgAnim]];
    [farBack runAction:bgFlicker];

    currentBG = FLAPFLAPFISH_BG;
}

-(void)to8Armory
{
    [[CCDirector sharedDirector] replaceScene:[The8Armory scene]
                               withTransition:[CCTransition transitionFadeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f] duration:0.8f]];
}


- (void)onStartClicked
{
    // To Game scene with transition
    GameScene *newGame;
    int curFish = [[GameState sharedGameState] curSelectedFish];
    switch (curFish) {
        case 0:  // main char
            //            newGame = [AnglerGameScene scene];
            newGame = [BlowFishGameScene scene];
            break;
        case 1:  // narwhal
            newGame = [NarwhalGameScene scene];
            //            _fish = [[Narwhal alloc] init];
            break;
            
        case 2:  // blowfish
            newGame = [PiranhaGameScene scene];
            break;
            
        case 3: // angler
            //            _fish = [[Angler alloc] init];
            newGame = [AnglerGameScene scene];
            break;
        case 4:
            newGame = [SkellyGameScene scene];
            break;
    }
    
    
    
    [[CCDirector sharedDirector] replaceScene:newGame
                               withTransition:[CCTransition transitionFadeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f] duration:0.8f]];
}



-(void)transitionFromMainToCharSelect
{
    if (_allowClick) {
        [[GameState sharedGameState] buttonPressedSound];
        [_mainMenu runAction:[CCActionMoveTo actionWithDuration:0.5f position:(IS_IPAD_AD)? ccp(-winSize.width, title.position.y - title.contentSize.height*7.8) :  ccp(-winSize.width, 0)]];
        [_charSelectMenu runAction:[CCActionMoveTo actionWithDuration:0.5f position:ccp(0, 0)]];
    }
    _allowClick = NO;
    
}

-(void)transitionFromMainToStats
{
    if (_allowClick) {
        [_statsMenu updateTocurFish];
        [[GameState sharedGameState] buttonPressedSound];
        [_mainMenu runAction:[CCActionMoveTo actionWithDuration:0.5f position: (IS_IPAD_AD)? ccp(winSize.width, title.position.y - title.contentSize.height*7.8) :  ccp(winSize.width, 0)]];
        [_statsMenu runAction:[CCActionMoveTo actionWithDuration:0.5f position:ccp(0, 0)]];
    }
    _allowClick = NO;
    
}

-(void)transitionFromCharSelectToMain
{
    if (!_allowClick) {
        [[GameState sharedGameState] buttonPressedSound];
        [[_charSelectMenu unlockText] setVisible:NO];
        [_mainMenu runAction:[CCActionMoveTo actionWithDuration:0.5f position:(IS_IPAD_AD)? ccp(0, title.position.y - title.contentSize.height*7.8) :  ccp(0, 0)]];
        [_charSelectMenu runAction:[CCActionMoveTo actionWithDuration:0.5f position:ccp(winSize.width, 0)]];
    }
    _allowClick = YES;
    
}


- (void)transitionFromStatsToMain
{
    if (!_allowClick) {
        [[GameState sharedGameState] buttonPressedSound];
        [_mainMenu runAction:[CCActionMoveTo actionWithDuration:0.5f position:(IS_IPAD_AD)? ccp(0, title.position.y - title.contentSize.height*7.8) : ccp(0, 0)]];
        [_statsMenu runAction:[CCActionMoveTo actionWithDuration:0.5f position:ccp(-winSize.width, 0)]];
    }
    _allowClick = YES;
}

-(void)selectNewFish:(Fish *)newFish
{
    nextFish = newFish;
    [fish runAction:[CCActionSequence actionOne:[CCActionMoveTo actionWithDuration:0.5f position:ccp(winSize.width + fish.contentSize.width, title.position.y - (title.contentSize.height*1.2))]  two:[CCActionCallFunc actionWithTarget:self selector:@selector(replaceFish)] ]];
}

-(void)replaceFish
{
//    [_statsMenu updateTocurFish];
    fishIdle = NO;
    [_physicsWorld removeChild:fish];
    fish = nextFish;
    fish.position = ccp(-fish.contentSize.width, title.position.y - (title.contentSize.height*1.2));
    if([fish isKindOfClass:[BlowFish class]]){
        [(BlowFish *)fish idle];
    }
    
    [_physicsWorld addChild:fish];
    
    if (FLAPPYMODE_ON && currentBG!=FLAPPYBIRD_BG) {
        [self switchToFlappyBG];
    } else if (!FLAPPYMODE_ON && currentBG!=FLAPFLAPFISH_BG){
        [self switchToFFFishBG];
    }
    
    [fish runAction:[CCActionSequence actionOne:[CCActionMoveTo actionWithDuration:0.5f position:ccp(winSize.width/2, title.position.y - (title.contentSize.height*1.2))]  two:[CCActionCallBlock actionWithBlock:^{
        fishIdle = YES;
    }] ]];
    
}

- (void)hideBannerAd
{
    
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    [app hideIAdBanner];
}

#pragma mark In-App Purchases


-(void)purchaseRemoveAds
{
    NSArray *products = [[The8ArmoryStockManager sharedStockManager] products];
    if(products.count > 0){
        SKProduct *product;
        for (SKProduct *p in  products) {
            if ([p.productIdentifier isEqualToString:@"com.krackgames.FlapFlapFish.removeAds"]) {
                product = p;
            }
        }
        CCLOG(@"Buying %@...", product.productIdentifier);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAdsPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
        
        [[FFFishIAPHelper sharedInstance] buyProduct:product];
    } else {
        // alert user of connection error
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Connection Error"
                              message:@"There was an error with connecting with the server, please try again later."
                              delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil, nil];
        [alert show];
    }
}



- (void)removeAdsPurchased:(NSNotification *)notification {
    [_mainMenu removeIAP];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// have to update the idle b/c actions causing synchronization problems with skins
-(void)update:(CCTime)delta
{
    if (fishIdle) {
        if (up) {
            [fish setPosition:ccp(fish.position.x, fish.position.y + 0.20)];
            if (fish.position.y >= (title.position.y - title.contentSize.height*1.2)) {
                up = NO;
            }
        } else {
            [fish setPosition:ccp(fish.position.x, fish.position.y - 0.20)];
            if (fish.position.y <= (title.position.y - title.contentSize.height*1.5)) {
                up = YES;
            }
        }
    }
    [self scrollBackground:delta];
}


-(void)onEnter{
    [super onEnter];
    [self hideBannerAd];
}


-(void)onExit{
    [self removeAllChildrenWithCleanup:YES];
    [_statsMenu removeAllChildrenWithCleanup:YES];
    _statsMenu = nil;
    
    [_charSelectMenu removeAllChildrenWithCleanup:YES];
    _charSelectMenu = nil;
    
    [_mainMenu removeAllChildrenWithCleanup:YES];
    _mainMenu = nil;
    
    
    title = nil;
    _bg1 = nil;
    _bg2 = nil;
    _ground1 = nil;
    _ground2 = nil;
    fish = nil;
    
    [_physicsWorld removeAllChildrenWithCleanup:YES];
    _physicsWorld = nil;
    nextFish = nil;
    
    muteButton = nil;
    
    
    [super onExit];
}



@end
