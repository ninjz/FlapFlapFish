//
//  FFFishIAPHelper.m
//  floppyFish
//
//  Created by sh0gun on 2/25/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import "FFFishIAPHelper.h"


@implementation FFFishIAPHelper

+ (FFFishIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static FFFishIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.krackgames.FlapFlapFish.removeAds",
                                      @"com.krackgames.FlapFlapFish.buy5Coins",
                                      @"com.krackgames.FlapFlapFish.buy15Coins",
                                      @"com.krackgames.FlapFlapFish.buy30Coins",
                                      @"com.krackgames.FlapFlapFish.buyNarwhal",
                                      @"com.krackgames.FlapFlapFish.buyPiranha",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
