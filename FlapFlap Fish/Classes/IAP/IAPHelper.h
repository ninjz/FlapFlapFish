//
//  IAPHelper.h
//  floppyFish
//
//  Created by sh0gun on 2/25/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//
// Add to the top of the file
#import <StoreKit/StoreKit.h>
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperPurchaseFailedNotification;



typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject <SKPaymentTransactionObserver>

@property(nonatomic, retain) NSSet *productIdentifiers;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
// Add two new method declarations
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
@end
