//
//  IAPHelper.m
//  floppyFish
//
//  Created by sh0gun on 2/25/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

// 1
#import "IAPHelper.h"
#import "IAPHelperRequest.h"
#import "cocos2d.h"
#import <StoreKit/StoreKit.h>

// 2
//@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
//@end

@implementation IAPHelper {
    
    __block IAPHelperRequest *req;
    // 3
    SKProductsRequest * _productsRequest;
    // 4
    RequestProductsCompletionHandler _completionHandler;
    NSMutableSet * _purchasedProductIdentifiers;
}

// Add to top of file
NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperPurchaseFailedNotification = @"IAPHelperPurchaseFailedNotification";

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                CCLOG(@"Previously purchased: %@", productIdentifier);
            } else {
                CCLOG(@"Not purchased: %@", productIdentifier);
            }
        }
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    req = [[IAPHelperRequest alloc] initWithHelper:self andCompletionHandler:completionHandler];
    
}

#pragma mark - SKProductsRequestDelegate


- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    
    CCLOG(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    CCLOG(@"completeTransaction...");
    
    // alert user of restored purchases
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Purchases Complete"
                          message:@"Thank you for your purchase"
                          delegate:nil
                          cancelButtonTitle:@"Done"
                          otherButtonTitles:nil, nil];
    [alert show];
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    CCLOG(@"restoreTransaction...");
    
    // alert user of restored purchases
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Purchases Restored"
                          message:@"Your previous purchases have been restored."
                          delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil, nil];
    [alert show];
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    CCLOG(@"failedTransaction...");
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        CCLOG(@"Transaction error: %@", transaction.error.localizedDescription);
        // alert user of failed transaction
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Transaction Error"
                              message:@"There was an error with completing this transaction. Please try again later."
                              delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil, nil];
        [alert show];
        
        
    } else { // transaction was cancelled
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperPurchaseFailedNotification object:nil userInfo:nil];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}



// Add new method
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // remove ads
    if([productIdentifier isEqualToString:@"com.krackgames.FlapFlapFish.removeAds"]){
        [[GameState sharedGameState] setAdsRemoved:YES];
        [[GameState sharedGameState] saveState];
    }
    
    else if ([productIdentifier isEqualToString:@"com.krackgames.FlapFlapFish.buyNarwhal"]) {
        //unlock narwhal
        [[GameState sharedGameState] unlockFish:@"narwhal"];
    }
    
    else if ([productIdentifier isEqualToString:@"com.krackgames.FlapFlapFish.buyPiranha"]) {
        //unlock piranha
        [[GameState sharedGameState] unlockFish:@"piranha"];
    }
    
    // 8armory coin purchase
    else if ([productIdentifier isEqualToString:@"com.krackgames.FlapFlapFish.buy5Coins"]) {
        [[GameState sharedGameState] credit8ArmoryCoins:5];
    }
    
    else if ([productIdentifier isEqualToString:@"com.krackgames.FlapFlapFish.buy15Coins"]) {
        [[GameState sharedGameState] credit8ArmoryCoins:15];
    }

    else if ([productIdentifier isEqualToString:@"com.krackgames.FlapFlapFish.buy30Coins"]) {
        [[GameState sharedGameState] credit8ArmoryCoins:30];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
    
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end