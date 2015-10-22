//
//  Narwhal.m
//  floppyFish
//
//  Created by sh0gun on 2/20/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import "Narwhal.h"
#import "CCAnimation+Helper.h"
#import "OALSimpleAudio.h"
#import "The8ArmoryStockManager.h"
#import "GameScene.h"


@implementation Narwhal{
    CCSpriteFrame *skinFrame;
    CCActionRepeatForever *skinAnimate;
}

-(id)init
{
    
    if(self = [super initWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Character-Narwhal-1.png"]])
    {
        CCAnimation *flopAnim;
        
        self.swimSpeed = 2;
        self.alive = true;
        winSize = [[CCDirector sharedDirector] viewSize];
        
#pragma skin setup
        wearingSkin = NO;
        
        equippedSkin = [[The8ArmoryStockManager sharedStockManager] getFrameForSkinBySID:[[[GameState sharedGameState] equippedSkin] objectAtIndex:1]];
        
        skin = [CCSprite node];
        [skin setPositionType:CCPositionTypeNormalized];
        [skin setPosition:ccp(0.5, 0.5)];
        [self addChild:skin z:1];
        
        if (equippedSkin) {
            [skin setSpriteFrame:[CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"%@1.png", equippedSkin]]];
            
            
            CCAnimation *skinAnim = [CCAnimation animationWithFrame:equippedSkin
                                                         frameCount:4
                                                              delay:0.3f];
            skinAnimate = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:skinAnim]];
            wearingSkin = YES;
            
            // check if wally needs to be hornless
            
            if([[The8ArmoryStockManager sharedStockManager] isWallyHornlessAtSID:[[[GameState sharedGameState] equippedSkin] objectAtIndex:1]]){
                // set base image so when anim stops, still hornless
                [self setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Character-HornlessNarwhal-1.png"]];
                
                flopAnim = [CCAnimation animationWithFrame:@"Character-HornlessNarwhal-"
                                                             frameCount:4
                                                                  delay:0.3f];
                goto animated;
            }
        }
        
        
        
        //***********************************************************************//
        
        // this gets skipped if animation is hornless
        flopAnim = [CCAnimation animationWithFrame:@"Character-Narwhal-"
                                                     frameCount:4
                                                          delay:0.3f];
    animated:
       
        
        self.jumpRotation = [CCActionRotateTo actionWithDuration:0.1f angle:-15];
        self.floppingAnim = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:flopAnim]];
        self.fallAction = [CCActionRotateTo actionWithDuration:0.3f angle:90];
        
        flopping = false;
        allowFlop = true;
        
        targetY = 0.0f;
        yThresh = 0.0f;
        
        velocity = ccp(0.0f, 0.0f);
        gravity = ccp(0.0f, -50.0f);
        
        CCPhysicsShape *body = [CCPhysicsShape circleShapeWithRadius:(self.contentSize.width - self.contentSize.width/2.15)/2 center:ccp((self.contentSize.width*2.7)/5, self.contentSize.height/2)];
        
        CCPhysicsShape *tail = [CCPhysicsShape rectShape:CGRectMake(self.contentSize.width/18, self.contentSize.height/2.6, self.contentSize.width/5, self.contentSize.height/5) cornerRadius:0];
        
        _physicsBody = [CCPhysicsBody bodyWithShapes:@[body, tail]];
        
        _physicsBody.collisionGroup = @"playerGroup";
        _physicsBody.collisionType = @"projectileCollision";
        
        
        if (wearingSkin) {
            [skin runAction:skinAnimate];
            
        }
        [self runAction:self.floppingAnim];
        [self setScale:2.0f];
    }
    return self;
}

-(void)flop
{
    if(allowFlop){
        [[OALSimpleAudio sharedInstance] playEffect:@"KrackGames-SwimJump2.wav" volume:1 pitch:1 pan:0 loop:NO];
        velocity = ccp(0, 300.0f);
        [self stopAction:self.fallAction];
        [self stopAction:self.jumpRotation];
        self.rotation = 0;
        [self runAction:self.jumpRotation];
        self.state = AnimationStateFlopping;
        targetY = self.position.y + 15;//40;
        yThresh = self.position.y;
        falling = false;
        flopping = true;
    }
}

-(void) updateMe:(CCTime)delta
{
    if([[GameScene sharedGameScene] isGameStarted] && self.alive){
        if(flopping == false){
            velocity = ccpAdd(velocity, gravity);
            self.position = ccpAdd(self.position, ccpMult(velocity, delta));
            
            
            if(falling == true && (self.position.y <= yThresh))
            {
                falling = false;
                [self stopAction:self.fallAction];
                [self runAction:self.fallAction];
            }
            
            
            if(allowFlop == false && (self.position.y <= (winSize.height - (self.contentSize.height + (self.contentSize.height/2))))){
                allowFlop = true;
            }
            
            if (FLAPPYMODE_ON) {
                if (IS_IPAD_AD) {
                    if(self.position.y <= [[GameScene sharedGameScene] ground1].contentSize.height*2.17 + self.contentSize.height/2){
                        [[GameScene sharedGameScene] gameOver];
                    }
                } else {
                    if(self.position.y <= [[GameScene sharedGameScene] ground1].contentSize.height*1.95 + self.contentSize.height/2){
                        [[GameScene sharedGameScene] gameOver];
                    }
                }
            } else {
                if(self.position.y <= [[GameScene sharedGameScene] ground1].contentSize.height*0.83f){
                    [[GameScene sharedGameScene] gameOver];
                }
            }
            
        } else{
            self.position = ccpAdd(self.position, ccpMult(velocity, delta));
            if(self.position.y >= targetY){
                flopping = false;
                falling = true;
            }
            
            if(self.position.y > (winSize.height - (self.contentSize.height + (self.contentSize.height/2)))){
                flopping = false;
                falling = true;
                allowFlop = false;
            }
            
        }
        
    } else if(self.alive){
        self.rotation = 0;
        
    } else{
        self.rotation = 90;
        velocity = ccpAdd(velocity, gravity);
        self.position = ccpAdd(self.position, ccpMult(velocity, delta));
        
        if (FLAPPYMODE_ON) {
            if (IS_IPAD_AD) {
                if(self.position.y <= [[GameScene sharedGameScene] ground1].contentSize.height*2.17 + self.contentSize.width/2){
                    self.position = ccp(self.position.x,[[GameScene sharedGameScene] ground1].contentSize.height*2.17 + self.contentSize.width/2);
                }
            } else {
                if(self.position.y <= [[GameScene sharedGameScene] ground1].contentSize.height*1.95 + self.contentSize.width/2){
                    self.position = ccp(self.position.x,[[GameScene sharedGameScene] ground1].contentSize.height*1.95 + self.contentSize.width/2);
                }
            }
        } else {
            if(self.position.y <= [[GameScene sharedGameScene] ground1].contentSize.height*5/6){
                self.position = ccp(self.position.x,[[GameScene sharedGameScene] ground1].contentSize.height*5/6);
            }
        }
        
    }
    
}

// for trying on skin in The 8 Armory
-(void)tryOutFit:(NSString *)outfit
      isHornless:(BOOL)isHornless
{
    [self stopAction:self.floppingAnim];
    [skin stopAllActions];
    
    [skin setVisible:YES];
    CCAnimation * anim = [CCAnimation animationWithFrame:outfit
                                              frameCount:4
                                                   delay:0.3f];
    
    skinAnimate = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]];
    
    //check if it is hornless
    if (isHornless) {
        CCAnimation *flopAnim = [CCAnimation animationWithFrame:@"Character-HornlessNarwhal-"
                                        frameCount:4
                                             delay:0.3f];
        self.floppingAnim = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:flopAnim]];
    } else {
        CCAnimation *flopAnim = [CCAnimation animationWithFrame:@"Character-Narwhal-"
                                                     frameCount:4
                                                          delay:0.3f];
        self.floppingAnim = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:flopAnim]];
    }
    
    [skin runAction:skinAnimate];
    [self runAction:self.floppingAnim];
    
    wearingSkin = YES;
    
}


-(void)takeOffOutfit
{
    [skin setVisible:NO];
    // stop in case it was hornless before
    [self stopAction:self.floppingAnim];
    CCAnimation *flopAnim = [CCAnimation animationWithFrame:@"Character-Narwhal-"
                                                 frameCount:4
                                                      delay:0.3f];
    self.floppingAnim = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:flopAnim]];
    
    [self runAction:self.floppingAnim];
}


@end
