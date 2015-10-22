//
//  ScoreBoardLayer.m
//  floppyFish
//
//  Created by sh0gun on 2/18/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//
#import <Social/Social.h>
#import "ScoreBoardLayer.h"
#import "GameScene.h"
#import "MenuScene.h"
#import "CCAnimation.h"
#import "AppDelegate.h"

@implementation ScoreBoardLayer{
    CGSize winSize;
    BOOL restoreUnlockLabel;
    
    CCLabelBMFont *score;
    CCLabelBMFont *highscore;
    CCSprite *newHighScoreLabel;
    CCSprite *newUnlock;
    
    CCSprite *frame;
    
    CCButton *fbButton;
    CCButton *twitterButton;
    
    CCSprite *medal;
    CCButton *menuButton;
    CCButton *retryButton;
    
    BOOL enunumerateScore;
    int baseScore;
    int targetScore;
}

-(id)init
{
    self = [super init];
    if (!self) return(nil);
    
    winSize = [[CCDirector sharedDirector] viewSize];
    
    
    // GAME OVER image
    CCSprite *gameOver = [CCSprite spriteWithImageNamed:@"Text-GameOver.png"];
    [gameOver setScale:2.5];
    [gameOver setPosition:ccp(winSize.width/2, (winSize.height*3)/4)];
    [self addChild:gameOver z: 10];
//    [gameOver setColor:[CCColor colorWithRed:0.5f green:0.5f blue:0.5f]];
    
    
    // Create Frame image
    
    frame = [CCSprite spriteWithImageNamed:@"GameOver-Screen.png"];
    [frame setScale:2];
    frame.anchorPoint = ccp(0.5f, 0.5f);
    [frame setPosition:ccp( winSize.width/2, winSize.height/2)];
    [self addChild:frame z: 0];
    
    
    // Create a Menu button
    menuButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"button-menu.png"]];
    menuButton.scale = 0;
    menuButton.anchorPoint = ccp(0.5f, 0.5f);
    [menuButton setPosition:(IS_IPAD_AD) ?  ccp(winSize.width/3.0, frame.position.y - frame.contentSize.width/1.2) :
                            ccp(winSize.width/3.5, frame.position.y - frame.contentSize.width/1.2)];
    [menuButton setTarget:self selector:@selector(backToMenu)];
    [self addChild:menuButton];
    
    retryButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"button-retry.png"]];
    retryButton.scale = 0;
    retryButton.anchorPoint = ccp(0.5f, 0.5f);
    [retryButton setPosition:(IS_IPAD_AD) ? ccp((winSize.width - winSize.width/3.0), frame.position.y - frame.contentSize.width/1.2):
     ccp((winSize.width*2.5/3.5), frame.position.y - frame.contentSize.width/1.2)];
    [retryButton setTarget:[GameScene sharedGameScene] selector:@selector(moveScoreBoardDown)];
    [self addChild:retryButton];
    
    fbButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Button-Facebook.png"]];
    fbButton.scale = 1.5;
    
    ([[GameState sharedGameState]  adsRemoved]) ?
    ((IS_IPAD_AD) ? [fbButton setPosition:ccp(winSize.width - fbButton.contentSize.width*2, fbButton.contentSize.height*3)]  : [fbButton setPosition:ccp(winSize.width - fbButton.contentSize.width*2, fbButton.contentSize.height*2)])
    : ((IS_IPAD_AD) ? [fbButton setPosition:ccp(winSize.width - fbButton.contentSize.width*2, fbButton.contentSize.height*5)] : [fbButton setPosition:ccp(winSize.width - fbButton.contentSize.width*2, fbButton.contentSize.height*4)]) ;
    
    [fbButton setTarget:self selector:@selector(postToFacebook)];
    [self addChild:fbButton];
    
    twitterButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Button-Twitter.png"]];
    twitterButton.scale = 1.5;
    
    ([[GameState sharedGameState]  adsRemoved]) ?
    ((IS_IPAD_AD) ? [twitterButton setPosition:ccp(fbButton.position.x - twitterButton.contentSize.width*2, twitterButton.contentSize.height*3)]  : [twitterButton setPosition:ccp(fbButton.position.x - twitterButton.contentSize.width*2, twitterButton.contentSize.height*2)])
    : ((IS_IPAD_AD) ? [twitterButton setPosition:ccp(fbButton.position.x - twitterButton.contentSize.width*2, twitterButton.contentSize.height*5)] : [twitterButton setPosition:ccp(fbButton.position.x - twitterButton.contentSize.width*2, twitterButton.contentSize.height*4)]) ;
    
    [twitterButton setTarget:self selector:@selector(postToTwitter)];
    [self addChild:twitterButton];
    
    
    score = [[CCLabelBMFont alloc] initWithFile:@"font.png" capacity:2];
    [score setFntFile:@"font.fnt"];
    [score setString:@"0"];
    [score setScale:2];
    [score setPosition:(IS_IPAD) ? ccp(frame.position.x - frame.contentSize.width/5, frame.position.y + frame.contentSize.height/5) : ccp(frame.position.x - frame.contentSize.width/5, frame.position.y + frame.contentSize.height/5.0)];

    // right alignment
    [score setAnchorPoint: ccp(1, 0.5f)];
    [self addChild:score z: 10];
    
    int hScore = [[[[GameState sharedGameState] highScore] objectAtIndex:[[GameState sharedGameState] curSelectedFish]] intValue];
    
    highscore = [[CCLabelBMFont alloc] initWithFile:@"font.png" capacity:2];
    [highscore setFntFile:@"font.fnt"];
    [highscore setString:[NSString stringWithFormat:@"%i", hScore]];
    [highscore setScale:2];
    [highscore setPosition:(IS_IPAD) ? ccp(frame.position.x - frame.contentSize.width/5, frame.position.y - frame.contentSize.height/2) :
     ccp(frame.position.x - frame.contentSize.width/5, frame.position.y - frame.contentSize.height/2.15)];
    // right alignment
    [highscore setAnchorPoint: ccp(1, 0.5f)];
    
    [self addChild:highscore z: 10];
    
    
    
    
    
    
    return self;
}

-(void)updateScore:(int)newScore
{
    
    targetScore = newScore;
    baseScore = 0;
    
    enunumerateScore = YES;
    
    
    if (newScore >= kBronze) {
        [self displayMedal:newScore];
    }
    
}


// only gets called when score is >= 10
 -(void)displayMedal:(int)newScore
 {
     int curFish = [[GameState sharedGameState] curSelectedFish];
     NSMutableDictionary *currencyDict = [[[GameState sharedGameState] currencyCollected] mutableCopy];
     NSMutableArray *currency;
     NSInteger curMedals;
     switch (curFish) {
         case 0: // blowfish
             currency = [[currencyDict objectForKey:@"Blowfish"] mutableCopy];
             
             if(newScore < kSilver){
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Puffer-1.png"];
                  curMedals = [[currency objectAtIndex:0] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:0];
                 }
                 
             } else if(newScore < kGold) {
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Puffer-2.png"];
                 curMedals = [[currency objectAtIndex:1] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:1];
                 }
             } else {
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Puffer-3.png"];
                 curMedals = [[currency objectAtIndex:2] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:2];
                 }
             }
             
             [currencyDict setObject:currency forKey:@"Blowfish"];
             break;
             
         case 1:    // narwhal
             currency = [[currencyDict objectForKey:@"Narwhal"] mutableCopy];
             if(newScore < kSilver){
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Narwhal-1.png"];
                 curMedals = [[currency objectAtIndex:0] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:0];
                 }
             } else if(newScore < kGold) {
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Narwhal-2.png"];
                 curMedals = [[currency objectAtIndex:1] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:1];
                 }
             } else {
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Narwhal-3.png"];
                 curMedals = [[currency objectAtIndex:2] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:2];
                 }
             }
             [currencyDict setObject:currency forKey:@"Narwhal"];
             break;
         case 2: // piranha
             currency = [[currencyDict objectForKey:@"Piranha"] mutableCopy];
             if(newScore < kSilver){
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Piranha-1.png"];
                 curMedals = [[currency objectAtIndex:0] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:0];
                 }
             } else if(newScore < kGold) {
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Piranha-2.png"];
                 curMedals = [[currency objectAtIndex:1] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:1];
                 }
             } else {
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Piranha-3.png"];
                 curMedals = [[currency objectAtIndex:2] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:2];
                 }
             }
             [currencyDict setObject:currency forKey:@"Piranha"];
             break;
         case 3: // angler
             currency = [[currencyDict objectForKey:@"Angler"] mutableCopy];
             if(newScore < kSilver){
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Angler-1.png"];
                 curMedals = [[currency objectAtIndex:0] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:0];
                 }
                 
             } else if(newScore < kGold) {
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Angler-2.png"];
                 curMedals = [[currency objectAtIndex:1] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:1];
                 }
             } else {
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Angler-3.png"];
                 curMedals = [[currency objectAtIndex:2] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:2];
                 }
             }
             [currencyDict setObject:currency forKey:@"Angler"];
             break;
         case 4: // skully
             currency = [[currencyDict objectForKey:@"Zombie"] mutableCopy];
             if(newScore < kSilver){
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Skelly-1.png"];
                 curMedals = [[currency objectAtIndex:0] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:0];
                 }
             } else if(newScore < kGold) {
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Skelly-2.png"];
                 curMedals = [[currency objectAtIndex:1] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:1];
                 }
             } else {
                 medal = [CCSprite spriteWithImageNamed:@"Coin-Skelly-3.png"];
                 curMedals = [[currency objectAtIndex:2] integerValue];
                 if(curMedals <= 999){
                     curMedals ++;
                     [currency setObject:[NSNumber numberWithInteger:curMedals] atIndexedSubscript:2];
                 }
             }
             [currencyDict setObject:currency forKey:@"Zombie"];
             break;
             
     }
     [[GameState sharedGameState] setCurrencyCollected:currencyDict];
     [[GameState sharedGameState] saveState];
     
     [medal setScale:0];
     [medal setPosition:ccp(frame.position.x + frame.contentSize.width*2.13/4, (frame.position.y - frame.contentSize.height/5.8))];
     [self addChild:medal z:20];
     
 }

     
     
-(void)updateHighScore:(int)newHighScore
{
    [highscore setString:[NSString stringWithFormat:@"%i", newHighScore]];
    newHighScoreLabel = [CCSprite spriteWithImageNamed:@"update-newhighscore.png"];
    newUnlock = [CCSprite spriteWithImageNamed:@"update-newunlock.png"];
    [newHighScoreLabel setVisible:NO];
    [self addChild: newHighScoreLabel z:10];
    [newUnlock setVisible:NO];
    [self addChild: newUnlock z:10];
    
    
    
    if([[GameScene sharedGameScene] newUnlock]){
        CCAnimation *blinkAnim;
        CCActionAnimate *blink;
        
        [newUnlock setVisible:YES];
        [newUnlock setScale:2];
        [newUnlock setPosition:ccp(winSize.width/2, (winSize.height*2/3))];
        
        
        
        blinkAnim = [CCAnimation animationWithSpriteFrames:@[[CCSpriteFrame frameWithImageNamed:@"update-newhighscore.png"],
                                                             [CCSpriteFrame frameWithImageNamed:@"update-newunlock.png"]] delay:0.5];
        
        blink = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:blinkAnim]];
        [newUnlock runAction:blink];
        [newUnlock runAction:[CCActionRepeatForever actionWithAction:[CCActionBlink actionWithDuration:0.5 blinks:1]]];
        
    } else {
        [newHighScoreLabel setVisible:YES];
        [newHighScoreLabel setScale:2];
        [newHighScoreLabel setPosition:ccp(winSize.width/2, (winSize.height*2/3))];
        
        [newHighScoreLabel runAction:[CCActionRepeatForever actionWithAction:[CCActionBlink actionWithDuration:0.5 blinks:1]]];
       
    }
    
}



-(void)postToTwitter
{
    [[GameState sharedGameState] buttonPressedSound];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"I just scored %i points in #FlapFlapFish, u mad bro? Check it out at http://itunes.apple.com/app/id830240851 #KrackGames", [[GameScene sharedGameScene] score]]];
        
        // take screenshot
        
        [self displayIndicator];
        
        UIImage *img = [self screenshotWithStartNode:[GameScene sharedGameScene]];
        [tweetSheet addImage:img];
        
        if (!restoreUnlockLabel) {
            [newHighScoreLabel runAction:[CCActionRepeatForever actionWithAction:[CCActionBlink actionWithDuration:0.5 blinks:1]]];
        } else {
            [newUnlock setVisible:YES];
        }
        
        [[CCDirector sharedDirector] presentViewController:tweetSheet animated:YES completion:nil];
    }
}


-(void)postToFacebook
{
    [[GameState sharedGameState] buttonPressedSound];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:[NSString stringWithFormat:@"I just scored %i points in #FlapFlapFish, u mad bro? Check it out at http://itunes.apple.com/app/id830240851 #KrackGames", [[GameScene sharedGameScene] score]]];
        
        // take screenshot
        
        [self displayIndicator];
        
        UIImage *img = [self screenshotWithStartNode:[GameScene sharedGameScene]];
        [controller addImage:img];
        
        if (!restoreUnlockLabel) {
            [newHighScoreLabel runAction:[CCActionRepeatForever actionWithAction:[CCActionBlink actionWithDuration:0.5 blinks:1]]];
        } else {
            [newUnlock setVisible:YES];
        }
        
        
        [[CCDirector sharedDirector] presentViewController:controller animated:YES completion:Nil];
        
    }
}

-(void) displayIndicator
{
    if ([newUnlock visible]) {
        [newUnlock setVisible:NO];
        [newHighScoreLabel stopAllActions];
        [newHighScoreLabel setVisible:YES];
        restoreUnlockLabel = YES;
    } else {
        [newHighScoreLabel stopAllActions];
        [newHighScoreLabel setVisible:YES];
        restoreUnlockLabel = NO;
    }
    
    // set fb and twitter buttons to nonhighlighted
    [fbButton setHighlighted:NO];
    [twitterButton setHighlighted:NO];
}

-(UIImage*) screenshotWithStartNode:(CCNode*)stNode
{
    [CCDirector sharedDirector].nextDeltaTimeZero = YES;
    
    CCRenderTexture* renTxture =
    [CCRenderTexture renderTextureWithWidth:winSize.width
                                     height:winSize.height];
    [renTxture begin];
    [stNode visit];
    [renTxture end];
    
    return [renTxture getUIImage];
}


-(void)end
{
    [medal runAction:[CCActionSequence actionOne:[CCActionScaleTo actionWithDuration:0.1f scale:2] two:[CCActionCallBlock actionWithBlock:^{
        [[OALSimpleAudio sharedInstance] playEffect:@"KrackGames-BarrierPass .wav"];
    }]]];
    [menuButton runAction:[CCActionScaleTo actionWithDuration:0.2f scale:2]];
    [retryButton runAction:[CCActionScaleTo actionWithDuration:0.2f scale:2]];
}


-(void)backToMenu
{
    [[CCDirector sharedDirector] replaceScene:[MenuScene scene]
                               withTransition:[CCTransition transitionFadeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f] duration:0.8f]];
    
    
}

int delay = 0;
-(void)update:(CCTime)delta
{
    if (enunumerateScore) {
        if (delay%2 == 0) {
            if (baseScore <= targetScore) {
                [score setString:[NSString stringWithFormat:@"%i", baseScore]];
                baseScore++;
            } else {
                [self end];
                enunumerateScore = NO;
            }
        }
    }
    
    delay++;
}


-(void)dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    [score removeAllChildrenWithCleanup:YES];
    score = nil;
    [highscore removeAllChildrenWithCleanup:YES];
    highscore = nil;
    
    frame = nil;
    newHighScoreLabel = nil;
    newUnlock = nil;
    fbButton = nil;
    twitterButton = nil;
}


@end
