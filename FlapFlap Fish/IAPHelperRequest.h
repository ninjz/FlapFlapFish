//
//  IAPHelperRequest.h
//  FlapFlap Fish
//
//  Created by sh0gun on 2014-03-24.
//  Copyright (c) 2014 Krack Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAPHelperRequest : NSObject

-(id)initWithHelper:(IAPHelper*)helper
andCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

@end
