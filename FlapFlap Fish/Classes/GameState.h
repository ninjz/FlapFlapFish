//
//  GameState.h
//  floppyFish
//
//  Created by sh0gun on 2/16/2014.
//  Copyright (c) 2014 JAC studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kGameStatePlayCount @"play_count"
#define kGameStatecurSelectedFish @"curr_fish"
#define kGameStateHighScore @"high_score"
#define kGameStateDeaths @"deaths"
#define kGameStateSoundOn @"sound_on"
#define kGameStateUnlockedFishes @"unlocked_fishes"
#define kGameStateAdsRemoved @"ads_removed"
#define kGameStateCurrencyCollected @"currency_collected"

//update 2.0
#define kGameStateSkinsOwned @"skins_owned"
#define kGameStateCurSkinEquipped @"curr_skin"
#define kGameState8coin @"amount_8coin"
#define kGameStateRated @"rated"
#define kGameStateFbLiked @"fb_liked"
#define kGameStateCurrentVersion @"current_version"


@interface GameState : NSObject

@property(nonatomic, assign) int playCount;
@property(nonatomic, assign) int deaths;
@property(nonatomic, retain) NSMutableArray *highScore;
@property(nonatomic, assign) int curSelectedFish;
@property(nonatomic, assign) BOOL soundON;
@property(nonatomic, assign) BOOL adsRemoved;
@property(nonatomic, retain) NSMutableDictionary *unlockedFishes;
@property(nonatomic, retain) NSMutableDictionary *currencyCollected;

// v1.5
@property(nonatomic, retain) NSMutableArray *skinsOwned;
@property(nonatomic, retain) NSMutableArray *equippedSkin;
@property(nonatomic, assign) int amount8coin;
@property(nonatomic, assign) BOOL rated;
@property(nonatomic, assign) BOOL fbLiked;
@property(nonatomic, assign) int currentVersion;

typedef NS_ENUM(NSInteger, CoinType)
{
    CoinTypeBronze,
    CoinTypeSilver,
    CoinTypeGold,
    CoinType8coin,
};


-(void) loadSavedState;
-(void) saveState;
-(void) buttonPressedSound;
-(NSArray *) getCurrencyForCurrFish;
-(NSString *)getCoinForCurrFish:(CoinType)coinType;
-(void) debitAmount:(NSNumber *)amount
               from:(CoinType)coinType;
-(void) credit8ArmoryCoins:(int)amount;
-(void)unlockFish:(NSString *)fish;
+(GameState *) sharedGameState;

@end
