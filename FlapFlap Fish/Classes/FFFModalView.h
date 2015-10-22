//
//  FFFModalView.h
//  FlapFlap Fish
//
//  Created by sh0gun on 2014-03-30.
//  Copyright 2014 Krack Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"

@interface FFFModalView : CCNode {
    
}

-(id)initRateMeModal;
-(id)initBuyNarwhalModal;
-(id)initBuyPiranhaModal;
-(void)displayModal;
-(void)displayModalWithAction:(CCAction *)action;

@end
