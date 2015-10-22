//
//  AppDelegate.m
//  floppyFish
//
//  Created by Calvin Cheng on 2/10/2014.
//  Copyright JAC studios 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "AppDelegate.h"
#import "MenuScene.h"
#import "FFFishIAPHelper.h"
#import "MyiAd.h"
#import "The8Armory.h"
#import "The8ArmoryStockManager.h"
#import "SDCloudUserDefaults.h"
#import "Chartboost.h"
#import <Parse/Parse.h>


@implementation AppDelegate

static BOOL notSynced = TRUE;

//
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// This is the only app delegate method you need to implement when inheriting from CCAppDelegate.
	// This method is a good place to add one time setup code that only runs when your app is first launched.
	
	// Setup Cocos2D with reasonable defaults for everything.
	// There are a number of simple options you can change.
	// If you want more flexibility, you can configure Cocos2D yourself instead of calling setupCocos2dWithOptions:.
    (IS_IPAD_AD) ?
	[self setupCocos2dWithOptions:@{
                                    // Show the FPS and draw call label.
                                    //		CCSetupShowDebugStats: @(YES),
                                    
                                    // More examples of options you might want to fiddle with:
                                    // (See CCAppDelegate.h for more information)
                                    
                                    // Use a 16 bit color buffer:
                                    CCSetupPixelFormat: kEAGLColorFormatRGB565,
                                    
                                    // Use a simplified coordinate system that is shared across devices.
                                    CCSetupScreenMode: CCScreenModeFixed,
                                    // Run in portrait mode.
                                    CCSetupScreenOrientation: CCScreenOrientationPortrait,
                                    // Run at a reduced framerate.
//                                    		CCSetupAnimationInterval: @(1.0/10.0),
                                    // Run the fixed timestep extra fast.
                                    //		CCSetupFixedUpdateInterval: @(1.0/60.0),
                                    // Make iPad's act like they run at a 2x content scale. (iPad retina 4x)
                                    CCSetupTabletScale2X: @(YES),
                                    }]
    
    :
    
    [self setupCocos2dWithOptions:@{
                                    // Show the FPS and draw call label.
//                                        	CCSetupShowDebugStats: @(YES),
                                    
                                    // More examples of options you might want to fiddle with:
                                    // (See CCAppDelegate.h for more information)
                                    
                                    // Use a 16 bit color buffer:
                                    CCSetupPixelFormat: kEAGLColorFormatRGB565,
                                    // Use a simplified coordinate system that is shared across devices.
//                                      CCSetupScreenMode: CCScreenModeFixed,
                                    // Run in portrait mode.
                                    CCSetupScreenOrientation: CCScreenOrientationPortrait,
                                    // Run at a reduced framerate.
//                                         		CCSetupAnimationInterval: @(1.0/60.0),
                                    // Run the fixed timestep extra fast.
                                    //     		CCSetupFixedUpdateInterval: @(1.0/60.0),
                                    // Make iPad's act like they run at a 2x content scale. (iPad retina 4x)
//                                    CCSetupTabletScale2X: @(YES),
                                    }];
    
    // for background gap??
    if (!(IS_IPAD_AD)) {
        [[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];
    }
    
    
    
    self.isBannerOn=false;
    
    if(IS_BANNER_ON_TOP)
    {
        self.isBannerOnTop = true;
    }
    else
    {
        self.isBannerOnTop = false;
    }
    
    
    [Parse setApplicationId:@"Csg9YQSR7LPUDgQ4TXjd2NH7BrqCIFeSoKLsDFGx"
                  clientKey:@"cOcrH3FutwYr11N58Y7WIuSpenUVzHyfdk3HEf7N"];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
#ifdef ANDROID
    [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenBestEmulatedMode];
#endif
    
    
	return YES;
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}


- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}


-(void)cloudSynced:(NSNotification *)obj
{
    notSynced = FALSE;
}


-(CCScene *)startScene
{
	
    
    //initialize stockmanager
    [The8ArmoryStockManager sharedStockManager];
    
    
    // iCloud !!!!
    [SDCloudUserDefaults registerForNotifications];
    
    if(![GameState sharedGameState].playCount) {
        [GameState sharedGameState].highScore = [NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0]];
        [GameState sharedGameState].deaths = 0;
        [GameState sharedGameState].curSelectedFish = 0;
        [GameState sharedGameState].unlockedFishes = [NSMutableDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO]]
                                                                      forKeys:@[@"main_fish",
                                                                                @"narwhal",
                                                                                @"piranha",
                                                                                @"angler",
                                                                                @"zombie"]];
        [GameState sharedGameState].currencyCollected = [NSMutableDictionary dictionaryWithObjects:@[[NSMutableArray arrayWithArray:@[@0,@0,@0]],
                                                                                                     [NSMutableArray arrayWithArray:@[@0,@0,@0]],
                                                                                                     [NSMutableArray arrayWithArray:@[@0,@0,@0]],
                                                                                                     [NSMutableArray arrayWithArray:@[@0,@0,@0]],
                                                                                                     [NSMutableArray arrayWithArray:@[@0,@0,@0]]]
                                                                                           forKeys:@[@"Blowfish",
                                                                                                     @"Narwhal",
                                                                                                     @"Piranha",
                                                                                                     @"Angler",
                                                                                                     @"Zombie"]];
        
        
        [GameState sharedGameState].adsRemoved = NO;
        
    }

    
    if ([GameState sharedGameState].currentVersion < 2) {
        [GameState sharedGameState].skinsOwned = [NSMutableArray arrayWithArray:@[]];
        [GameState sharedGameState].equippedSkin = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@""]];
        [GameState sharedGameState].amount8coin = 999;
        [GameState sharedGameState].rated = FALSE;
        [GameState sharedGameState].fbLiked = FALSE;
        [GameState sharedGameState].currentVersion = 2;
        if (![[NSFileManager defaultManager]
              URLForUbiquityContainerIdentifier:nil]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"iCloud Game Save"
                                  message:@"Turn on iCloud to save game data onto the cloud."
                                  delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil, nil];
            [alert show];
        }
        CCLOG(@"at version 2!");
    }
    
    
    
    [GameState sharedGameState].soundON = YES;
    [GameState sharedGameState].playCount++;
    
    [[GameState sharedGameState] saveState];
    
    
    
    // initialize IAP $$$$$
    [FFFishIAPHelper sharedInstance];
    
    // ADS $$$$$
    mIAd = [[MyiAd alloc] init];
//    [self createAdmobAds];
//    [self hideAdMobBannerView];
    [mIAd hideBannerView];
    
    
    // access audio object
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    // play background sound
    [audio preloadEffect:@"death.wav"];
    [audio preloadEffect:@"KrackGames-SwimJump2.wav"];
    
    
    
    [audio playBg:@"Ouroboros.mp3" volume:0.03 pan:0 loop:YES];
    
    
    
	return [MenuScene scene];
}




-(void)ShowIAdBanner
{
    if([[GameState sharedGameState] adsRemoved])
    {
        self.isBannerOn = false;
        [self hideIAdBanner];
        return;
    }
    
    self.isBannerOn = true;
    
    if(mIAd)
    {
        [mIAd showBannerView];
    }
    else
    {
//        [self showAdMobBannerView];
        mIAd = [[MyiAd alloc] init];
    }
}


-(void)hideIAdBanner
{
    self.isBannerOn = false;
    if(mIAd){
        [mIAd hideBannerView];
    } else {
        // refresh only ever so often
        if ([[GameState sharedGameState] deaths] % 3) {
            [self refreshAdMobBanner];
        }
        
        [self hideAdMobBannerView];
    }
    
}

-(void)bannerDidFail
{
    mIAd = nil;
#if TARGET_IPHONE_SIMULATOR
    UIAlertView* alert= [[UIAlertView alloc] initWithTitle: @"Simulator_ShowAlert!" message: @"didFailToReceiveAdWithError:"
                                                  delegate: NULL cancelButtonTitle: @"OK" otherButtonTitles: NULL];
	[alert show];
#endif
}


/** ADMOB BANNERS **/

-(void)createAdmobAds
{
//    if (![[GameState sharedGameState] adsRemoved]) {
        mBannerType = BANNER_TYPE;
        
        if(mBannerType <= kBanner_Portrait_Bottom)
            mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        else
            mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
        
        // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
        
        mBannerView.adUnitID = ADMOB_BANNER_UNIT_ID;
        
        
        // Let the runtime know which UIViewController to restore after taking
        // the user wherever the ad goes and add it to the view hierarchy.
        
        mBannerView.rootViewController = self.navController;
        [self.navController.view addSubview:mBannerView];
        
        //    #ifdef DEBUG
        //       GADRequest *request = [GADRequest request];
        //    request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
        //    request.testDevices = @[ @"7d12c06068a590bf78b526defbf4354c" ];
        //    [mBannerView loadRequest:request];
        //    #endif
        
        
        // Initiate a generic request to load it with an ad.
        [mBannerView loadRequest:[GADRequest request]];
        
        CGSize s = [[CCDirector sharedDirector] viewSize];
        
        CGRect frame = mBannerView.frame;
        
        off_x = 0.0f;
        on_x = 0.0f;
        
        switch (mBannerType)
        {
            case kBanner_Portrait_Top:
            {
                off_y = -frame.size.height;
                on_y = 0.0f;
            }
                break;
            case kBanner_Portrait_Bottom:
            {
                
                off_y = (IS_IPAD_AD) ? s.height*2 : s.height;
                on_y = (IS_IPAD_AD) ? s.height*2 - frame.size.height : s.height-frame.size.height;
            }
                break;
            case kBanner_Landscape_Top:
            {
                off_y = -frame.size.height;
                on_y = 0.0f;
            }
                break;
            case kBanner_Landscape_Bottom:
            {
                off_y = s.height;
                on_y = s.height-frame.size.height;
            }
                break;
                
            default:
                break;
        }
        
        frame.origin.y = off_y;
        frame.origin.x = off_x;
        
        mBannerView.frame = frame;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        frame = mBannerView.frame;
        frame.origin.x = on_x;
        frame.origin.y = on_y;
        
        
        mBannerView.frame = frame;
        [UIView commitAnimations];
//    }
}

-(void)refreshAdMobBanner
{
    [mBannerView loadRequest:[GADRequest request]];
}


-(void)showAdMobBannerView
{
    if(![[GameState sharedGameState] adsRemoved]) {
        if (mBannerView)
        {
            //banner on bottom
            {
                CGRect frame = mBannerView.frame;
                frame.origin.y = off_y;
                frame.origin.x = on_x;
                mBannerView.frame = frame;
                
                
                [UIView animateWithDuration:0.5
                                      delay:0.1
                                    options: UIViewAnimationCurveEaseOut
                                 animations:^
                 {
                     CGRect frame = mBannerView.frame;
                     frame.origin.y = on_y;
                     frame.origin.x = on_x;
                     
                     mBannerView.frame = frame;
                 }
                                 completion:^(BOOL finished)
                 {
                 }];
            }
            
        }
    } else {
//        [self dismissAdView];
    }
    
}


-(void)hideAdMobBannerView
{
    if (mBannerView)
    {
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             CGRect frame = mBannerView.frame;
             frame.origin.y = off_y;
             frame.origin.x = off_x;
             mBannerView.frame = frame;
         }
                         completion:^(BOOL finished)
         {
             
             
         }];
    }
}


-(void)dismissAdView
{
    if (mBannerView)
    {
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             CGSize s = [[CCDirector sharedDirector] viewSize];
             
             CGRect frame = mBannerView.frame;
             frame.origin.y = frame.origin.y + frame.size.height ;
             frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
             mBannerView.frame = frame;
         }
                         completion:^(BOOL finished)
         {
             [mBannerView setDelegate:nil];
             [mBannerView removeFromSuperview];
             mBannerView = nil;
             
         }];
    }
    
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    cb = [Chartboost sharedChartboost];
    cb.appId = @"5337bbdf2d42da7528a881d2";
    cb.appSignature = @"525ce641a98e4ba15d3be59be141d7e19528cb32";
    cb.delegate = self;
    [cb startSession];
    [cb cacheInterstitial];
    
//    [Pollfish initAtPosition:PollFishPositionBottomRight
//                 withPadding:10
//             andDeveloperKey:@"a7789624-dac0-4e60-ada0-4e64193aabc9"
//               andDebuggable:false
//               andCustomMode:false];
    
    [[CCDirector sharedDirector] resume];
}

-(void)applicationWillTerminate:(UIApplication *)application
{
//    [Pollfish destroy];
}

-(void)didDismissInterstitial:(CBLocation)location
{
    [[Chartboost sharedChartboost] cacheInterstitial:location];
}


@end
