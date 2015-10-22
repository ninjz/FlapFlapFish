//
//  The8ArmoryStockManager.m
//  FlapFlap Fish
//
//  Created by sh0gun on 3/12/2014.
//  Copyright (c) 2014 Krack Games. All rights reserved.
//

#import "The8ArmoryStockManager.h"
#import "The8Armory.h"

static The8ArmoryStockManager *sharedStockManager_ = nil;

@implementation The8ArmoryStockManager

+(The8ArmoryStockManager *) sharedStockManager
{
    if(!sharedStockManager_)
    {
        sharedStockManager_ = [[The8ArmoryStockManager alloc] init];
    }
    return sharedStockManager_;
}


-(id) init {
    if((self = [super init])){
        [self loadStoreData];
        
        //IAP init so no errors
        _products = [[NSArray alloc] init];
    }
    return self;
}

-(void) loadStoreData
{
    NSMutableDictionary *dictRoot = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"inventory" ofType:@"plist"]];
    
    NSMutableDictionary *skins = [dictRoot objectForKey:@"Skins"];
    
    // Your dictionary contains an array of dictionary
    // Now pull an Array out of it.
    _blowfishSkins = [skins objectForKey:@"Blowfish"];
    _narwhalSkins = [skins objectForKey:@"Narwhal"];
    _piranhaSkins = [skins objectForKey:@"Piranha"];
    _anglerSkins = [skins objectForKey:@"Angler"];
    _zombieSkins = [skins objectForKey:@"Zombie"];
}



-(NSArray *)sortKeys:(NSDictionary *)dict
{
    return [[dict keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        if (obj1 > obj2)
            return (NSComparisonResult)NSOrderedDescending;
        if (obj1 < obj2)
            return (NSComparisonResult)NSOrderedAscending;
        return (NSComparisonResult)NSOrderedSame;
    }] sortedArrayUsingSelector:@selector(compare:)];
}

-(NSString *)getFrameForSkin:(NSDictionary *)skin
{
    return [skin objectForKey:@"initialFrame"];
}

-(NSString *)getFrameForSkinBySID:(NSString *)sID
{
    NSArray *skins = [self getSkinsForCurrChar];
    
    for (NSDictionary *skin in skins) {
        if ([[skin objectForKey:@"sID"] isEqualToString:sID])
        {
            return [skin objectForKey:@"initialFrame"];
        }
    }
    
    return NULL;
}

-(BOOL)isWallyHornlessAtSID:(NSString *)sID
{
    NSArray *skins = [self getSkinsForCurrChar];
    
    for (NSDictionary *skin in skins) {
        if ([[skin objectForKey:@"sID"] isEqualToString:sID])
        {
            return [[skin objectForKey:@"removeHorn"] boolValue];
        }
    }
    
    return NO;
}

-(NSArray *)getSkinsForCurrChar
{
    switch ([[GameState sharedGameState] curSelectedFish]) {
        case 0:
            return _blowfishSkins;
            break;
        case 1:
            return _narwhalSkins;
            break;
        case 2:
            return _piranhaSkins;
            break;
        case 3:
            return _anglerSkins;
            break;
        case 4:
            return _zombieSkins;
            break;
    }
    return NULL;
}

-(NSDictionary *)getSkinAtIndex:(NSUInteger)index
{
    return [[self getSkinsForCurrChar] objectAtIndex:index];
}


-(void)equipSkin:(NSDictionary *)skin
{
    int curFish = [[GameState sharedGameState] curSelectedFish];
    
    NSMutableArray *equippedSkins = [[[GameState sharedGameState] equippedSkin] mutableCopy];
    [equippedSkins setObject:[skin objectForKey:@"sID"] atIndexedSubscript:curFish];
    [[GameState sharedGameState] setEquippedSkin:equippedSkins];
    
    [[GameState sharedGameState] saveState];
    
    [self tryOnSkin:skin];
}

-(void)unequipSkin
{
    int curFish = [[GameState sharedGameState] curSelectedFish];
    
    NSMutableArray *equippedSkins = [[[GameState sharedGameState] equippedSkin] mutableCopy];
    [equippedSkins setObject:@"" atIndexedSubscript:curFish];
    [[GameState sharedGameState] setEquippedSkin:equippedSkins];
    
    [[GameState sharedGameState] saveState];
    
    [[[The8Armory shared8ArmoryScene] fish] takeOffOutfit];
}


-(void)tryOnSkin:(NSDictionary *)skin
{
    if ([[GameState sharedGameState] curSelectedFish] == 1) { // Narwhal needs to check if hornless or not
        [[[The8Armory shared8ArmoryScene] fish] tryOutFit:[self getFrameForSkin:skin]
                                               isHornless:[self isWallyHornlessAtSID:[skin objectForKey:@"sID"]]];
    } else {
        [[[The8Armory shared8ArmoryScene] fish] tryOutFit:[self getFrameForSkin:skin]];
    }
}

-(void)purchaseSkin:(NSDictionary *)skin
{
    [self equipSkin:skin];
    NSMutableArray *owned = [[[GameState sharedGameState] skinsOwned] mutableCopy];
    [owned addObject:[skin objectForKey:@"sID"]];
    [[GameState sharedGameState] setSkinsOwned:owned];
    
    [[GameState sharedGameState] saveState];
    
    [[The8Armory shared8ArmoryScene] purchasedSkin];
    [[The8Armory shared8ArmoryScene] hidePurchaseModal];
    
}




@end
