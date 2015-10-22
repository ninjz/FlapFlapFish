//
//  FFFModalView.m
//  FlapFlap Fish
//
//  Created by sh0gun on 2014-03-30.
//  Copyright 2014 Krack Games. All rights reserved.
//

#import "FFFModalView.h"
#import "CCAnimation+Helper.h"
#import "FFFishIAPHelper.h"
#import "MenuScene.h"
#import "The8ArmoryStockManager.h"


@implementation FFFModalView{
    CCNodeColor *pauseTint;
    CCSprite *popup, *tapPrompt;
    CCButton *button1, *button2;
    CGSize winSize;
}

#pragma Rate-Me Modal
-(id)initRateMeModal
{
    if(self = [super init]){
        winSize = [[CCDirector sharedDirector] viewSize];
        
        
        
        // tint scene
        pauseTint = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.7f]];
        
        popup = [CCSprite spriteWithImageNamed:@"Popup-Rate.png"];
        
        // rate now button
        button1 = [CCButton buttonWithTitle:NULL spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Popup-RateNow.png"]];
        [button1 setCascadeOpacityEnabled:YES];
        // rate later button
        button2 = [CCButton buttonWithTitle:NULL spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Popup-Later.png"]];
        [button2 setCascadeOpacityEnabled:YES];
        
        
        popup.scale = 2;
        
        [self addChild:pauseTint z:4];
        [self addChild:popup z:5];
        [popup addChild:button1];
        [popup addChild:button2];
        
        popup.anchorPoint = ccp(0.5f, 0.5f);
        [popup setPosition:ccp(winSize.width/2, winSize.height/2)];
        [button1 setPosition:ccp(popup.contentSize.width/2, popup.contentSize.height/4.5)];
        [button2 setPosition:ccp(popup.contentSize.width/2, popup.contentSize.height/9.5)];
        
        [button1 setTarget:self selector:@selector(rateNow)];
        [button2 setTarget:self selector:@selector(rateLater)];
        
        [pauseTint setVisible:NO];
        [popup setVisible:NO];
    }
    return self;
}


-(void)rateNow
{
    NSString *url;
#ifdef ANDROID
    url = @"market://details?id=<package_name>";
#else
    url = @"http://itunes.apple.com/app/id830240851";
#endif
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithString:url]]];
    
    // set rated
    [[GameState sharedGameState] setRated:YES];
    // unlock 8armory skins
    NSMutableArray *skinsOwned = [[[GameState sharedGameState] skinsOwned] mutableCopy];
    [skinsOwned addObject:@"P010"];
    [skinsOwned addObject:@"N010"];
    [skinsOwned addObject:@"C010"];
    [skinsOwned addObject:@"S007"];
    [[GameState sharedGameState] setSkinsOwned:skinsOwned];
    [[GameState sharedGameState] saveState];
    // dismiss modal view
    [self dismissRateMeModal];
}

-(void)rateLater
{
    // dismiss modal view
    [self dismissRateMeModal];
}

-(void)dismissRateMeModal
{
    [pauseTint runAction:[CCActionFadeOut actionWithDuration:0.2f]];
    [popup runAction:[CCActionFadeOut actionWithDuration:0.2f]];
    [button1 runAction:[CCActionFadeOut actionWithDuration:0.2f]];
    [button2 runAction:[CCActionFadeOut actionWithDuration:0.2f]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FFFModalViewDismissed" object:nil];
    
    [self enableBackground];
    [self removeFromParentAndCleanup:YES];
}

#pragma Buy Character Modal

-(id)initBuyNarwhalModal
{
    if (self = [super init]) {
        winSize = [[CCDirector sharedDirector] viewSize];
        
        
        // tint scene
        pauseTint = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.7f]];
        
        popup = [CCSprite spriteWithImageNamed:@"Popup-Narwhal.png"];
        
        // rate now button
        button1 = [CCButton buttonWithTitle:NULL spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-BuyCoins.png"]];
        [button1 setCascadeOpacityEnabled:YES];
        // rate later button
        button2 = [CCButton buttonWithTitle:NULL spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Cancel.png"]];
        [button2 setCascadeOpacityEnabled:YES];
        
        // tap prompt
        tapPrompt = [CCSprite spriteWithImageNamed:@"Popup-NarwhalTutorial-1.png"];
        CCAnimation *tap = [CCAnimation animationWithFrame:@"Popup-NarwhalTutorial-" frameCount:2 delay:0.15f];
        
        [tapPrompt runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:tap]]];
        
        
        popup.scale = 2;
        
        [self addChild:pauseTint z:4];
        [self addChild:popup z:5];
        [popup addChild:button1];
        [popup addChild:button2];
        [popup addChild:tapPrompt];
        
        popup.anchorPoint = ccp(0.5f, 0.5f);
        [popup setPosition:ccp(winSize.width/2, winSize.height/2)];
        [button1 setPosition:ccp(popup.contentSize.width/4, popup.contentSize.height/8.5)];
        [button2 setPosition:ccp(popup.contentSize.width*3/4, popup.contentSize.height/8.5)];
        [tapPrompt setPosition:ccp(popup.contentSize.width/3, popup.contentSize.width*3/4)];
        
        [button1 setTarget:self selector:@selector(buyNarwhal)];
        [button2 setTarget:self selector:@selector(dismissModal)];
        
        [pauseTint setVisible:NO];
        [popup setVisible:NO];
    }
    return self;
}

-(id)initBuyPiranhaModal
{
    if (self = [super init]) {
        winSize = [[CCDirector sharedDirector] viewSize];
        
        
        // tint scene
        pauseTint = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.7f]];
        
        popup = [CCSprite spriteWithImageNamed:@"Popup-Piranha.png"];
        
        // rate now button
        button1 = [CCButton buttonWithTitle:NULL spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-BuyCoins.png"]];
        [button1 setCascadeOpacityEnabled:YES];
        // rate later button
        button2 = [CCButton buttonWithTitle:NULL spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Armory-Cancel.png"]];
        [button2 setCascadeOpacityEnabled:YES];
        
        // tap prompt
        tapPrompt = [CCSprite spriteWithImageNamed:@"Popup-PiranhaTutorial-1.png"];
        CCAnimation *tap = [CCAnimation animationWithFrame:@"Popup-PiranhaTutorial-" frameCount:4 delay:0.25f];
        
        [tapPrompt runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:tap]]];
        
        
        popup.scale = 2;
        
        [self addChild:pauseTint z:4];
        [self addChild:popup z:5];
        [popup addChild:button1];
        [popup addChild:button2];
        [popup addChild:tapPrompt];
        
        popup.anchorPoint = ccp(0.5f, 0.5f);
        [popup setPosition:ccp(winSize.width/2, winSize.height/2)];
        [button1 setPosition:ccp(popup.contentSize.width/4, popup.contentSize.height/8.5)];
        [button2 setPosition:ccp(popup.contentSize.width*3/4, popup.contentSize.height/8.5)];
        [tapPrompt setPosition:ccp(popup.contentSize.width/2.5, popup.contentSize.width*3/4)];
        
        [button1 setTarget:self selector:@selector(buyPiranha)];
        [button2 setTarget:self selector:@selector(dismissModal)];
        
        [pauseTint setVisible:NO];
        [popup setVisible:NO];
    }
    return self;
}

-(void)buyNarwhal
{
    NSArray *products = [[The8ArmoryStockManager sharedStockManager] products];
    button1.enabled = NO;
    button2.enabled = NO;
    
    if(products.count > 0){
        SKProduct *product;
        for (SKProduct *p in  products) {
            if ([p.productIdentifier isEqualToString:@"com.krackgames.FlapFlapFish.buyNarwhal"]) {
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
        [self dismissModal];
    }
}

-(void)buyPiranha
{
    NSArray *products = [[The8ArmoryStockManager sharedStockManager] products];
    button1.enabled = NO;
    button2.enabled = NO;
    
    if(products.count > 0){
        SKProduct *product;
        for (SKProduct *p in  products) {
            if ([p.productIdentifier isEqualToString:@"com.krackgames.FlapFlapFish.buyPiranha"]) {
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
        [self dismissModal];
    }
}

-(void)productPurchased:(NSNotification *)obj
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // refresh char select menu
    [[[MenuScene sharedMenuScene] charSelectMenu] initFrame];
    
    [self dismissModal];
}

-(void)purchaseFailed:(NSNotification *)obj
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissModal];
}

-(void)dismissModal
{
    [tapPrompt runAction:[CCActionFadeOut actionWithDuration:0.2f]];
    [pauseTint runAction:[CCActionFadeOut actionWithDuration:0.2f]];
    [popup runAction:[CCActionFadeOut actionWithDuration:0.2f]];
    [button1 runAction:[CCActionFadeOut actionWithDuration:0.2f]];
    [button2 runAction:[CCActionFadeOut actionWithDuration:0.2f]];
    
    [self enableBackground];
    [self removeFromParentAndCleanup:YES];
}


-(void)displayModal
{
    for (CCNode *obj in [self children]) {
        [obj setVisible:YES];
    }
    [self disableBackground];
}

-(void)displayModalWithAction:(CCAction *)action
{
    for (CCNode *obj in [self children]) {
        [obj runAction:action];
    }
    [self disableBackground];
}


-(void)disableBackground
{
    for (id obj in [[self parent] children]) {
        CCLOG(@"%@", obj);
        if (obj != self) {
            if ([obj isKindOfClass:[CCButton class]]) {
                [(CCButton *)obj setEnabled:NO];
            }
        }
    }
}


-(void)enableBackground
{
    for (id obj in [[self parent] children]) {
        CCLOG(@"%@", obj);
        if (obj != self) {
            if ([obj isKindOfClass:[CCButton class]]) {
                [(CCButton *)obj setEnabled:YES];
            }
        }
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
