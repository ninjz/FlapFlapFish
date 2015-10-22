//
//
//  FlapFlap Fish
//
//  Created by sh0gun on 3/12/2014.
//  Copyright (c) 2014 Krack Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface The8ArmoryStockManager : NSObject


@property(nonatomic, retain) NSMutableArray *blowfishSkins;
@property(nonatomic, retain) NSMutableArray *narwhalSkins;
@property(nonatomic, retain) NSMutableArray *piranhaSkins;
@property(nonatomic, retain) NSMutableArray *zombieSkins;
@property(nonatomic, retain) NSMutableArray *anglerSkins;

@property(nonatomic, retain) NSArray *products; // IAP


+(The8ArmoryStockManager *) sharedStockManager;
-(NSString *)getFrameForSkin:(NSDictionary *)skin;
-(NSArray *)getSkinsForCurrChar;
-(NSString *)getFrameForSkinBySID:(NSString *)sID;
-(BOOL)isWallyHornlessAtSID:(NSString *)sID;

-(NSDictionary *)getSkinAtIndex:(NSUInteger)index;
-(void)equipSkin:(NSDictionary *)skin;
-(void)unequipSkin;
-(void)tryOnSkin:(NSDictionary *)skin;
-(void)purchaseSkin:(NSDictionary *)skin;

@end
