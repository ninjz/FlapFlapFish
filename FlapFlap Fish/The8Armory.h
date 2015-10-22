//
//  The8Armory.h
//  FlapFlap Fish
//
//  Created by sh0gun on 3/10/2014.
//  Copyright 2014 Krack Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "Fish.h"

@interface The8Armory : CCScene <CCScrollViewDelegate> {
    
}

@property (nonatomic, strong) Fish *fish;
@property (nonatomic, strong) CCTableView *shopTable;
@property (nonatomic, assign) BOOL purchaseActive;

+ (The8Armory *) shared8ArmoryScene;
+ (The8Armory *) scene;

-(void)purchaseSkin:(NSDictionary *)skin;
-(void)hidePurchaseModal;
-(void)displayPurchaseCoinsModal;
-(void)displayMessageModalWithString:(NSString *)msg;
-(void)displayRateMeModal;
-(void)purchasedSkin;

@end
