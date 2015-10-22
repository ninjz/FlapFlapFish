//
//  CCNode+Scaling.h
//  floppyFish
//
//  Created by sh0gun on 2/13/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
    CCScaleFitFull,
    CCScaleFitAspectFit,
    CCScaleFitAspectFill,
} CCScaleFit;

@interface CCNode (Scaling)

-(void)scaleToSize:(CGSize)size fitType:(CCScaleFit)fitType;

@end

