//
//  GameState.m
//  floppyFish
//
//  Created by sh0gun on 2/16/2014.
//  Copyright (c) 2014 JAC studios. All rights reserved.
//

#import "GameState.h"
#import "cocos2d.h"
#import "SDCloudUserDefaults.h"
#import "OALSimpleAudio.h"

static GameState *sharedGameState_ = nil;

@implementation GameState

+(GameState *) sharedGameState
{
    if(!sharedGameState_)
    {
        sharedGameState_ = [[GameState alloc] init];
    }
    return sharedGameState_;
}

-(id) init {
    if((self = [super init])){
        [self loadSavedState];
    }
    return self;
}

-(void) loadSavedState
{
    
    _playCount = [SDCloudUserDefaults integerForKey:kGameStatePlayCount];
    _curSelectedFish = [SDCloudUserDefaults integerForKey:kGameStatecurSelectedFish];
    _soundON = [SDCloudUserDefaults boolForKey:kGameStateSoundOn];
    _adsRemoved = [SDCloudUserDefaults boolForKey:kGameStateAdsRemoved];
    _highScore = [[NSMutableArray alloc] initWithArray:[SDCloudUserDefaults objectForKey: kGameStateHighScore]];
    _deaths = [SDCloudUserDefaults integerForKey:kGameStateDeaths];
    _unlockedFishes = [[NSMutableDictionary alloc] initWithDictionary:[SDCloudUserDefaults objectForKey:kGameStateUnlockedFishes]];
    _currencyCollected = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey: kGameStateCurrencyCollected]];
    
    // v1.5
    _skinsOwned = [[NSMutableArray alloc] initWithArray:[SDCloudUserDefaults objectForKey:kGameStateSkinsOwned]];
    _equippedSkin = [[NSMutableArray alloc] initWithArray:[SDCloudUserDefaults objectForKey:kGameStateCurSkinEquipped]];
    _amount8coin = [[NSUserDefaults standardUserDefaults] integerForKey:kGameState8coin];
    _rated = [SDCloudUserDefaults boolForKey:kGameStateRated];
    _fbLiked = [SDCloudUserDefaults boolForKey:kGameStateFbLiked];
    _currentVersion = [SDCloudUserDefaults integerForKey:kGameStateCurrentVersion];
}


-(void) saveState
{
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [SDCloudUserDefaults setInteger:_playCount forKey:kGameStatePlayCount];
    [SDCloudUserDefaults setBool:_soundON forKey:kGameStateSoundOn];
    [SDCloudUserDefaults setBool:_adsRemoved forKey:kGameStateAdsRemoved];
    [SDCloudUserDefaults setObject:_highScore forKey:kGameStateHighScore];
    [[NSUserDefaults standardUserDefaults] setInteger:_curSelectedFish forKey:kGameStatecurSelectedFish];
    [SDCloudUserDefaults setInteger:_deaths forKey:kGameStateDeaths];
    [SDCloudUserDefaults setObject:_unlockedFishes forKey:kGameStateUnlockedFishes];
    [SDCloudUserDefaults setObject:_currencyCollected forKey:kGameStateCurrencyCollected];
    
    // v1.5
    [SDCloudUserDefaults setObject:_skinsOwned forKey:kGameStateSkinsOwned];
    [SDCloudUserDefaults setObject:_equippedSkin forKey:kGameStateCurSkinEquipped];
    [[NSUserDefaults standardUserDefaults] setInteger:_amount8coin forKey:kGameState8coin];
    [SDCloudUserDefaults setBool:_rated forKey:kGameStateRated];
    [SDCloudUserDefaults setBool:_fbLiked forKey:kGameStateFbLiked];
    [SDCloudUserDefaults setInteger:_currentVersion forKey:kGameStateCurrentVersion];
    
    [SDCloudUserDefaults synchronize];
}


-(NSArray *) getCurrencyForCurrFish
{
    switch (_curSelectedFish) {
        case 0:
            return [_currencyCollected objectForKey:@"Blowfish"];
            break;
        case 1:
            return [_currencyCollected objectForKey:@"Narwhal"];
            break;
        case 2:
            return [_currencyCollected objectForKey:@"Piranha"];
            break;
        case 3:
            return [_currencyCollected objectForKey:@"Angler"];
            break;
        case 4:
            return [_currencyCollected objectForKey:@"Zombie"];
            break;
            
        default:
            break;
    }
    return NULL;
}

-(NSString *) curFishString
{
    switch (_curSelectedFish) {
        case 0:
            return @"Blowfish";
            break;
        case 1:
            return @"Narwhal";
            break;
        case 2:
            return @"Piranha";
            break;
        case 3:
            return @"Angler";
            break;
        case 4:
            return @"Zombie";
            break;
            
        default:
            break;
    }
    return NULL;
}

-(NSString *)getCoinForCurrFish:(CoinType)coinType
{
    switch (_curSelectedFish) {
        case 0: // blowfish
            
            switch (coinType) {
                case CoinTypeBronze:
                    return @"Coin-Puffer-1.png";
                    break;
                    
                case CoinTypeSilver:
                    return @"Coin-Puffer-2.png";
                    break;
                case CoinTypeGold:
                    return @"Coin-Puffer-3.png";
                    break;
                case CoinType8coin:
                    break;
            }
        case 1:    // narwhal
            switch (coinType) {
                case CoinTypeBronze:
                    return @"Coin-Narwhal-1.png";
                    break;
                    
                case CoinTypeSilver:
                    return @"Coin-Narwhal-2.png";
                    break;
                case CoinTypeGold:
                    return @"Coin-Narwhal-3.png";
                    break;
                case CoinType8coin:
                    break;
            }
        case 2: // piranha
            switch (coinType) {
                case CoinTypeBronze:
                    return @"Coin-Piranha-1.png";
                    break;
                    
                case CoinTypeSilver:
                    return @"Coin-Piranha-2.png";
                    break;
                case CoinTypeGold:
                    return @"Coin-Piranha-3.png";
                    break;
                case CoinType8coin:
                    break;
            }
        case 3: // angler
            switch (coinType) {
                case CoinTypeBronze:
                    return @"Coin-Angler-1.png";
                    break;
                    
                case CoinTypeSilver:
                    return @"Coin-Angler-2.png";
                    break;
                case CoinTypeGold:
                    return @"Coin-Angler-3.png";
                    break;
                case CoinType8coin:
                    break;
            }
        case 4: // skully
            switch (coinType) {
                case CoinTypeBronze:
                    return @"Coin-Skelly-1.png";
                    break;
                    
                case CoinTypeSilver:
                    return @"Coin-Skelly-2.png";
                    break;
                case CoinTypeGold:
                    return @"Coin-Skelly-3.png";
                    break;
                case CoinType8coin:
                    break;
            }
            
    }
    return NULL;
}

-(void) debitAmount:(NSNumber *)amount
               from:(CoinType)coinType
{
    NSMutableDictionary *wallet;
    NSMutableArray *cash;
    int inPocket;
    int debit;
    
    wallet = [_currencyCollected mutableCopy];
    
    switch (coinType) {
        case CoinTypeBronze:
            cash = [[wallet objectForKey:[self curFishString]] mutableCopy];
            inPocket = [[cash objectAtIndex:0] intValue];
            debit = inPocket - [amount intValue];
            [cash setObject:[NSNumber numberWithInt:debit] atIndexedSubscript:0];
            [wallet setObject:cash forKey:[self curFishString]];
            [[GameState sharedGameState] setCurrencyCollected:wallet];
            break;
        case CoinTypeSilver:
            cash = [[wallet objectForKey:[self curFishString]] mutableCopy];
            inPocket = [[cash objectAtIndex:1] intValue];
            debit = inPocket - [amount intValue];
            [cash setObject:[NSNumber numberWithInt:debit] atIndexedSubscript:1];
            [wallet setObject:cash forKey:[self curFishString]];
            [[GameState sharedGameState] setCurrencyCollected:wallet];
            break;
            
        case CoinTypeGold:
            cash = [[wallet objectForKey:[self curFishString]] mutableCopy] ;
            inPocket = [[cash objectAtIndex:2] intValue];
            debit = inPocket - [amount intValue];
            [cash setObject:[NSNumber numberWithInt:debit] atIndexedSubscript:2];
            [wallet setObject:cash forKey:[self curFishString]];
            [[GameState sharedGameState] setCurrencyCollected:wallet];
            break;
        case CoinType8coin:
            inPocket = _amount8coin;
            debit = inPocket - [amount intValue];
            [[GameState sharedGameState] setAmount8coin:debit];
            break;
        default:
            break;
    }
    
    [[GameState sharedGameState] saveState];
    
}

-(void) credit8ArmoryCoins:(int)amount
{
    int amountInWallet = _amount8coin;
    amountInWallet += amount;
    
    [[GameState sharedGameState] setAmount8coin:amountInWallet];
    [[GameState sharedGameState] saveState];
}



-(void)unlockFish:(NSString *)fish
{
    NSMutableDictionary * unlocked = [_unlockedFishes mutableCopy];
    
    
    if ([unlocked objectForKey:fish]) {
        [unlocked setObject:[NSNumber numberWithBool:YES] forKey:fish];
        [[GameState sharedGameState] setUnlockedFishes:unlocked];
        [self saveState];
    } else {
        CCLOG(@"must have fucked up the naming or smthing @unlockFish");
    }
}


-(void)buttonPressedSound
{
    [[OALSimpleAudio sharedInstance] playEffect:@"newsfx1.wav" volume:0.5 pitch:1 pan:0 loop:NO];
}



@end
