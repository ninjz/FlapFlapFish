//
//  CharSelectLayer.h
//  floppyFish
//
//  Created by sh0gun on 2/15/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"

@interface CharSelectLayer : CCNode {
    
}

@property(nonatomic, retain) CCLabelBMFont *unlockText;

- (id)init;
- (void)initFrame;

@end
