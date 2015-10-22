//
//  AppDelegate.h
//  floppyFish
//
//  Created by Calvin Cheng on 2/10/2014.
//  Copyright JAC studios 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "cocos2d.h"

#define ADMOB_BANNER_UNIT_ID  ((IS_IPAD) ? @"ca-app-pub-4972682479042100/6545695672"  : @"ca-app-pub-4972682479042100/6545695672" );
typedef enum _bannerType
{
    kBanner_Portrait_Top,
    kBanner_Portrait_Bottom,
    kBanner_Landscape_Top,
    kBanner_Landscape_Bottom,
}CocosBannerType;

#define BANNER_TYPE kBanner_Portrait_Bottom

#import "GADBannerView.h"
#import "Chartboost.h"

@class MyiAd;

@interface AppDelegate : CCAppDelegate <ChartboostDelegate> {
    MyiAd   *mIAd;
    Chartboost *cb;
    bool   mIsBannerOn;
    
    bool   mBannerOnTop;
    
    
    //AD MOB
    CocosBannerType mBannerType;
    GADBannerView *mBannerView;
    float on_x, on_y, off_x, off_y;
}


@property(nonatomic, assign) bool isBannerOn;
@property(nonatomic, assign) bool isBannerOnTop;



-(void)ShowIAdBanner;
-(void)hideIAdBanner;
-(void)bannerDidFail;

// ADMOB
-(void)hideAdMobBannerView;
-(void)showAdMobBannerView;
-(void)refreshAdMobBanner;



@end
