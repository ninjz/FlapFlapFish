//
//  BlowFish.m
//  floppyFish
//
//  Created by sh0gun on 2/20/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import "BlowFish.h"
#import "CCAnimation+Helper.h"
#import "OALSimpleAudio.h"
#import "GameScene.h"
#import "The8ArmoryStockManager.h"


@implementation BlowFish{
    CCActionRepeatForever *deflatedAnim;
    CCSpriteFrame *inflatedSkin;
    CCSpriteFrame *floppingFrame;
}

-(id)init
{
    
    if(self = [super initWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Character-Puffer-1.png"]])
    {
        
        self.swimSpeed = 3;//177;//3;
        self.alive = true;
        
        
#pragma skin setup
        wearingSkin = NO;
        
        // equip skin
//        equippedSkin = [[GameState sharedGameState] equippedSkin];
        equippedSkin = [[The8ArmoryStockManager sharedStockManager] getFrameForSkinBySID:[[[GameState sharedGameState] equippedSkin] objectAtIndex:0]];
        
        skin = [CCSprite node];
        [skin setPositionType:CCPositionTypeNormalized];
        [skin setPosition:ccp(0.5, 0.5)];
        [self addChild:skin z:10];
        
        if (equippedSkin) {
            [skin setSpriteFrame:[CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"%@1.png", equippedSkin]]];
            
            
            
            wearingSkin = YES;
            
            CCAnimation *deflated = [CCAnimation animationWithFrame:equippedSkin
                                                         frameCount:2
                                                              delay:0.3f];
            deflatedAnim = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:deflated]];
            
            inflatedSkin = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"%@3.png", equippedSkin]];
            
        }
    
        
        
        //***********************************************************************//
        
        winSize = [[CCDirector sharedDirector] viewSize];
        
        
        floppingFrame = [CCSpriteFrame frameWithImageNamed:@"Character-Puffer-3.png"];
        
        CCAnimation *diveAnim = [CCAnimation animationWithFrame:@"Character-Puffer-"
                                                     frameCount:2
                                                          delay:0.3f];
        
        self.divingAnim = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:diveAnim]];
        
        self.fallAction = [CCActionRotateTo actionWithDuration:2.8f angle:90];  //prev 0.8f
        
        flopping = false;
        allowFlop = true;
        
        targetY = 0.0f;
        yThresh = 0.0f;
        
        velocity = ccp(0.0f, 0.0f);
        acceleration = ccp(0.0f, 10);
        gravity = ccp(0.0f, -35.0f); //-30.0f);
        
        CCPhysicsShape *body = [CCPhysicsShape circleShapeWithRadius:(self.contentSize.width - self.contentSize.width/3)/2 center:ccp((self.contentSize.width*2.7)/5, self.contentSize.height/2.1)];
        CCPhysicsShape *head = [CCPhysicsShape circleShapeWithRadius:(self.contentSize.width - self.contentSize.width/2.3)/2 center:ccp((self.contentSize.width*3.3)/5, self.contentSize.height/2.3)];
        CCPhysicsShape *tail = [CCPhysicsShape rectShape:CGRectMake(self.contentSize.width/18, self.contentSize.height/4, self.contentSize.width/6, self.contentSize.height/3) cornerRadius:0];
        
        body.collisionGroup = @"uninflated";
        head.collisionGroup = @"uninflated";
        tail.collisionGroup = @"uninflated";
        
        CCPhysicsShape *bodyInflated = [CCPhysicsShape circleShapeWithRadius:(self.contentSize.width - self.contentSize.width/5.5)/2
                                                                      center:ccp((self.contentSize.width*2.9)/5, self.contentSize.height/2.0)];
        
        CCPhysicsShape *tailInflated = [CCPhysicsShape rectShape:CGRectMake(self.contentSize.width/18, self.contentSize.height/6, self.contentSize.width/6, self.contentSize.height/3) cornerRadius:0];
        
        bodyInflated.collisionGroup = @"inflated";
        tailInflated.collisionGroup = @"inflated";
        
        
        
        
        _physicsBody = [CCPhysicsBody bodyWithShapes:@[body, head, tail,
                                                       bodyInflated, tailInflated]];
        _physicsBody.collisionType = @"projectileCollision";
        
        
        
        self.state = AnimationStateDiving;
        [self runAction:self.divingAnim];
        
//        [self runAction:self.floppingAnim];
        if (wearingSkin) {
            [skin runAction:deflatedAnim];
        }
        
        
        [self setScale:2];
    }
    return self;
}

-(void)stopDive
{
    if(allowFlop){
        
        [[OALSimpleAudio sharedInstance] playEffect:@"KrackGames-SwimJump2.wav" volume:1 pitch:1 pan:0 loop:NO];
        velocity = ccp(0, 200.0f);   // oldval : 300.0f
        [self stopAction:self.fallAction];
        self.rotation = 0;
        if(self.state == AnimationStateDiving){
            [self stopAction:self.divingAnim];
            [self setSpriteFrame:floppingFrame];
        }
        [self runAction:[CCActionRotateTo actionWithDuration:0.1f angle:-10]];
        self.state = AnimationStateFlopping;
        
        flopping = true;
        falling = false;
        [self setSkin];
    }
}

-(void)dive
{
    
    if(self.state == AnimationStateFlopping){
        [self stopAction:self.floppingAnim];
        [self runAction:self.divingAnim];
        self.state = AnimationStateDiving;
    }
    
    flopping = false;
    falling = true;
    [self setSkin];
}

-(void) updateMe:(CCTime)delta
{
    if([[GameScene sharedGameScene] isGameStarted] && self.alive){
        if(flopping == false){
            velocity = ccpAdd(velocity, gravity);
            self.position = ccpAdd(self.position, ccpMult(velocity, delta));
            
            
            if(falling == true)
            {
                allowFlop = true;
                falling = false;
                [self stopAction:self.fallAction];
                [self runAction:self.fallAction];
            }
            
            if (FLAPPYMODE_ON) {
                if (IS_IPAD_AD) {
                    if(self.position.y <= [[GameScene sharedGameScene] ground1].contentSize.height*2.22 + self.contentSize.height/2){
                        [[GameScene sharedGameScene] gameOver];
                    }
                } else {
                    if(self.position.y <= [[GameScene sharedGameScene] ground1].contentSize.height*2 + self.contentSize.height/2){
                        [[GameScene sharedGameScene] gameOver];
                    }
                }
            } else {
                if(self.position.y <= [[GameScene sharedGameScene] ground1].contentSize.height*0.83f){
                    [[GameScene sharedGameScene] gameOver];
                }
            }
            
            

            
            
        } else{
            velocity = ccpAdd(velocity, acceleration);
            self.position = ccpAdd(self.position, ccpMult(velocity, delta));
            
            if(self.position.y >= (winSize.height - (self.contentSize.height + self.contentSize.height*0.5))){
                self.position = ccp(self.position.x ,winSize.height - (self.contentSize.height + self.contentSize.height*0.5));
                if(self.state == AnimationStateFlopping){
//                    [self stopAction:self.floppingAnim];
                    [self runAction:self.divingAnim];
                    self.state = AnimationStateDiving;
                    [self setSkin];
                }
                
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
                if(self.position.y <= [[GameScene sharedGameScene] ground1].contentSize.height*2.22 + self.contentSize.width/2){
                    self.position = ccp(self.position.x,[[GameScene sharedGameScene] ground1].contentSize.height*2.22 + self.contentSize.width/2);
                }
            } else {
                if(self.position.y <= [[GameScene sharedGameScene] ground1].contentSize.height*2 + self.contentSize.width/2){
                    self.position = ccp(self.position.x,[[GameScene sharedGameScene] ground1].contentSize.height*2 + self.contentSize.width/2);
                }
            }
        } else {
            if(self.position.y <= [[GameScene sharedGameScene] ground1].contentSize.height*5/6){
                self.position = ccp(self.position.x,[[GameScene sharedGameScene] ground1].contentSize.height*5/6);
            }
        }
    }
    
}


-(void)setSkin
{
    if (wearingSkin) {
        if (flopping) {
            [skin stopAllActions];
            [skin setSpriteFrame:inflatedSkin];
        }else {
//            [skin setSpriteFrame:inflatedSkin];
            [skin stopAllActions];
            [skin runAction:deflatedAnim];
        }
    }
}

// for trying on skin in The 8 Armory
-(void)tryOutFit:(NSString *)outfit
{
    [skin setVisible:YES];
    inflatedSkin = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"%@3.png",outfit]];
    CCAnimation *deflated = [CCAnimation animationWithFrame:outfit
                                                 frameCount:2
                                                      delay:0.3f];
    deflatedAnim = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:deflated]];
    wearingSkin = YES;
    [self setSkin];
    
}

-(void)takeOffOutfit
{
    [skin setVisible:NO];
}

-(void)idle
{
    [self stopAllActions];
    [self setSpriteFrame:floppingFrame];
//    [skin setSpriteFrame:inflatedSkin];
    flopping = YES;
    [self setSkin];
}




@end
