//
//  The8Armory.m
//  FlapFlap Fish
//
//  Created by sh0gun on 3/10/2014.
//  Copyright 2014 Krack Games. All rights reserved.
//
#import "CCAnimation+Helper.h"
#import "CCNode+Scaling.h"
#import "The8Armory.h"
#import "OctoBoss.h"
#import "The8ArmoryStockManager.h"
#import "ShopList.h"

#import "Angler.h"
#import "Narwhal.h"
#import "Blowfish.h"
#import "Angler.h"
#import "Piranha.h"
#import "Skelly.h"
#import "MenuScene.h"
#import "FFFModalView.h"

//IAP
#import "FFFishIAPHelper.h"
#import <StoreKit/StoreKit.h>


@implementation The8Armory{
    CGSize winSize;
    OctoBoss *octoBoss;
    
    CCActionRepeatForever *_fishIdle;
    BOOL fishIdle;
    
    CCLabelBMFont *bronzeLabel;
    CCLabelBMFont *silverLabel;
    CCLabelBMFont *goldLabel;
    CCLabelBMFont *_8coinLabel;
    
    CCNodeColor *pauseTint;
    CCSprite *speechBubble;
    CCButton *_8coinButton, *coinButton;
    CCLabelBMFont *coinPrice;
    CCLabelBMFont *_8coinPrice;
    
    CCButton *cancelButton;
    CCButton *yesButton;
    CCButton *noButton;
    CCButton *okButton;
    CCLabelBMFont *confirmText;
    
    // purchase coins modal
    CCButton *buy5coins, *buy15coins, *buy30coins;
    
    // IAP
    NSArray *_products;
    
    //wallet
    int bronze;
    int silver;
    int gold;
    int _8coin;
    
    BOOL didPurchaseSomething;
}

static The8Armory *shared8ArmoryScene;

+ (The8Armory *) shared8ArmoryScene{
    NSAssert(shared8ArmoryScene != nil, @"instance not yet initialized");
    return shared8ArmoryScene;
}
+ (The8Armory *) scene{
    return [[self alloc] init];
}

-(id)init
{
    if(self = [super init]){
        shared8ArmoryScene = self;
        _purchaseActive = NO;
        didPurchaseSomething = NO;
        
        // IAP $$$$$$$
        [[FFFishIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success) {
                _products = products;
            }
        }];
        
        winSize = [[CCDirector sharedDirector] viewSize];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"8armory.plist"];
        
        //initialize scene assets
        [self setupScene];
        [self fillWallet];
        [self setupShopTable];
        
    }
    return self;
}

-(void)setupShopTable
{
    // setup shop Table View
    CCSprite *plank = [CCSprite spriteWithImageNamed:@"Armory-Plank-1.png"];       // for size ref.
    
    
    CCSprite *frame = [CCSprite spriteWithImageNamed:@"Armory-Frame.png"];
    frame.scale = 2;
    frame.anchorPoint = ccp(0.5f,0.5f);
    frame.position = (IS_IPAD_AD) ? ccp(winSize.width/2, winSize.height*4.2/6) : ccp(winSize.width/2, winSize.height*4/6);
    [self addChild:frame z:4];
    
    CCSprite *frameBg = [CCSprite spriteWithImageNamed:@"Armory-PlankBackground.png"];
    frameBg.scale = 2;
    frameBg.anchorPoint = ccp(0.5f,0.5f);
    frameBg.position = frame.position;
    [self addChild:frameBg z:3];
    
    
    _shopTable = [[CCTableView alloc] init];
    _shopTable.bounces = NO;
    _shopTable.contentSizeType = CCSizeTypeMake(CCSizeUnitPoints, CCSizeUnitPoints);
    _shopTable.contentSize = CGSizeMake(plank.contentSize.width*2, plank.contentSize.height*2.1*4); //480
    _shopTable.rowHeight = plank.contentSize.height*2.1;  //2.1
    _shopTable.scale = 0.5;
    _shopTable.dataSource = [[ShopList alloc]init];
    
    
    _shopTable.positionType = CCPositionTypeNormalized;
    _shopTable.anchorPoint = ccp(0.5f, 0.5f);
    [frameBg addChild:_shopTable];
    _shopTable.position = (IS_IPAD_AD) ? ccp(0.503f, 0.363f) : ccp(0.503f, 0.363f);
    [frameBg setOpacity:0];
}

-(void)setupScene
{
    // BACKGROUND FARTHEST BACK
    CCAnimation *bgAnim;
    CCActionAnimate *bgFlicker;
    CCSprite *farBack, *bg, *ground;
    CCPhysicsNode *physicsWorld;
    
    
    
    
    // Set background image
    farBack = [CCSprite spriteWithImageNamed:@"Background-1.png"];
    [self addChild:farBack];
    [farBack scaleToSize:winSize fitType:CCScaleFitAspectFill];
    [farBack setPosition:ccp(winSize.width/2, winSize.height/2)];
    
    bgAnim = [CCAnimation animationWithFrame:@"Background-"
                                  frameCount:2
                                       delay:0.8f];
    
    bgFlicker = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:bgAnim]];
    [farBack runAction:bgFlicker];
    
    bg = [CCSprite spriteWithImageNamed:@"Midground-1.png"];
    
    [self addChild:bg];
    [bg scaleToSize:winSize fitType:CCScaleFitAspectFit];
    [bg setPosition:ccp(winSize.width/2, winSize.height/4)];
    
    
    
    
    
    // set ground image
    ground = [CCSprite spriteWithImageNamed:@"Armory-Cave.png"];
    
    [self addChild:ground z:2];
    [ground scaleToSize:winSize fitType:CCScaleFitAspectFit];
    [ground setPosition:(IS_IPAD_AD) ? ccp(winSize.width/2, ground.contentSize.height * 1.4) : ccp(winSize.width/2, ground.contentSize.height * 1.1)];
    
    
    octoBoss = [OctoBoss node];
    [octoBoss setPosition:(IS_IPAD_AD) ? ccp(winSize.width - octoBoss.contentSize.width , ground.contentSize.height * 1.25) : ccp(winSize.width - octoBoss.contentSize.width , ground.contentSize.height * 0.9f)];
    
    [self addChild:octoBoss z:5];
    
    
    physicsWorld = [CCPhysicsNode node];
    [self addChild:physicsWorld z:5];
    
    // initialize current _fish that is selected.
    int cur_fish = [[GameState sharedGameState] curSelectedFish];
    switch (cur_fish) {
        case 0: // main _fish
            _fish = [[BlowFish alloc] init];
            [(BlowFish *)_fish idle];
            
            break;
        case 1: // narwhal
            _fish = [[Narwhal alloc] init];
            break;
        case 2:
            _fish = [[Piranha alloc] init];
            break;
            
        case 3: //angler
            _fish = [[Angler alloc] init];
            break;
        case 4:
            _fish = [[Skelly alloc] init];
            break;
    }
    
    
    _fish.position = ccp(-_fish.contentSize.width, octoBoss.position.y);
  
    [physicsWorld addChild:_fish];
    
    fishIdle = NO;
    
    
    CCButton *menuButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Menu.png"]];
    menuButton.scale = 2;
    [menuButton setPosition:(IS_IPAD_AD) ? ccp(winSize.width - menuButton.contentSize.width*1.5, winSize.height):
     ccp(winSize.width - menuButton.contentSize.width*1.5, winSize.height - menuButton.contentSize.height*1.5)];
    [menuButton setTarget:self selector:@selector(backToMenu)];
    [self addChild:menuButton];
}

-(void)backToMenu
{
    if (didPurchaseSomething) {
        [[CCDirector sharedDirector] replaceScene:[MenuScene scene]
                                   withTransition:[CCTransition transitionFadeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f] duration:0.8f]];
    } else {
        [octoBoss rage];
        [self runAction:[CCActionSequence actionOne:[CCActionDelay actionWithDuration:1.5f] two:[CCActionCallBlock actionWithBlock:^{
            [[CCDirector sharedDirector] replaceScene:[MenuScene scene]
                                       withTransition:[CCTransition transitionFadeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f] duration:0.8f]];
        }]]];
    }
}

-(void)fillWallet
{
    NSArray *medals = [[GameState sharedGameState] getCurrencyForCurrFish];
    
    _8coin = [[GameState sharedGameState] amount8coin];
    bronze = [[medals objectAtIndex:0] intValue];
    silver = [[medals objectAtIndex:1] intValue];
    gold = [[medals objectAtIndex:2] intValue];
    
    if ([[self children] containsObject:bronzeLabel]) {
        [self removeChild:bronzeLabel cleanup:YES];
    }
    if ([[self children] containsObject:silverLabel]) {
        [self removeChild:silverLabel cleanup:YES];
    }
    if ([[self children] containsObject:goldLabel]) {
        [self removeChild:goldLabel cleanup:YES];
    }
    if ([[self children] containsObject:_8coinLabel]) {
        [self removeChild:_8coinLabel cleanup:YES];
    }
    
    // currency display
    CCSprite *bronzeCoin, *silverCoin, *goldCoin, *_8coinDisplay;
    
    bronzeCoin = [CCSprite spriteWithImageNamed:[[GameState sharedGameState] getCoinForCurrFish:CoinTypeBronze]];
    silverCoin = [CCSprite spriteWithImageNamed:[[GameState sharedGameState] getCoinForCurrFish:CoinTypeSilver]];
    goldCoin = [CCSprite spriteWithImageNamed:[[GameState sharedGameState] getCoinForCurrFish:CoinTypeGold]];
    _8coinDisplay = [CCSprite spriteWithImageNamed:@"Coin-8-Armory.png"];
    
    [bronzeCoin setAnchorPoint:ccp(0.5f,0.5f)];
    [silverCoin setAnchorPoint:ccp(0.5f,0.5f)];
    [goldCoin setAnchorPoint:ccp(0.5f,0.5f)];
    [_8coinDisplay setAnchorPoint:ccp(0.5f,0.5f)];
    
    [bronzeCoin setPosition:(IS_IPAD_AD) ? ccp(bronzeCoin.contentSize.height, winSize.height): ccp(bronzeCoin.contentSize.height,winSize.height - bronzeCoin.contentSize.height)];
    [silverCoin setPosition:(IS_IPAD_AD) ? ccp(bronzeCoin.position.x + bronzeCoin.contentSize.height * 2, winSize.height): ccp(bronzeCoin.position.x + bronzeCoin.contentSize.height * 2,winSize.height - bronzeCoin.contentSize.height)];
    [goldCoin setPosition:(IS_IPAD_AD) ? ccp(silverCoin.position.x + bronzeCoin.contentSize.height * 2,winSize.height) : ccp(silverCoin.position.x + bronzeCoin.contentSize.height * 2,winSize.height - bronzeCoin.contentSize.height)];
    [_8coinDisplay setPosition:(IS_IPAD_AD) ? ccp(goldCoin.position.x + bronzeCoin.contentSize.height * 2,winSize.height) : ccp(goldCoin.position.x + bronzeCoin.contentSize.height * 2,winSize.height - bronzeCoin.contentSize.height)];
    
    [self addChild:bronzeCoin z:10];
    [self addChild:silverCoin z:10];
    [self addChild:goldCoin z:10];
    [self addChild:_8coinDisplay z:10];
   
    //display the coin counts
    bronzeLabel = [[CCLabelBMFont alloc ] initWithFile:@"font.png" capacity:2];
    [bronzeLabel setFntFile:@"font.fnt"];
    [bronzeLabel setString:[NSString stringWithFormat:@"%i",bronze]];
    [self addChild:bronzeLabel z:10];
    [bronzeLabel setScale:2];
    [bronzeLabel setAnchorPoint:ccp(0.5f, 0.5f)];
    [bronzeLabel setAlignment:CCTextAlignmentCenter];
    [bronzeLabel setPosition:(IS_IPAD_AD) ?  ccp(bronzeCoin.position.x,winSize.height - bronzeCoin.contentSize.height) : ccp(bronzeCoin.position.x,winSize.height - bronzeCoin.contentSize.height * 2)];
    
    silverLabel = [[CCLabelBMFont alloc ] initWithFile:@"font.png" capacity:2];
    [silverLabel setFntFile:@"font.fnt"];
    [silverLabel setString:[NSString stringWithFormat:@"%i",silver]];
    [self addChild:silverLabel z:10];
    [silverLabel setScale:2];
    [silverLabel setAnchorPoint:ccp(0.5f, 0.5f)];
    [silverLabel setAlignment:CCTextAlignmentCenter];
    [silverLabel setPosition:(IS_IPAD_AD) ?  ccp(silverCoin.position.x, winSize.height - bronzeCoin.contentSize.height) : ccp(silverCoin.position.x, winSize.height - bronzeCoin.contentSize.height * 2)];
    
    goldLabel = [[CCLabelBMFont alloc ] initWithFile:@"font.png" capacity:2];
    [goldLabel setFntFile:@"font.fnt"];
    [goldLabel setString:[NSString stringWithFormat:@"%i",gold]];
    
    [self addChild:goldLabel z:10];
    [goldLabel setScale:2];
    [goldLabel setAnchorPoint:ccp(0.5f, 0.5f)];
    [goldLabel setAlignment:CCTextAlignmentCenter];
    [goldLabel setPosition:(IS_IPAD_AD) ? ccp(goldCoin.position.x, winSize.height - bronzeCoin.contentSize.height): ccp(goldCoin.position.x, winSize.height - bronzeCoin.contentSize.height * 2)];
    
    _8coinLabel = [[CCLabelBMFont alloc ] initWithFile:@"font.png" capacity:2];
    [_8coinLabel setFntFile:@"font.fnt"];
    [_8coinLabel setString:[NSString stringWithFormat:@"%i",_8coin]];
    
    [self addChild:_8coinLabel z:10];
    [_8coinLabel setScale:2];
    [_8coinLabel setAnchorPoint:ccp(0.5f, 0.5f)];
    [_8coinLabel setAlignment:CCTextAlignmentCenter];
    [_8coinLabel setPosition:(IS_IPAD_AD) ? ccp(_8coinDisplay.position.x, winSize.height - bronzeCoin.contentSize.height) : ccp(_8coinDisplay.position.x, winSize.height - bronzeCoin.contentSize.height * 2)];
}


-(void)onEnter
{
    [super onEnter];
    
    [_fish runAction:[CCActionSequence actionOne:[CCActionMoveTo actionWithDuration:1.5f position:ccp(winSize.width/4, octoBoss.position.y)] two:[CCActionCallBlock actionWithBlock:^{
        fishIdle = YES;
    }] ]];
    
}


-(void)purchasedSkin
{
    didPurchaseSomething = YES;
}

//- (void) selectedRow:(NSUInteger)sender
//{
//    // buy coins is at index 0
////    if (sender == 0) {
////        [[GameState sharedGameState] buttonPressedSound];
////    } else {
////        NSDictionary *skin = [[The8ArmoryStockManager sharedStockManager] getSkinAtIndex:sender];
////        [_fish tryOutFit:[[The8ArmoryStockManager sharedStockManager] getFrameForSkin:skin]];
////        [[GameState sharedGameState] buttonPressedSound];
////        
////        
////        NSLog(@"%i" , [[skin objectForKey:@"unlockOnly"] intValue]);
////        NSLog(@"%@" , [skin objectForKey:@"skinName"] );
////        // if the skin is unlock only and char does not own the skin.
////        if ([[skin objectForKey:@"unlockOnly"] boolValue] )
////        {
////            [self displayMessageModalWithString:[skin objectForKey:@"unlockMessage"]];
////        }
////    }
//    CCLOG(@"HI");
//}

-(void)purchaseSkin:(NSDictionary *)skin
{
    [self displayPurchaseModal];
    
    [[The8ArmoryStockManager sharedStockManager] tryOnSkin:skin];
    
    coinPrice = [[CCLabelBMFont alloc ] initWithFile:@"Font-File-Armory.png" capacity:2];
    [coinPrice setFntFile:@"Font-File-Armory.fnt"];
    [speechBubble addChild:coinPrice z:10];
    [coinPrice setScale:2];
    [coinPrice setAnchorPoint:ccp(0.5f, 0.5f)];
    [coinPrice setAlignment:CCTextAlignmentCenter];
    
    _8coinPrice = [[CCLabelBMFont alloc ] initWithFile:@"Font-File-Armory.png" capacity:2];
    [_8coinPrice setFntFile:@"Font-File-Armory.fnt"];
    [speechBubble addChild:_8coinPrice z:10];
    [_8coinPrice setScale:2];
    [_8coinPrice setAnchorPoint:ccp(0.5f, 0.5f)];
    [_8coinPrice setAlignment:CCTextAlignmentCenter];
    
    
    
    _8coinButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Coin-8-Armory.png"]];
    [speechBubble addChild:_8coinButton z:8];
    cancelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Cancel.png"]];
    [speechBubble addChild:cancelButton];
    
    _8coinButton.block = ^(id sender){
        [[The8Armory shared8ArmoryScene] coinConfirm:CoinType8coin
                                              amount:[skin objectForKey:@"8coin"]
                                                skin:skin];
    };
    
    [_8coinPrice setString:[NSString stringWithFormat:@"%i",[[skin objectForKey:@"8coin"] intValue]]];
    
    // get medal type for skin:
    NSArray *prices = @[[skin objectForKey:@"bronze"], [skin objectForKey:@"silver"], [skin objectForKey:@"gold"]];
    
    BOOL hasCoinPrice = NO;
    //which one has something??
    for (int i = 0; i < [prices count]; i++) {
        if ([[prices objectAtIndex:i] intValue] != 0) {
            switch (i) {
                case 0:
                {
                    coinButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:[[GameState sharedGameState] getCoinForCurrFish:CoinTypeBronze]]];
                    [speechBubble addChild:coinButton z:8];
                    coinButton.block = ^(id sender){
                       [[The8Armory shared8ArmoryScene] coinConfirm:CoinTypeBronze
                                                             amount:[prices objectAtIndex:0]
                                                               skin:skin];
                    };
                    [coinPrice setString:[NSString stringWithFormat:@"%i",[[prices objectAtIndex:0] intValue]]];
                }
                    break;
                case 1:
                {
                    coinButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:[[GameState sharedGameState] getCoinForCurrFish:CoinTypeSilver]]];
                    [speechBubble addChild:coinButton z:8];
                    coinButton.block = ^(id sender){
                        [[The8Armory shared8ArmoryScene] coinConfirm:CoinTypeSilver
                                                              amount:[prices objectAtIndex:1]
                                                                skin:skin];
                    };
                    [coinPrice setString:[NSString stringWithFormat:@"%i",[[prices objectAtIndex:1] intValue]]];
                }
                    
                    break;
                case 2:
                {
                    coinButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:[[GameState sharedGameState] getCoinForCurrFish:CoinTypeGold]]];
                    [speechBubble addChild:coinButton z:8];
                    coinButton.block = ^(id sender){
                        [[The8Armory shared8ArmoryScene] coinConfirm:CoinTypeGold
                                                              amount:[prices objectAtIndex:2]
                                                                skin:skin];
                    };
                    [coinPrice setString:[NSString stringWithFormat:@"%i",[[prices objectAtIndex:2] intValue]]];
                }
                    break;
                default:
                    break;
            }
            hasCoinPrice = YES;
        }
    }
    
    [_8coinButton setAnchorPoint:ccp(0.5f,0.5f)];
    [coinButton setAnchorPoint:ccp(0.5f,0.5f)];
    [cancelButton setAnchorPoint:ccp(0.5f,0.5f)];
    
    if (hasCoinPrice) {
        [_8coinButton setPosition:ccp(speechBubble.contentSize.width*3/4, speechBubble.contentSize.height*2/3)];
        [_8coinPrice setPosition:ccp(speechBubble.contentSize.width*3/4, speechBubble.contentSize.height/2.3)];
        
        [coinButton setPosition:ccp(speechBubble.contentSize.width/4, speechBubble.contentSize.height*2/3)];
        [coinPrice setPosition:ccp(speechBubble.contentSize.width/4, speechBubble.contentSize.height/2.3)];
    } else {
        [speechBubble setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Bubble-2.png"]];
        [_8coinButton setPosition:ccp(speechBubble.contentSize.width/2, speechBubble.contentSize.height*2/3)];
        [_8coinPrice setPosition:ccp(speechBubble.contentSize.width/2, speechBubble.contentSize.height/2.3)];
    }
    
    
    
    [cancelButton setPosition:ccp(speechBubble.contentSize.width/2, speechBubble.contentSize.height/2.8)];
    
    [cancelButton setTarget:self selector:@selector(hidePurchaseModal)];
    
    [_8coinButton setCascadeOpacityEnabled:YES];
    [coinButton setCascadeOpacityEnabled:YES];
    [cancelButton setCascadeOpacityEnabled:YES];
}

-(void) coinConfirm:(CoinType)coinType
             amount:(NSNumber *)amount
               skin:(NSDictionary *)skin
{
    [_8coinButton setVisible:NO];
    [coinButton setVisible:NO];
    [cancelButton setVisible:NO];
    [coinPrice setVisible:NO];
    [_8coinPrice setVisible:NO];
    
    [speechBubble setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Bubble-2.png"]];
    
    // confirmation text
    confirmText = [[CCLabelBMFont alloc] initWithFile:@"Font-File-Armory.png" capacity:10];
    [confirmText setFntFile:@"Font-File-Armory.fnt"];
    confirmText.anchorPoint = ccp(0.5f,0.5f);
    [confirmText setPosition:ccp(speechBubble.contentSize.width/2, speechBubble.contentSize.height/1.8)];
    [confirmText setCascadeOpacityEnabled:YES];
    [speechBubble addChild:confirmText z:5];
    
    yesButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Yes.png"]];
    [speechBubble addChild:yesButton z:5];
    yesButton.anchorPoint = ccp(0.5f, 0.5f);
    yesButton.position = ccp(speechBubble.contentSize.width*2/3, speechBubble.contentSize.height/2.8);
    yesButton.cascadeOpacityEnabled = YES;
    
    noButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-No.png"]];
    [speechBubble addChild:noButton z:5];
    noButton.anchorPoint = ccp(0.5f, 0.5f);
    noButton.position = ccp(speechBubble.contentSize.width/3, speechBubble.contentSize.height/2.8);
    noButton.cascadeOpacityEnabled = YES;
    
    okButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Ok.png"]];
    [speechBubble addChild:okButton z:5];
    okButton.anchorPoint = ccp(0.5f, 0.5f);
    okButton.position = ccp(speechBubble.contentSize.width/2, speechBubble.contentSize.height/2.8);
    okButton.cascadeOpacityEnabled = YES;
    
    [yesButton setVisible:NO];
    [noButton setVisible:NO];
    [okButton setVisible:NO];
    
   
    
    // confirm button
    switch (coinType) {
        case CoinTypeBronze:
            if(bronze - [amount intValue] >= 0){
                [confirmText setString:@"You sure about that?"];
                [yesButton setVisible:YES];
                [noButton setVisible:YES];
                
                yesButton.block = ^(id sender){
                    [[GameState sharedGameState] debitAmount:amount from:CoinTypeBronze];
                     [[The8ArmoryStockManager sharedStockManager] purchaseSkin:skin];
                };
            } else {
                [octoBoss rage];
                [confirmText setString:@"Not enough money!"];
                [okButton setVisible:YES];
            }
            break;
        case CoinTypeSilver:
            if(silver - [amount intValue] >= 0){
                 [confirmText setString:@"You sure about that?"];
                [yesButton setVisible:YES];
                [noButton setVisible:YES];
                yesButton.block = ^(id sender){
                    [[GameState sharedGameState] debitAmount:amount from:CoinTypeSilver];
                    [[The8ArmoryStockManager sharedStockManager] purchaseSkin:skin];
                };
                
            } else {
                [octoBoss rage];
                [confirmText setString:@"Not enough money!"];
                [okButton setVisible:YES];
                
            }
            break;
        case CoinTypeGold:
            if(gold - [amount intValue] >= 0){
                 [confirmText setString:@"You sure about that?"];
                [yesButton setVisible:YES];
                [noButton setVisible:YES];
                yesButton.block = ^(id sender){
                    [[GameState sharedGameState] debitAmount:amount from:CoinTypeGold];
                    [[The8ArmoryStockManager sharedStockManager] purchaseSkin:skin];
                };
                
            } else {
                [octoBoss rage];
                [confirmText setString:@"Not enough money!"];
                [okButton setVisible:YES];
            }
            break;
        case CoinType8coin:
            if(_8coin - [amount intValue] >= 0){
                 [confirmText setString:@"You sure about that?"];
                [yesButton setVisible:YES];
                [noButton setVisible:YES];
                yesButton.block = ^(id sender){
                    [[GameState sharedGameState] debitAmount:amount from:CoinType8coin];
                    [[The8ArmoryStockManager sharedStockManager] purchaseSkin:skin];
                    
                };
                
                
            } else {
                [octoBoss rage];
                [confirmText setString:@"Not enough money!"];
                [okButton setVisible:YES];
            }
            break;
            
        default:
            break;
    }
    
    [noButton setTarget:self selector:@selector(hidePurchaseModal)];
    [okButton setTarget:self selector:@selector(hidePurchaseModal)];
    
}


-(void)displayPurchaseModal
{
    [octoBoss talk];
    // tint scene
    pauseTint = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.7f]];
    [self addChild:pauseTint z:4];
    
    // turn off interactions (make sure to turn them back on
    _purchaseActive = YES;
    _shopTable.verticalScrollEnabled = NO;
    
    // display bubble
    speechBubble = [CCSprite spriteWithImageNamed:@"Armory-Bubble-1.png"];
    speechBubble.scale = 0;
    speechBubble.positionType = CCPositionTypeNormalized;
    speechBubble.position = ccp(0.5f,0.5f);
    [self addChild:speechBubble z:5];
    [speechBubble runAction:[CCActionScaleTo actionWithDuration:0.3f scale:2]];
}

-(void)hidePurchaseModal
{
    [octoBoss idle];
    // refresh wallet count
    [self fillWallet];
    
    // update the buttons
    [_shopTable reloadData];
    
    // hide all the stuff on the speechBubble
    [coinButton runAction:[CCActionFadeOut actionWithDuration:1]];
    [_8coinButton runAction:[CCActionFadeOut actionWithDuration:1]];
    [cancelButton runAction:[CCActionFadeOut actionWithDuration:1]];
    [yesButton runAction:[CCActionFadeOut actionWithDuration:1]];
    [noButton runAction:[CCActionFadeOut actionWithDuration:1]];
    [okButton runAction:[CCActionFadeOut actionWithDuration:1]];
    [pauseTint runAction:[CCActionFadeOut actionWithDuration:1]];
    [speechBubble runAction:[CCActionFadeOut actionWithDuration:1]];
    [confirmText setVisible:NO];
    [coinPrice setVisible:NO];
    [_8coinPrice setVisible:NO];
    
    
    [speechBubble removeFromParentAndCleanup:YES];
    
    _purchaseActive = NO;
    _shopTable.verticalScrollEnabled = YES;
}

-(void)displayMessageModalWithString:(NSString*)msg
{
    [octoBoss talk];
    // tint scene
    pauseTint = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.7f]];
    [self addChild:pauseTint z:4];
    
    // turn off interactions (make sure to turn them back on
    _purchaseActive = YES;
    _shopTable.verticalScrollEnabled = NO;
    
    // display bubble
    speechBubble = [CCSprite spriteWithImageNamed:@"Armory-Bubble-2.png"];
    speechBubble.scale = 0;
    speechBubble.positionType = CCPositionTypeNormalized;
    speechBubble.position = ccp(0.5f,0.5f);
    [self addChild:speechBubble z:5];
    [speechBubble runAction:[CCActionScaleTo actionWithDuration:0.3f scale:2]];
    
    // confirmation text
    confirmText = [[CCLabelBMFont alloc] initWithFile:@"Font-File-Armory.png" capacity:10];
    [confirmText setFntFile:@"Font-File-Armory.fnt"];
    confirmText.anchorPoint = ccp(0.5f,0.5f);
    [confirmText setWidth:speechBubble.contentSize.width*0.8];
    [confirmText setScale:0.8];
    [confirmText setPosition:ccp(speechBubble.contentSize.width/2, speechBubble.contentSize.height*0.65)];
    [confirmText setCascadeOpacityEnabled:YES];
    [confirmText setString:msg];
    [speechBubble addChild:confirmText z:5];
    
    okButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Ok.png"]];
    [speechBubble addChild:okButton z:5];
    okButton.anchorPoint = ccp(0.5f, 0.5f);
    okButton.position = ccp(speechBubble.contentSize.width/2, speechBubble.contentSize.height/2.8);
    okButton.cascadeOpacityEnabled = YES;
    [okButton setTarget:self selector:@selector(hideMessageModal)];
}

-(void)hideMessageModal
{
    [octoBoss idle];
    [pauseTint runAction:[CCActionFadeOut actionWithDuration:1]];
    [okButton runAction:[CCActionFadeOut actionWithDuration:1]];
    [speechBubble runAction:[CCActionFadeOut actionWithDuration:1]];
    [confirmText setVisible:NO];
    
    [speechBubble removeFromParentAndCleanup:YES];
    
    _purchaseActive = NO;
    _shopTable.verticalScrollEnabled = YES;
}

-(void)hidePurchaseCoinsModal
{
    [octoBoss idle];
    // refresh wallet count
    [self fillWallet];

    // hide all the stuff on the speechBubble
    [buy5coins runAction:[CCActionFadeOut actionWithDuration:1]];
    [buy15coins runAction:[CCActionFadeOut actionWithDuration:1]];
    [buy30coins runAction:[CCActionFadeOut actionWithDuration:1]];
    [cancelButton runAction:[CCActionFadeOut actionWithDuration:1]];
    [pauseTint runAction:[CCActionFadeOut actionWithDuration:1]];
    [speechBubble runAction:[CCActionFadeOut actionWithDuration:1]];
    [confirmText setVisible:NO];
    
    [speechBubble removeFromParentAndCleanup:YES];
    
    _purchaseActive = NO;
    _shopTable.verticalScrollEnabled = YES;
}

-(void)displayPurchaseCoinsModal
{
    [octoBoss talk];
    // tint scene
    pauseTint = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.7f]];
    [self addChild:pauseTint z:4];
    
    // turn off interactions (make sure to turn them back on
    _purchaseActive = YES;
    _shopTable.verticalScrollEnabled = NO;
    
    // display bubble
    speechBubble = [CCSprite spriteWithImageNamed:@"Armory-Bubble-3.png"];
    speechBubble.scale = 0;
    speechBubble.positionType = CCPositionTypeNormalized;
    speechBubble.position = ccp(0.5f,0.5f);
    [self addChild:speechBubble z:5];
    [speechBubble runAction:[CCActionScaleTo actionWithDuration:0.3f scale:2]];
    
    // setup buy buttons
    buy5coins = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Buy.png"]];
    buy5coins.anchorPoint = ccp(0.5f, 0.5f);
    buy5coins.position = ccp(speechBubble.contentSize.width/5, speechBubble.contentSize.height/2.1);
    buy5coins.cascadeOpacityEnabled = YES;
    [buy5coins setTarget:self selector:@selector(purchase5coins)];
    
    buy15coins = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Buy.png"]];
    buy15coins.anchorPoint = ccp(0.5f, 0.5f);
    buy15coins.position = ccp(speechBubble.contentSize.width/2, speechBubble.contentSize.height/2.1);
    buy15coins.cascadeOpacityEnabled = YES;
    [buy15coins setTarget:self selector:@selector(purchase15coins)];
    
    buy30coins = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Buy.png"]];
    buy30coins.anchorPoint = ccp(0.5f, 0.5f);
    buy30coins.position = ccp(speechBubble.contentSize.width*4/5, speechBubble.contentSize.height/2.1);
    buy30coins.cascadeOpacityEnabled = YES;
    [buy30coins setTarget:self selector:@selector(purchase30coins)];
    
    cancelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Cancel.png"]];
    cancelButton.anchorPoint = ccp(0.5f, 0.5f);
    cancelButton.position = ccp(speechBubble.contentSize.width/2, speechBubble.contentSize.height/3.3);
    cancelButton.cascadeOpacityEnabled = YES;
    [cancelButton setTarget:self selector:@selector(hidePurchaseCoinsModal)];
    
    [speechBubble addChild:cancelButton];
    [speechBubble addChild:buy5coins z:5];
    [speechBubble addChild:buy15coins z:5];
    [speechBubble addChild:buy30coins z:5];
    
    
}

-(void)displayRateMeModal
{
    // turn off interactions (make sure to turn them back on
    _purchaseActive = YES;
    _shopTable.verticalScrollEnabled = NO;
    
    FFFModalView *rateMe = [[FFFModalView alloc] initRateMeModal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissRateMeModal) name:@"FFFModalViewDismissed" object:nil];
    [self addChild:rateMe z:30];
    [rateMe displayModal];
}

-(void)dismissRateMeModal
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FFFModalViewDismissed" object:nil];
    [_shopTable reloadData];
    // turn on interactions
    _purchaseActive = NO;
    _shopTable.verticalScrollEnabled = YES;
}

-(void)purchase5coins
{
    [self loading];
    
    if(_products.count > 1){
        SKProduct *product;
        
        for (SKProduct *p in  _products) {
            if ([p.productIdentifier isEqualToString:@"com.krackgames.FlapFlapFish.buy5Coins"]) {
                product = p;
            }
        }
        
        CCLOG(@"Buying %@...", product.productIdentifier);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseFailed:) name:IAPHelperPurchaseFailedNotification object:nil];
        
        [[FFFishIAPHelper sharedInstance] buyProduct:product];
    } else {
        // alert user of connection error
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Connection Error"
                              message:@"There was an error with connecting with the server, please try again later."
                              delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil, nil];
        [alert show];
        [self hidePurchaseCoinsModal];
    }
}

-(void)purchase15coins
{
    [self loading];
    
    if(_products.count > 1){
        SKProduct *product;
        
        for (SKProduct *p in  _products) {
            if ([p.productIdentifier isEqualToString:@"com.krackgames.FlapFlapFish.buy15Coins"]) {
                product = p;
            }
        }
        
        CCLOG(@"Buying %@...", product.productIdentifier);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseFailed:) name:IAPHelperPurchaseFailedNotification object:nil];
        
        [[FFFishIAPHelper sharedInstance] buyProduct:product];
    } else {
        // alert user of connection error
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Connection Error"
                              message:@"There was an error with connecting with the server, please try again later."
                              delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil, nil];
        [alert show];
        [self hidePurchaseCoinsModal];
    }
}

-(void)purchase30coins
{
    [self loading];
    
    if(_products.count > 1){
        SKProduct *product;
        
        for (SKProduct *p in  _products) {
            if ([p.productIdentifier isEqualToString:@"com.krackgames.FlapFlapFish.buy30Coins"]) {
                product = p;
            }
        }
        CCLOG(@"Buying %@...", product.productIdentifier);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseFailed:) name:IAPHelperPurchaseFailedNotification object:nil];
        
        [[FFFishIAPHelper sharedInstance] buyProduct:product];
    } else {
        // alert user of connection error
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Connection Error"
                              message:@"There was an error with connecting with the server, please try again later."
                              delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil, nil];
        [alert show];
        [self hidePurchaseCoinsModal];
    }
}

-(void)loading
{
    [speechBubble setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Bubble-2.png"]];
    for(CCNode *obj in [speechBubble children])
    {
        [obj setVisible:NO];
    }
    
    CCSprite *loadingImage = [CCSprite spriteWithImageNamed:@"Coin-8-Armory.png"];
    
    [speechBubble addChild:loadingImage];
    [loadingImage setAnchorPoint:ccp(0.5f,0.5f)];
    [loadingImage setPosition:ccp(speechBubble.contentSize.width/2, speechBubble.contentSize.height*0.6)];
    
    [loadingImage runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:0.5f angle:360]]];
    
}

// coin purchases
- (void)productPurchased:(NSNotification *)notification {
    // TODO: display a thank you for puchase
    [self fillWallet];
    [self hidePurchaseCoinsModal];
    didPurchaseSomething = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// coin purchases
- (void)purchaseFailed:(NSNotification *)notification {
    [self hidePurchaseCoinsModal];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


BOOL up = YES;
// have to update the idle b/c actions causing synchronization problems with skins
-(void)update:(CCTime)delta
{
    if (fishIdle) {
        if (up) {
            [_fish setPosition:ccp(_fish.position.x, _fish.position.y + 0.25)];
            if (_fish.position.y >= (octoBoss.position.y + 10)) {
                up = NO;
            }
        } else {
            [_fish setPosition:ccp(_fish.position.x, _fish.position.y - 0.25)];
            if (_fish.position.y <= (octoBoss.position.y - 10)) {
                up = YES;
            }
        }
    }
    
}

@end
