//
//  IAPHelperRequest.m
//  FlapFlap Fish
//
//  Created by sh0gun on 2014-03-24.
//  Copyright (c) 2014 Krack Games. All rights reserved.
//

#import "IAPHelperRequest.h"
#import "FFFishIAPHelper.h"
#import "cocos2d.h"

@interface IAPHelperRequest () <SKProductsRequestDelegate>
@end

@implementation IAPHelperRequest{
    // 3
    SKProductsRequest * _productsRequest;
    // 4
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}


-(id)initWithHelper:(IAPHelper*)helper
andCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    if (self = [super init]) {
        _completionHandler = [completionHandler copy];
        _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:helper.productIdentifiers]; // You will need to make productIdentifiers a property
        _productsRequest.delegate = self;
        [_productsRequest start];
    }
    return self;
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    CCLOG(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        CCLOG(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    CCLOG(@"Failed to load list of products.");
    
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
}

-(void)dealloc
{
    _productsRequest.delegate = nil;
}


@end
