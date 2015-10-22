//
//  CCAnimation+Helper.h
//  Ninjahz
//
//  Created by Calvin Cheng on 2013-04-30.
//
//

#import "CCAnimation.h"
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"

@interface CCAnimation (Helper)

+(CCAnimation *) animationWithFrame:(NSString *)frame
                         frameCount:(int)frameCount
                              delay:(float)delay;


@end
