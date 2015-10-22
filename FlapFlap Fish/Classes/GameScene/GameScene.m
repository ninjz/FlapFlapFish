
//  GameScene.m
//  floppyFish
//
//  Created by sh0gun on 2/13/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//



#import "GameScene.h"
#import "AppDelegate.h"
#import "AnglerGameScene.h"
#import "BlowFishGameScene.h"
#import "NarwhalGameScene.h"
#import "PiranhaGameScene.h"
#import "SkellyGameScene.h"

#import "MenuScene.h"
#import "CCNode+Scaling.h"
#import "CCAnimation+Helper.h"
#import "CCLabelBMFont+Capacity.h"
#import "Obstacle.h"
#import "ScoreBoardLayer.h"
#import "OALSimpleAudio.h"

#import "ObstacleCache.h"
#import "FFFModalView.h"

#import "CCTextureCache.h"
#import "Chartboost.h"


#define speed 2



// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------
@interface GameScene ()



@property (nonatomic, readwrite)int score;
@property (nonatomic, assign) CGFloat distanceObstacles;

@end
@implementation GameScene{
    CCSprite * _reference;
    CCSprite * pausedLabel;
    BOOL prevRotated;
    BOOL kPaused;
    BOOL firstObstacle;
    CCButton *pauseButton;
    CCNodeColor *pauseTint;
    
    int obstacleNum;
    
    //obstacle cache
    Obstacle *_lastObstacle;
    ObstacleCache *_obstacleCache;
    
    
}

static GameScene *sharedGameScene_ = nil;
int obstaclesInScene = 0;
int nextFreeIndex = 0;

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------
+(GameScene *) sharedGameScene{
    NSAssert(sharedGameScene_ != nil, @"instance not yet initialized");
    return sharedGameScene_;
}




+ (GameScene *)scene
{
    return [[self alloc] init];
}



// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    sharedGameScene_ = self;
    nextFreeIndex = 0;
    obstaclesInScene = 0;
    
    
    
    /* *************************Setup your scene here */
    _newUnlock = NO;
    _isGameover = NO;
    _isGameStarted = NO;
    kPaused = false;
    self.distanceObstacles = 0;
    
   
    _score = 0;
    
    
    _physicsWorld                   = [CCPhysicsNode node];
    _physicsWorld.debugDraw         = NO;
    _physicsWorld.collisionDelegate = self;
    _physicsWorld.sleepTimeThreshold = 0.1f;
    
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    [self addChild:_physicsWorld z:2];
    
    winSize = [[CCDirector sharedDirector] viewSize];
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    // GET READY BITCHEZ
    getReady = [CCSprite spriteWithImageNamed:@"Text-GetReady.png"];
    [self addChild:getReady z:4];
    [getReady setPosition:ccp(winSize.width/2, (winSize.height*3)/4)];
    [getReady setScale:2];
    
    // Pause Label
    pausedLabel = [CCSprite spriteWithImageNamed:@"Text-Pause.png"];
    [self addChild:pausedLabel z:5];
    [pausedLabel setPosition:ccp(winSize.width/2, winSize.height/2)];
    [pausedLabel setScale:2];
    [pausedLabel setVisible:NO];
    
    
    
    // obstacle size _reference
    if (FLAPPYMODE_ON) {
         _reference = [CCSprite spriteWithImageNamed:@"Barrier-Bottom-FB.png"];
    } else {
         _reference = [CCSprite spriteWithImageNamed:@"Barrier-Bottom-1.png"];
    }
    _reference.scale = 2;
    

    _min = _ground1.contentSize.height + _reference.contentSize.height - (spaceBetweenTopBottom/11); // (spaceBetweenTopBottom/2);
    _max = winSize.height - _reference.contentSize.height + spaceBetweenTopBottom*2;// - (spaceBetweenTopBottom*2);
    
    
    
    
    // BACKGROUND FARTHEST BACK
    CCAnimation *bgAnim;
    CCActionAnimate *bgFlicker;
    // Set background image
    CCSprite *farBack;
    
    if (FLAPPYMODE_ON) {
        farBack = [CCSprite spriteWithImageNamed:@"Background-FB.png"];
    } else {
        farBack = [CCSprite spriteWithImageNamed:@"Background-1.png"];
    }
    
    [self addChild:farBack z:0];
    [farBack scaleToSize:winSize fitType:CCScaleFitAspectFill];
    [farBack setPosition:ccp(winSize.width/2, winSize.height/2)];
    
    bgAnim = [CCAnimation animationWithFrame:@"Background-"
                                  frameCount:2
                                       delay:0.8f];
    
    bgFlicker = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:bgAnim]];
    if (!FLAPPYMODE_ON) {
        [farBack runAction:bgFlicker];
    }

    
    
    if (FLAPPYMODE_ON) {
        _bg1 = [CCSprite spriteWithImageNamed:@"Midground-FB.png"];
    } else {
        _bg1 = [CCSprite spriteWithImageNamed:@"Midground-1.png"];
    }
    
    [self addChild:_bg1 z:1];
    [_bg1 scaleToSize:winSize fitType:CCScaleFitAspectFit];
    [_bg1 setPosition:ccp(winSize.width/2, winSize.height/4)];
    
    if (FLAPPYMODE_ON) {
        _bg2 = [CCSprite spriteWithImageNamed:@"Midground-FB.png"];
    } else {
        _bg2 = [CCSprite spriteWithImageNamed:@"Midground-1.png"];
    }
    
    [self addChild:_bg2 z:1];
    [_bg2 scaleToSize:winSize fitType:CCScaleFitAspectFit];
    [_bg2 setPosition:ccp(winSize.width/2 + winSize.width, winSize.height/4)];
    
    
    
    _scoreDisplay = [[CCLabelBMFont alloc] initWithFile:@"font.png" capacity:3];
    [_scoreDisplay setFntFile:@"font.fnt"];
    //    _scoreDisplay.positionType = CCPositionTypeNormalized;
    [_scoreDisplay setAnchorPoint:ccp(0.5f,0.5f)];
    _scoreDisplay.position = ccp(winSize.width/2 ,getReady.position.y + getReady.contentSize.height*5);
    [_scoreDisplay setString:@"     "];
    [_scoreDisplay setString:@"0"];
    [_scoreDisplay setScale:3];
    
    [self addChild:_scoreDisplay z:4];
    
    
    // Create a pause button
    pauseButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Button-Pause.png"]
                     highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"button-resume.png"]
                        disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Button-Pause.png"]
                   ];
    [pauseButton setTogglesSelectedState:true];
    [pauseButton setBackgroundSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"button-resume.png"] forState:CCControlStateSelected];
    pauseButton.positionType = CCPositionTypeNormalized;
    pauseButton.position = (IS_IPAD_AD) ? ccp(0.90f, 0.90f) : ccp(0.90f, 0.95f); // Top Right of screen
    [pauseButton setTarget:self selector:@selector(onPauseClicked:)];
    [pauseButton setScale:2.5];
    [pauseButton setHitAreaExpansion:10];
    [self addChild:pauseButton z:5];
    
    
    
    
    if (FLAPPYMODE_ON) {
        _ground1 = [CCSprite spriteWithImageNamed:@"Foreground-FB.png"];
    } else {
        _ground1 = [CCSprite spriteWithImageNamed:@"Foreground-1.png"];
    }
    
    [_physicsWorld addChild:_ground1 z:2];
    [_ground1 scaleToSize:winSize fitType:CCScaleFitAspectFit];
    [_ground1 setPosition:ccp(winSize.width/2, 40)];
    
    
    if (FLAPPYMODE_ON) {
        _ground2 = [CCSprite spriteWithImageNamed:@"Foreground-FB.png"];
    } else {
        _ground2 = [CCSprite spriteWithImageNamed:@"Foreground-1.png"];
    }
    
    [_physicsWorld addChild:_ground2 z:2];
    [_ground2 scaleToSize:winSize fitType:CCScaleFitAspectFit];
    [_ground2 setPosition:ccp(winSize.width/2 + winSize.width, 40)];
    
    
	return self;
}

-(void)initObstacles
{
    //*************set the obstacles
    firstObstacle = YES;
    // Initialize Obstacle Cache
    _obstacleCache = [[ObstacleCache alloc] init];
    obstacleNum = 1;
    __autoreleasing Obstacle *obstacle;
    
    for (int i = 0; i < CACHE_SIZE; i++){
        obstacle = [_obstacleCache cacheInit];
        [_physicsWorld addChild:obstacle z:1];
        [obstacle setVisible:NO];
        [obstacle setInPhysicsWorld:YES];
        [obstacle setPosition:ccp(-winSize.width, 0)];
    }
}



- (void)onPauseClicked:(id)sender
{
    if([_fish alive]) {
        if(!kPaused){
            kPaused = true;
            [pausedLabel setVisible:YES];
            pauseTint = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.7f]];
            [self addChild:pauseTint z:4];
            [[OALSimpleAudio sharedInstance] setMuted:YES];
            
            [[CCDirector sharedDirector] pause];
        } else{
            kPaused = false;
            [pausedLabel setVisible:NO];
            [self removeChild:pauseTint cleanup:YES];
            
            [[OALSimpleAudio sharedInstance] setMuted:NO];
            [[CCDirector sharedDirector] resume];
        }
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
        pos2.x = winSize.width*0.5;
        pos1.x = pos2.x + winSize.width;
    }
    
    if(pos2.x <= -(winSize.width*0.5f)){
        pos1.x = winSize.width*0.5;
        pos2.x = pos1.x + winSize.width;
    }
    
    _bg1.position = pos1;
    _bg2.position = pos2;
    
    // ground movement
    pos1 = _ground1.position;
    pos2 = _ground2.position;
    
    //    pos1.x -= _fish.swimSpeed * dt;
    //    pos2.x -= _fish.swimSpeed * dt;
    
    pos1.x -= _fish.swimSpeed;
    pos2.x -= _fish.swimSpeed;
    
    if(pos1.x <= -(winSize.width*0.5f)){
        pos2.x = winSize.width*0.5;
        pos1.x = pos2.x + winSize.width;
    }
    
    if(pos2.x <= -(winSize.width*0.5f)){
        pos1.x = winSize.width*0.5;
        pos2.x = pos1.x + winSize.width;
    }
    
    _ground1.position = pos1;
    _ground2.position = pos2;
    
}

- (BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
                monsterCollision:(CCNode *)monster
             projectileCollision:(CCNode *)projectile
{
    
    // anything in here will only get called once on death b/c this gets called multiple times somtimes
    if([_fish alive]){
        
        [self gameOver];
        
    }
    
    return YES;
}


-(void)addObstacleGroup
{
    Obstacle *nodeObstacle1;
    Obstacle *nodeObstacle2;
    
    int rand = arc4random_uniform(2);
    
    switch (rand) {
        case 0:
            nodeObstacle1 = [_obstacleCache getUpDownDynamic];
            nodeObstacle2 = [_obstacleCache getUpDownDynamic];
            break;
        case 1:
            nodeObstacle1 = [_obstacleCache getUpDownStatic];
            nodeObstacle2 = [_obstacleCache getUpDownStatic];
            break;
    }
    

    rand = arc4random_uniform(2);
    if(rand == 1){
        nodeObstacle1.moveDown = true;
        nodeObstacle2.moveDown = true;
    }else{
        nodeObstacle1.moveDown = false;
        nodeObstacle2.moveDown = false;
    }
    nodeObstacle1.firstCalled = false;
    nodeObstacle2.firstCalled = false;
    
    float height = [self randomHeight];
    if([_lastObstacle type]  == kRotatedDynamic || [_lastObstacle type] == kRotatedStatic){
        [nodeObstacle1 setPosition:ccp(_lastObstacle.position.x + spaceBetweenRotatedObstacles, height)];
    } else {
        [nodeObstacle1 setPosition:ccp(_lastObstacle.position.x + _spaceBetweenObstacles, height)];
    }
    
    [nodeObstacle2 setPosition:ccp(nodeObstacle1.position.x + _reference.contentSize.width*2, height)];
    
    
    
    [nodeObstacle2 setIsGroup:YES];
    [nodeObstacle1 setIsGroup:YES];
    
    
    if(![nodeObstacle1 inPhysicsWorld]){
        [nodeObstacle1 setInPhysicsWorld:YES];
        [_physicsWorld addChild:nodeObstacle1];
    }
    if(![nodeObstacle2 inPhysicsWorld]){
        [nodeObstacle2 setInPhysicsWorld:YES];
        [_physicsWorld addChild:nodeObstacle2];
    }
    
    _lastObstacle = nodeObstacle2;
    
    
    [self addObstacleToScene:nodeObstacle1];
    [self addObstacleToScene:nodeObstacle2];
    obstacleNum++;
}

- (void)addObstacles{
    __autoreleasing Obstacle * nodeObstacle;
    
//    if(firstObstacle){
//            nodeObstacle = [_obstacleCache getRotatedStatic];
//            [nodeObstacle setPosition:ccp(winSize.width*2, [self randomHeight])];
//               firstObstacle = NO;
//    } else {
//        if(obstacleNum % 2 == 0){
//            nodeObstacle = [_obstacleCache getRotatedStatic];
//            [nodeObstacle setPosition:ccp(_lastObstacle.position.x + spaceBetweenRotatedObstacles, _min)];
//        } else {
//            nodeObstacle = [_obstacleCache getRotatedStatic];
//            [nodeObstacle setPosition:ccp(_lastObstacle.position.x + spaceBetweenRotatedObstacles, _max)];
//        }
//        
//    }
    
    
    
    /************************************************ */
    
    
    if(obstacleNum <= 10){
        nodeObstacle = [_obstacleCache getUpDownStatic];
        //            nodeObstacle = [_obstacleCache getRotatedDynamic];
    }
    else if(obstacleNum <= 35){
        int rand = arc4random_uniform(5);
        switch (rand) {
            case 0:
            case 1:
                nodeObstacle = [_obstacleCache getUpDownStatic];
                break;
            case 2:
                [self addObstacleGroup];    // spawn lower rate
                return;
            default:
                nodeObstacle = [_obstacleCache getUpDownDynamic];
                break;
        }
        
    } else if(obstacleNum <= 65){
        int rand = arc4random_uniform(6);
        switch (rand) {
            case 0:
                [self addObstacleGroup];  // lower rate
                return;
            case 1:
            case 2:
                nodeObstacle = [_obstacleCache getUpDownDynamic];
                break;
            case 4:
                nodeObstacle = [_obstacleCache getUpDownStatic];
                break;
            default:
                nodeObstacle = [_obstacleCache getRotatedStatic];
                break;
        }
        
    } else if(obstacleNum <= 80){
        int rand = arc4random_uniform(7);
        switch (rand) {
            case 0:
                [self addObstacleGroup];  // lower rate
                return;
            case 1:
            case 2:
                nodeObstacle = [_obstacleCache getUpDownStatic];
                break;
            case 3:
            case 4:
                nodeObstacle = [_obstacleCache getUpDownDynamic];
                break;
            default:
                nodeObstacle = [_obstacleCache getRotatedStatic];
                break;
        }
        
    } else{
        int rand = arc4random_uniform(8);
        switch (rand) {
            case 0:
            case 1:
                nodeObstacle = [_obstacleCache getRotatedDynamic];
                break;
            case 2:
            case 3:
                nodeObstacle = [_obstacleCache getUpDownStatic];
                break;
            case 4:
            case 5:
                nodeObstacle = [_obstacleCache getUpDownDynamic];
                break;
            case 6:
                [self addObstacleGroup];  // lower rate
                return;
            default:
                nodeObstacle = [_obstacleCache getRotatedStatic];
                break;
        }
        
    }
    
    
    
    if(firstObstacle){
        [nodeObstacle setPosition:ccp(winSize.width*2, [self randomHeight])];
        firstObstacle = NO;
    } else {
        
        if([_lastObstacle type] == kRotatedStatic || [_lastObstacle type] == kRotatedDynamic){
            [nodeObstacle setPosition:ccp(_lastObstacle.position.x + spaceBetweenRotatedObstacles, [self randomHeight])];
        } else {
            if([nodeObstacle type] != kRotatedStatic && [nodeObstacle type] != kRotatedDynamic){
                [nodeObstacle setPosition:ccp(_lastObstacle.position.x + _spaceBetweenObstacles, [self randomHeight])];
            } else {
                [nodeObstacle setPosition:ccp(_lastObstacle.position.x + spaceBetweenRotatedObstacles, [self randomHeight])];
            }
            
        }

    }
    
    
    
    
    if(![nodeObstacle inPhysicsWorld]){
        [nodeObstacle setInPhysicsWorld:YES];
        [_physicsWorld addChild:nodeObstacle];
    }
    
    
    _lastObstacle = nodeObstacle;
    
    [self addObstacleToScene:nodeObstacle];
    obstacleNum++;
}




-(int) randomHeight{
    
    int y = arc4random() % (_max - _min + 1) + _min;
    return y;
}

- (void)update:(CCTime)delta
{
    CGPoint position;
    
    if([_fish alive]){
        if (_isGameStarted && (!self.isGameover)){
            
            if (firstObstacle) {
                [self addObstacles];
            } else {
                if ([_lastObstacle position].x <= winSize.width) {
                    [self addObstacles];
                }
            }
            
            __autoreleasing Obstacle *obstacle;
            ObstacleType type;
            
            //            for (obstacle in self.obstacles) {
            for(int i = 0; i < CACHE_SIZE ; i++){
                
                obstacle = obstacles[i];
                
                
                if (obstacle) {
                    if (obstacle.isActive) {
                        type = [obstacle type];
                        position = [obstacle position];
                        
                        // move obstacles
                        [obstacle scroll:delta];
                        
                        if([obstacle type] == kUpDownDynamic || [obstacle type] == kRotatedDynamic){
                            if([obstacle isGroup]){
                                [obstacle movement:delta];
                            } else if (position.x <= winSize.width + _reference.contentSize.width*0.5){
                                [obstacle movement:delta];
                            }
                            
                        }
                        
                        if (![obstacle visible] && position.x <= winSize.width + _reference.contentSize.height)  {
                            if (type == kRotatedDynamic || type == kRotatedStatic) {
                                [obstacle setVisible:YES];
                            } else if (position.x  <= winSize.width + _reference.contentSize.width ){
                                [obstacle setVisible:YES];
                            }
                            
                        }
                        
                        
                        // score checking
                        if(position.x <= _fish.position.x && obstacle.passed == false)
                        {
                            obstacle.passed = true;
                            [self incrementScore];
                        }
                        
                        //remove from the screen
                        if (position.x + (_reference.contentSize.width) < 0)
                        {
                            if (type != kRotatedDynamic && type != kRotatedStatic ){
                                [_obstacleCache returnObstacle:obstacle];
                                obstacles[i] = nil;
                            } else if (position.x + (_reference.contentSize.height) < 0){
                                [_obstacleCache returnObstacle:obstacle];
                                obstacles[i] = nil;
                            }
                        }
                    }
                    
                }
                
                
            }
            
            
            
            
        }
        [self scrollBackground:delta];
        
    }
    
    [_fish updateMe:delta];
    
}

-(void)addObstacleToScene:(Obstacle *)obstacle
{
    for (int i = 0; i < CACHE_SIZE; i++) {
        if (obstacles[i] == nil) {
            obstacles[i] = obstacle;
            return;
        }
    }
}



-(void)incrementScore
{
    _score++;
    [_scoreDisplay setStringWithCapacity:[NSString stringWithFormat:@"%i", _score]];
    [[OALSimpleAudio sharedInstance] playEffect:@"KrackGames-BarrierPass .wav"];
}




// -----------------------------------------------------------------------
#pragma mark - GAME OVER
// -----------------------------------------------------------------------

-(void)gameOver
{
    [[OALSimpleAudio sharedInstance] playEffect:@"death.wav" volume:1 pitch:1 pan:0 loop:NO];
    
    CCActionSequence *vibrateAction = [CCActionSequence actions    :[CCActionRotateTo actionWithDuration:0.04 angle:0.5],
                                       [CCActionRotateTo actionWithDuration:0.04 angle:-0.5], [CCActionRotateTo actionWithDuration:0.04 angle:0] ,nil];
    CCActionSequence *vibrateAndWait = [CCActionSequence actions:[CCActionRepeat actionWithAction:vibrateAction times:5],
                                        [CCActionDelay actionWithDuration:0.5f],
                                        nil];
    [self runAction:vibrateAndWait ];
    
    
    [self removeChild:pauseButton];
    
    // score board init
    scoreboard = [[ScoreBoardLayer alloc] init];
    scoreboard.position = ccp(0, -winSize.height);
    [self addChild:scoreboard z:50];
    
    
    [self moveScoreBoardUp];
    
    int deaths = [[GameState sharedGameState] deaths] + 1;
    [[GameState sharedGameState] setDeaths:deaths];
    [self flashWhite];
    
    // -----------------------------------------------------------------------
#pragma mark - CHARACTER UNLOCKS
    // -----------------------------------------------------------------------
    NSMutableDictionary * unlocked = [[[GameState sharedGameState] unlockedFishes] mutableCopy];
    
    if(deaths >= 150){
        //unlock skull fish
        if([[unlocked objectForKey:@"zombie"] boolValue] == NO){
            _newUnlock = YES;
            [[GameState sharedGameState] unlockFish:@"zombie"];
        }
    }
    
    
    if((_score >= 100) && ([[unlocked objectForKey:@"piranha"] boolValue] == NO)){
        // unlock piranha
        if([[unlocked objectForKey:@"piranha"] boolValue] == NO){
            _newUnlock = YES;
            [[GameState sharedGameState] unlockFish:@"piranha"];
        }
    }
    
    if((_score >= 50) && ([[unlocked objectForKey:@"narwhal"] boolValue] == NO)){
        // unlock narwhal
        if([[unlocked objectForKey:@"narwhal"] boolValue] == NO){
            _newUnlock = YES;
            [[GameState sharedGameState] unlockFish:@"narwhal"];
        }
    }
    // -----------------------------------------------------------------------
#pragma mark - LEGEND SKIN UNLOCK
    // -----------------------------------------------------------------------
    int curFish = [[GameState sharedGameState] curSelectedFish];
    NSMutableArray *skinsOwned = [[[GameState sharedGameState] skinsOwned] mutableCopy];
    
    
    switch (curFish) {
        case 0:
            if (_score >= 150) {
                if (![skinsOwned containsObject:@"P011"]) {
                    [skinsOwned addObject:@"P011"];
                    [[GameState sharedGameState] setSkinsOwned:skinsOwned];
                }
            }
            break;
        case 1:
            if (_score >= 75) {
                if (![skinsOwned containsObject:@"N011"]) {
                    [skinsOwned addObject:@"N011"];
                    [[GameState sharedGameState] setSkinsOwned:skinsOwned];
                }
            }
            break;
        case 2:
            if (_score >= 75) {
                if (![skinsOwned containsObject:@"C011"]) {
                    [skinsOwned addObject:@"C011"];
                    [[GameState sharedGameState] setSkinsOwned:skinsOwned];
                }
            }
            break;
        case 4:
            if (_score >= 150) {
                if (![skinsOwned containsObject:@"S008"]) {
                    [skinsOwned addObject:@"S008"];
                    [[GameState sharedGameState] setSkinsOwned:skinsOwned];
                }
            }
            break;
            
        default:
            break;
    }
        
        

    
    
    // -----------------------------------------------------------------------
#pragma mark - HIGH SCORE SAVE
    // -----------------------------------------------------------------------
    
    if(_score > [[[[GameState sharedGameState] highScore] objectAtIndex:curFish] integerValue])
    {
        NSMutableArray *newScore = [[GameState sharedGameState] highScore];
        [newScore setObject:[NSNumber numberWithInt:_score] atIndexedSubscript:curFish];
        [[GameState sharedGameState] setHighScore:newScore];
        [scoreboard updateHighScore:_score];
    }
    
    [[GameState sharedGameState] saveState];
    [_fish kill];
}

-(void)flashWhite
{

    CCNodeColor *flash = [CCNodeColor nodeWithColor:[CCColor colorWithRed:1 green:1 blue:1 alpha:1.0f]];
    
    [flash runAction:[CCActionSequence actions:[CCActionFadeIn actionWithDuration:0.2f], [CCActionFadeOut actionWithDuration:0.2f], nil]];
    
    [self addChild:flash z:30];
    
}

-(void)moveScoreBoardUp
{
    if (![[GameState sharedGameState] adsRemoved]) {
        [self hideBannerAd];
        [self showTopBannerAd];
        
    } else {
        [self hideBannerAd];
    }
    
    // if hasnt been rated yet popup rate me modal
    if ([[GameState sharedGameState] deaths] % 3 == 0) {
        if (![[GameState sharedGameState] rated]) {
            FFFModalView *ratePopup = [[FFFModalView alloc] initRateMeModal];
            [self addChild:ratePopup z:51];
//            ratePopup.scale = 2;
//            [ratePopup displayModalWithAction:[CCActionScaleTo actionWithDuration:0.2f scale:2]];
            [ratePopup displayModal];
        }
    }
    
    [_scoreDisplay setVisible:NO];
    
    [scoreboard runAction:[CCActionSequence actionWithArray:@[[CCActionDelay actionWithDuration:0.5f],[CCActionMoveTo actionWithDuration:0.2f position:ccp(0, 0)], [CCActionCallBlock actionWithBlock:^{
        [scoreboard updateScore:_score];
    }]]]];
    
//    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    
}

-(void)moveScoreBoardDown
{
    GameScene *newGame;
    //    [scoreboard runAction:[CCActionMoveTo actionWithDuration:0.2f position:ccp(0, -winSize.height)]];
    int curFish = [[GameState sharedGameState] curSelectedFish];
    switch (curFish) {
        case 0:  // main char
            newGame = [BlowFishGameScene scene];
            
            break;
        case 1:  // narwhal
            newGame = [NarwhalGameScene scene];
            break;
        case 2: // blowfish
            newGame = [PiranhaGameScene scene];
            break;
        case 3: //angerier
            //            _fish = [[Angler alloc] init];
            newGame = [AnglerGameScene scene];
            break;
        case 4:
            newGame = [SkellyGameScene scene];
            break;
    }
    
    //    [[CCDirector sharedDirector] popScene];
    [[CCDirector sharedDirector] replaceScene:newGame
                               withTransition:[CCTransition transitionFadeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f] duration:0.8f]];
}

- (void)showTopBannerAd
{
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    app.isBannerOnTop = true;
    [app ShowIAdBanner];
    
}

- (void)showBottomBannerAd
{
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    app.isBannerOnTop = false;
    [app ShowIAdBanner];
    
}

- (void)hideBannerAd
{
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    [app hideIAdBanner];
}




// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    [self hideBannerAd];
    
    if (![[GameState sharedGameState] adsRemoved]) {
        int deaths = [[GameState sharedGameState] deaths];
        if(deaths%3 == 0){
            if ([[Chartboost sharedChartboost] hasCachedInterstitial]) {
                [[Chartboost sharedChartboost] showInterstitial];
            } else {
                [[Chartboost sharedChartboost] cacheInterstitial];
            }
        } else {
            [self showBottomBannerAd];
        }
        
    }
    
}

// -----------------------------------------------------------------------



- (void)onExit
{
    
    CCLOG(@"dealloc gamescene");
    [self removeAllChildrenWithCleanup:YES];
    // clean up code goes here
    [scoreboard removeAllChildrenWithCleanup:YES];
    scoreboard = nil;
    
    [_scoreDisplay removeAllChildrenWithCleanup:YES];
    _scoreDisplay = nil;
    
    
    
    [_obstacleCache clearCache];
    _obstacleCache = nil;
    
    
    _reference = nil;
    pausedLabel = nil;
    pauseButton = nil;
    pauseTint = nil;
    [tapPrompt removeAllChildrenWithCleanup:YES];
    tapPrompt = nil;
    [getReady removeAllChildrenWithCleanup:YES];
    getReady = nil;
    
    
    //obstacle cache
    _lastObstacle = nil;
    
    
    [_physicsWorld removeAllChildrenWithCleanup:YES];
    _physicsWorld = nil;
    
    
    // always call super onExit last
    [super onExit];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
