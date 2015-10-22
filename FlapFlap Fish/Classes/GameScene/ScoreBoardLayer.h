//
//  ScoreBoardLayer.h
//  floppyFish
//
//  Created by sh0gun on 2/18/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"

@interface ScoreBoardLayer : CCNode {
    
}

- (id)init;
-(void)updateScore:(int)newScore;
-(void)updateHighScore:(int)newHighScore;

@end
