//
//  Obstacle.m
//  floppyFish
//
//  Created by sh0gun on 2/16/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import "Obstacle.h"
#import "GameScene.h"
#import "CCAnimation+Helper.h"

#define updownSPEED 35
#define rotatedSPEED 30


@implementation Obstacle{
    CGSize winSize;
    
    int frameChoice;    // to know which pipe frames to use
    CCSprite *bottomObs;
    CCSprite *topObs;
    float SCROLL_SPEED;
    float MIN;
    float MAX;
    
    
}


-(id)init
{
    self = [super init];
    if (!self) return(nil);
    
    winSize = [[CCDirector sharedDirector] viewSize];
    _passed = false;
    _inPhysicsWorld = NO;
    _isGroup = NO;
    _isActive = NO;
    _type = kUpDownStatic; //default Type
    _firstCalled = true;
    
    // decide which frames to use.
    frameChoice = arc4random_uniform(2);
    
    SCROLL_SPEED = [[[GameScene sharedGameScene] fish] swimSpeed];
    MIN = [[GameScene sharedGameScene] min];
    MAX = [[GameScene sharedGameScene] max];
    [self topinit];
    [self  bottominit];
    
    if (FLAPPYMODE_ON) {
        // flappy pipe hitboxes
        CCPhysicsShape *topShape, *topBodyShape, *bottomShape, *bottomBodyShape;
        
        topBodyShape = [CCPhysicsShape rectShape:CGRectMake(topObs.position.x - topObs.contentSize.width/2.3,
                                                        topObs.position.y - topObs.contentSize.height/2,
                                                        (topObs.contentSize.width*4.3/5),
                                                        topObs.contentSize.height) cornerRadius:0];
        topShape = [CCPhysicsShape rectShape:CGRectMake(topObs.position.x - topObs.contentSize.width/2,
                                                            topObs.position.y - topObs.contentSize.height/2,
                                                            (topObs.contentSize.width),
                                                            topObs.contentSize.height/18) cornerRadius:0];
        
        bottomBodyShape = [CCPhysicsShape rectShape:CGRectMake(bottomObs.position.x - bottomObs.contentSize.width/2.3,
                                                            bottomObs.position.y - bottomObs.contentSize.height/2,
                                                            (bottomObs.contentSize.width*4.3/5),
                                                            bottomObs.contentSize.height) cornerRadius:0];
        bottomShape = [CCPhysicsShape rectShape:CGRectMake(bottomObs.position.x - bottomObs.contentSize.width/2,
                                                        bottomObs.position.y + bottomObs.contentSize.height/2,
                                                        (bottomObs.contentSize.width),
                                                        -bottomObs.contentSize.height/18) cornerRadius:0];
        
        
         _physicsBody = [CCPhysicsBody bodyWithShapes:@[topBodyShape, topShape, bottomBodyShape, bottomShape]];
        
    } else {
        
        // top Obstacle hitboxes
        CCPhysicsShape *topShape; CCPhysicsShape *topMidShape; CCPhysicsShape *topMidMidShape; CCPhysicsShape *topSideShape;
        CCPhysicsShape *bottomMidShape; CCPhysicsShape *bottomShape; CCPhysicsShape *bottomMidMidShape; CCPhysicsShape *bottomSideShape;
        
        
        if (frameChoice) {
            topShape = [CCPhysicsShape rectShape:CGRectMake(topObs.position.x - topObs.contentSize.width/2.1,
                                                            topObs.position.y - topObs.contentSize.height/2.02,
                                                            (topObs.contentSize.width*3.1)/4,
                                                            topObs.contentSize.height/24) cornerRadius:0];
            
            topMidShape = [CCPhysicsShape rectShape:CGRectMake(topObs.position.x - topObs.contentSize.width/2.49,
                                                               topObs.position.y - topObs.contentSize.height/2.02,
                                                               (topObs.contentSize.width*3.13)/5,
                                                               topObs.contentSize.height) cornerRadius:0];
            
            topMidMidShape = [CCPhysicsShape rectShape:CGRectMake(topObs.position.x - topObs.contentSize.width/2.1, topObs.position.y - topObs.contentSize.height/4.22, (topObs.contentSize.width*3.1)/4, topObs.contentSize.height/9.0) cornerRadius:0];
            
            topSideShape = [CCPhysicsShape rectShape:CGRectMake(topObs.position.x + topObs.contentSize.width/4,
                                                                topObs.position.y - topObs.contentSize.height/2.35,
                                                                (topObs.contentSize.width*3.1)/12.2,
                                                                topObs.contentSize.height/6.5) cornerRadius:0];
            
            // bottom obstacle hitboxes
            bottomShape =  [CCPhysicsShape rectShape:CGRectMake(bottomObs.position.x - bottomObs.contentSize.width/2.1, bottomObs.position.y + bottomObs.contentSize.height/2.02, (bottomObs.contentSize.width*3.1)/4, -bottomObs.contentSize.height/24 ) cornerRadius:0];
            
            bottomMidShape =  [CCPhysicsShape rectShape:CGRectMake(bottomObs.position.x - bottomObs.contentSize.width/2.49, bottomObs.position.y + bottomObs.contentSize.height/2.02, (bottomObs.contentSize.width*3.13)/5, -bottomObs.contentSize.height ) cornerRadius:0];
            
            bottomMidMidShape =  [CCPhysicsShape rectShape:CGRectMake(bottomObs.position.x - bottomObs.contentSize.width/2.1, bottomObs.position.y + bottomObs.contentSize.height/4.22, (bottomObs.contentSize.width*3.1)/4, -bottomObs.contentSize.height/9.0 ) cornerRadius:0];
            
            bottomSideShape =  [CCPhysicsShape rectShape:CGRectMake(bottomObs.position.x + bottomObs.contentSize.width/4,
                                                                    bottomObs.position.y + bottomObs.contentSize.height/2.35,
                                                                    (bottomObs.contentSize.width*3.1)/12.2,
                                                                    -bottomObs.contentSize.height/6.5 ) cornerRadius:0];
            
        } else {
            topShape = [CCPhysicsShape rectShape:CGRectMake(topObs.position.x - topObs.contentSize.width/3.3,
                                                            topObs.position.y - topObs.contentSize.height/2.02,
                                                            (topObs.contentSize.width*3.1)/4,
                                                            topObs.contentSize.height/24) cornerRadius:0];
            
            topMidShape = [CCPhysicsShape rectShape:CGRectMake(topObs.position.x - topObs.contentSize.width/4.4,
                                                               topObs.position.y - topObs.contentSize.height/2.02,
                                                               (topObs.contentSize.width*3.13)/5,
                                                               topObs.contentSize.height) cornerRadius:0];
            
            topMidMidShape = [CCPhysicsShape rectShape:CGRectMake(topObs.position.x - topObs.contentSize.width/3.3,
                                                                  topObs.position.y - topObs.contentSize.height/4.22,
                                                                  (topObs.contentSize.width*3.1)/4, topObs.contentSize.height/9.0) cornerRadius:0];
            
            topSideShape = [CCPhysicsShape rectShape:CGRectMake(topObs.position.x - topObs.contentSize.width/2.1,
                                                                topObs.position.y - topObs.contentSize.height/10.8,
                                                                (topObs.contentSize.width*3.1)/12.2,
                                                                topObs.contentSize.height/6.5) cornerRadius:0];
            
            // bottom obstacle hitboxes
            bottomShape =  [CCPhysicsShape rectShape:CGRectMake(bottomObs.position.x - bottomObs.contentSize.width/3.3,
                                                                bottomObs.position.y + bottomObs.contentSize.height/2.02,
                                                                (bottomObs.contentSize.width*3.1)/4,
                                                                -bottomObs.contentSize.height/24) cornerRadius:0];
            bottomMidShape =  [CCPhysicsShape rectShape:CGRectMake(bottomObs.position.x - bottomObs.contentSize.width/4.4,
                                                                   bottomObs.position.y + bottomObs.contentSize.height/2.02,
                                                                   (bottomObs.contentSize.width*3.13)/5, -bottomObs.contentSize.height ) cornerRadius:0];
            
            bottomMidMidShape =  [CCPhysicsShape rectShape:CGRectMake(bottomObs.position.x - bottomObs.contentSize.width/3.3,
                                                                      bottomObs.position.y + bottomObs.contentSize.height/4.22,
                                                                      (bottomObs.contentSize.width*3.1)/4,
                                                                      -bottomObs.contentSize.height/9.0 ) cornerRadius:0];
            
            bottomSideShape =  [CCPhysicsShape rectShape:CGRectMake(bottomObs.position.x - bottomObs.contentSize.width/2.1,
                                                                    bottomObs.position.y + bottomObs.contentSize.height/10.8,
                                                                    (bottomObs.contentSize.width*3.1)/12.2,
                                                                    -bottomObs.contentSize.height/6.5 ) cornerRadius:0];
        }
        
        
        _physicsBody = [CCPhysicsBody bodyWithShapes:@[topShape, topMidShape, topMidMidShape,topSideShape, bottomShape, bottomMidShape, bottomMidMidShape, bottomSideShape]];
    }
    
    _physicsBody.collisionGroup = @"obstacleGroup";
    _physicsBody.collisionType = @"monsterCollision";
    _physicsBody.sensor = NO;
    
    
    [self setScale:2];
    return self;
}


-(void)topinit
{
    if(frameChoice){
        if (FLAPPYMODE_ON) {
            topObs = [CCSprite spriteWithImageNamed:@"Barrier-Top-FB.png"];
        } else {
            topObs = [CCSprite spriteWithImageNamed:@"Barrier-Top-1.png"];
        }
    } else{
        if (FLAPPYMODE_ON) {
            topObs = [CCSprite spriteWithImageNamed:@"Barrier-Top-FB.png"];
        } else {
            topObs = [CCSprite spriteWithImageNamed:@"Barrier-Top-2.png"];
        }
    }
    
    [topObs setPosition:ccp(self.position.x, self.position.y + topObs.contentSize.height/2 + spaceBetweenTopBottom/2)];
    
    [self addChild:topObs];
}


-(void)bottominit{
    if(frameChoice){
        if (FLAPPYMODE_ON) {
            bottomObs = [CCSprite spriteWithImageNamed:@"Barrier-Bottom-FB.png"];
        } else {
            bottomObs = [CCSprite spriteWithImageNamed:@"Barrier-Bottom-1.png"];
        }
        
    } else {
        if (FLAPPYMODE_ON) {
            bottomObs = [CCSprite spriteWithImageNamed:@"Barrier-Bottom-FB.png"];
        } else {
            bottomObs = [CCSprite spriteWithImageNamed:@"Barrier-Bottom-2.png"];
        }
        
    }
    
    [bottomObs setPosition:ccp(self.position.x, self.position.y - bottomObs.contentSize.height/2 - spaceBetweenTopBottom/2)];
    
    [self addChild:bottomObs];
}

-(void)changeToType:(ObstacleType)type
{
//    int direction;
    
    switch (type) {
        case kUpDownStatic:
            self.rotation = 0;
            break;
        case kUpDownDynamic:
            self.rotation = 0;
            break;
        case kRotatedStatic:
//            direction = arc4random_uniform(2);
//            if (direction) {
                rDir = kDirNE;
                self.rotation = 25;
//            } else {
//                rDir = kDirNW;
//                self.rotation = -25;
//            }
            break;
        case kRotatedDynamic:
//            direction = arc4random_uniform(2);
//            if (direction) {
                rDir = kDirNE;
                self.rotation = 25;
//            } else {
//                rDir = kDirNW;
//                self.rotation = -25;
//            }
            break;
    }
    self.type = type;
}

-(void)scroll:(CCTime)dt
{
//    self.position = ccpAdd(self.position, ccpMult(ccp(-SCROLL_SPEED, 0), dt));
    self.position = ccpAdd(self.position, ccpMult(ccp(-SCROLL_SPEED, 0), 1));
}


-(void)movement:(CCTime)dt
{
    if (_type == kUpDownDynamic) {
        if(self.firstCalled){
            int rand = arc4random_uniform(2);
            if(rand == 1){
                _moveDown = true;
            }else{
                _moveDown = false;
            }
            self.firstCalled = false;
        }
        
        if(_moveDown){
            if(self.position.y >= MIN){
                self.position = ccpAdd(self.position, ccpMult(ccp(0,-updownSPEED), dt));
            } else{
                _moveDown = false;
            }
            
        }else{
            if(self.position.y <= MAX){
                self.position = ccpAdd(self.position, ccpMult(ccp(0,updownSPEED), dt));
            } else {
                _moveDown = true;
                
            }
            
        }
    } else if (_type == kRotatedDynamic){
        if(self.firstCalled){
            int rand = arc4random_uniform(2);
            if(rand == 1){
                _moveDown = true;
            }else{
                _moveDown = false;
            }
            self.firstCalled = false;
        }
        
        if(_moveDown){
            if(self.position.y >= MIN){
                // depends on the rotation direction
                if (rDir == kDirNE) {
                    self.position = ccpAdd(self.position, ccpMult(ccp(-rotatedSPEED * (1 - cos(25)),-rotatedSPEED * cos(25)), dt));
                } else {
                    self.position = ccpAdd(self.position, ccpMult(ccp(rotatedSPEED * (1 - cos(25)),-rotatedSPEED * cos(25)), dt));
                }
                
            } else{
                _moveDown = false;
            }
            
        } else{
            if(self.position.y <= MAX){
                if (rDir == kDirNE) {
                    self.position = ccpAdd(self.position, ccpMult(ccp(rotatedSPEED * (1 - cos(25)),rotatedSPEED * cos(-25)), dt));
                } else {
                    self.position = ccpAdd(self.position, ccpMult(ccp(-rotatedSPEED * (1 - cos(25)),rotatedSPEED * cos(-25)), dt));
                }
                
            } else {
                _moveDown = true;
            }
        }
    }
}


-(void) dealloc
{
    CCLOG(@"deallocing obstacle");
    [self removeAllChildrenWithCleanup:YES];
    self.physicsBody = nil;
    bottomObs = nil;
    topObs = nil;
}



@end
