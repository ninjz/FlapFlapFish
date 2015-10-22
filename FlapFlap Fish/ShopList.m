//
//  ShopList.m
//  FlapFlap Fish
//
//  Created by sh0gun on 3/10/2014.
//  Copyright 2014 Krack Games. All rights reserved.
//

#import "ShopList.h"
#import "The8Armory.h"

#import "The8ArmoryStockManager.h"


@implementation ShopList



- (CCTableViewCell*) tableView:(CCTableView*)tableView nodeForRowAtIndex:(NSUInteger) index
{
    
    // data setup
    NSDictionary *item;
    CCButton *buyButton;
    
    // reference to know which plank to load (there must b a better way)
    NSArray *plankArray = @[@1,@2,@3,@4,@1,@2,@3,@4,@1,@2,@3,@4,@1,@2,@3,@4,@1,@2,@3,@4];
    
    CCTableViewCell *cell = [[CCTableViewCell alloc] init];
    
    
    CCSprite *plank = [CCSprite spriteWithImageNamed:@"Armory-Plank-1.png"];
    plank.scale = 2;
    
    cell.contentSize = CGSizeMake(plank.contentSize.width, plank.contentSize.height);
    
    
    [cell.button setZoomWhenHighlighted:NO];
    [cell.button setExclusiveTouch:NO];
    cell.scale = 2;
    
    
    // buy coins plank
    if (index == 0) {
        [cell.button setBackgroundSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Plank-IAPv2.png"] forState:CCControlStateNormal];
        cell.button.block = ^(id sender){
            if (![[The8Armory shared8ArmoryScene] purchaseActive]) {
//                [[The8ArmoryStockManager sharedStockManager] tryOnSkin:item];
                [[GameState sharedGameState] buttonPressedSound];
            }
        };
        
        buyButton = [[CCButton alloc] initWithTitle:NULL spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-BuyCoins.png"]];
        buyButton.block = ^(id sender){
            if (![[The8Armory shared8ArmoryScene] purchaseActive]) {
                [[GameState sharedGameState] buttonPressedSound];
                [[The8Armory shared8ArmoryScene] displayPurchaseCoinsModal];
            }
        };

        [buyButton setExclusiveTouch:NO];
        [cell addChild:buyButton];
        buyButton.position = ccp(plank.contentSize.width - buyButton.contentSize.width/1.7, plank.contentSize.height/2);
        
        return cell;
    } else {
        [cell.button setBackgroundSpriteFrame:[CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"Armory-Plank-%i.png", [plankArray[index] intValue]]] forState:CCControlStateNormal];
        item = [[The8ArmoryStockManager sharedStockManager] getSkinAtIndex:index - 1];
    }
    
    // buy/equip button
    cell.button.block = ^(id sender){
        if (![[The8Armory shared8ArmoryScene] purchaseActive]) {
            [[The8ArmoryStockManager sharedStockManager] tryOnSkin:item];
            [[GameState sharedGameState] buttonPressedSound];
            
            // UNLOCK ONLY?
            if ([[item objectForKey:@"unlockOnly"] boolValue] && ![self doesCharOwnSkin:item])
            {
                NSString *sID = [item objectForKey:@"sID"];
                if ([sID isEqualToString:@"P010"] || [sID isEqualToString:@"N010"] || [sID isEqualToString:@"C010"] || [sID isEqualToString:@"S010"] ) {
                    [[The8Armory shared8ArmoryScene] displayRateMeModal];
                } else {
                    [[The8Armory shared8ArmoryScene] displayMessageModalWithString:[item objectForKey:@"unlockMessage"]];
                }
            }
        }

    };
    
    
    
    if ([self doesCharOwnSkin:item]) {
        // check if sID of this item is the same as the one equipped by current fish selected
        if ([[item objectForKey:@"sID"] isEqualToString:[[[GameState sharedGameState] equippedSkin]
                                          objectAtIndex:[[GameState sharedGameState] curSelectedFish]]]) {
            buyButton = [[CCButton alloc] initWithTitle:NULL spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Unequip.png"]];
            buyButton.block = ^(id sender){
                if (![[The8Armory shared8ArmoryScene] purchaseActive]) {
                    [[The8ArmoryStockManager sharedStockManager] unequipSkin];
                    [[GameState sharedGameState] buttonPressedSound];
                    [[[The8Armory shared8ArmoryScene] shopTable] reloadData];
                }
                
                
            };
            
            [buyButton setExclusiveTouch:NO];
            
        } else {
            buyButton = [[CCButton alloc] initWithTitle:NULL spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Equip.png"]];
            buyButton.block = ^(id sender){
                if (![[The8Armory shared8ArmoryScene] purchaseActive]) {
                    [[The8ArmoryStockManager sharedStockManager] equipSkin:item];
                    [[GameState sharedGameState] buttonPressedSound];
                    [[[The8Armory shared8ArmoryScene] shopTable] reloadData];
                }
            };
            [buyButton setExclusiveTouch:NO];
        }
        [cell addChild:buyButton];
        buyButton.position = ccp(plank.contentSize.width - buyButton.contentSize.width/1.7, plank.contentSize.height/2);
        
    } else if([[item objectForKey:@"unlockOnly"] boolValue]){ // unlock only so show lock
        CCSprite *lock = [CCSprite spriteWithImageNamed:@"Armory-Lock.png"];
        [cell addChild:lock];
        lock.position = ccp(plank.contentSize.width - lock.contentSize.width*2, plank.contentSize.height/2);
        
        
        
    } else { // char does not own
        buyButton = [[CCButton alloc] initWithTitle:NULL spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Buy.png"]];
        buyButton.block = ^(id sender){
            if (![[The8Armory shared8ArmoryScene] purchaseActive]) {
                
                [[The8Armory shared8ArmoryScene] purchaseSkin:item];
                [[GameState sharedGameState] buttonPressedSound];
                [[[The8Armory shared8ArmoryScene] shopTable] reloadData];
            }
        };
        [buyButton setExclusiveTouch:NO];
        [cell addChild:buyButton];
        buyButton.position = ccp(plank.contentSize.width - buyButton.contentSize.width/1.7, plank.contentSize.height/2);
    }
    
    
    
    
    
    
    // item label
    CCLabelBMFont *itemLabel = [[CCLabelBMFont alloc ] initWithFile:@"krackgames-font.png" capacity:10];
    [itemLabel setFntFile:@"krackgames-font.fnt"];
    [itemLabel setString:[item objectForKey:@"skinName"]];
    itemLabel.positionType = CCPositionTypeNormalized;
    itemLabel.position = ccp(0.1f, 0);
    [cell addChild:itemLabel];
    
    return cell;
}

- (NSUInteger) tableViewNumberOfRows:(CCTableView *)tableView
{
    int curFish = [[GameState sharedGameState] curSelectedFish];
    
    switch (curFish) {
        case 0:
            // + 1 for buy coins plank
            return [[[The8ArmoryStockManager sharedStockManager] blowfishSkins] count] + 1;
            break;
        case 1:
            return [[[The8ArmoryStockManager sharedStockManager] narwhalSkins] count] + 1;
            break;
        case 2:
            return [[[The8ArmoryStockManager sharedStockManager] piranhaSkins] count] + 1;
            break;
        case 3:
            return [[[The8ArmoryStockManager sharedStockManager] anglerSkins] count] + 1;
            break;
        case 4:
            return [[[The8ArmoryStockManager sharedStockManager] zombieSkins] count] + 1;
            break;
    }
    return 0;
}


-(BOOL)doesCharOwnSkin:(NSDictionary *)skin
{
    return [[[GameState sharedGameState] skinsOwned] containsObject:[skin objectForKey:@"sID"]];
}



@end
