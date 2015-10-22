//
//  SDCloudUserDefaults.m
//
//  Created by Stephen Darlington on 01/09/2011.
//  Copyright (c) 2011 Wandle Software Limited. All rights reserved.
//

#import "SDCloudUserDefaults.h"

@implementation SDCloudUserDefaults

static id notificationObserver;

+(NSString*)stringForKey:(NSString*)aKey {
    return [SDCloudUserDefaults objectForKey:aKey];
}

+(BOOL)boolForKey:(NSString*)aKey {
    return [[SDCloudUserDefaults objectForKey:aKey] boolValue];
}

+(id)objectForKey:(NSString*)aKey {
    NSUbiquitousKeyValueStore* cloud = [NSUbiquitousKeyValueStore defaultStore];
    id retv = [cloud objectForKey:aKey];
    if (!retv) {
        retv = [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
        [cloud setObject:retv forKey:aKey];
    }
    
    return retv;
}

+(int)integerForKey:(NSString*)aKey {
    return [[SDCloudUserDefaults objectForKey:aKey] intValue];
}

+(void)setString:(NSString*)aString forKey:(NSString*)aKey {
    [SDCloudUserDefaults setObject:aString forKey:aKey];
}

+(void)setBool:(BOOL)aBool forKey:(NSString*)aKey {
    [SDCloudUserDefaults setObject:[NSNumber numberWithBool:aBool] forKey:aKey];
}

+(void)setObject:(id)anObject forKey:(NSString*)aKey {
    [[NSUbiquitousKeyValueStore defaultStore] setObject:anObject forKey:aKey];
    [[NSUserDefaults standardUserDefaults] setObject:anObject forKey:aKey];
}

+(void)setInteger:(NSInteger)anInteger forKey:(NSString*)aKey {
    [SDCloudUserDefaults setObject:[NSNumber numberWithInteger:anInteger]
                            forKey:aKey];
}

+(void)removeObjectForKey:(NSString*)aKey {
    [[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:aKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:aKey];
}

+(void)synchronize {
//    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.krackgames.FlapFlapFish", NULL);
    
    // Send sync to GCD
    
    dispatch_async(backgroundQueue, ^(void){
    
        if ([NSUbiquitousKeyValueStore defaultStore]) {
            
            // iCloud enabled
            
            [[NSUbiquitousKeyValueStore defaultStore] synchronize];
            
//            NSLog(@"SDUserDefaults - saved to iCloud");
            
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
//        [[NSNotificationCenter defaultCenter] postNotificationName:SDCloudDoneSync object:nil userInfo:nil];
    });
    
    // Clean up queue
    
    dispatch_release(backgroundQueue);
    
    
}

+(void)registerForNotifications {
    @synchronized(notificationObserver) {
        if (notificationObserver) {
            return;
        }

        notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"NSUbiquitousKeyValueStoreDidChangeExternallyNotification"
                                                                                 object:[NSUbiquitousKeyValueStore defaultStore]
                                                                                  queue:nil
                                                                             usingBlock:^(NSNotification* notification) {
                                                                                 
                                                                                 
                                                                                 NSDictionary* userInfo = [notification userInfo];
                                                                                 NSNumber* reasonForChange = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
                                                                                 
                                                                                 // If a reason could not be determined, do not update anything.
                                                                                 if (!reasonForChange)
                                                                                     return;
                                                                                 
                                                                                 // Update only for changes from the server.
                                                                                 NSInteger reason = [reasonForChange integerValue];
                                                                                 
                                                                                 if (reason == NSUbiquitousKeyValueStoreServerChange) {
                                                                                     // need to compare values to make sure no concurrency issues
                                                                                     NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                                                                                     NSUbiquitousKeyValueStore* cloud = [NSUbiquitousKeyValueStore defaultStore];
                                                                                     
                                                                                     NSArray* changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
                                                                                     
                                                                                     
                                                                                     // you only get more skins
                                                                                     if ([[cloud objectForKey:kGameStateSkinsOwned] count] >= [[[GameState sharedGameState] skinsOwned] count] )
                                                                                     {
                                                                                        [defaults setObject:[cloud objectForKey:kGameStateSkinsOwned] forKey:kGameStateSkinsOwned];
                                                                                     }
                                                                                     
                                                                                     // new high score
                                                                                     if ([[[cloud objectForKey:kGameStateHighScore] objectAtIndex:0] intValue] >= [[[[GameState sharedGameState] highScore] objectAtIndex:0] intValue] &&
                                                                                         [[[cloud objectForKey:kGameStateHighScore] objectAtIndex:1] intValue] >= [[[[GameState sharedGameState] highScore] objectAtIndex:1] intValue] &&
                                                                                         [[[cloud objectForKey:kGameStateHighScore] objectAtIndex:2] intValue] >= [[[[GameState sharedGameState] highScore] objectAtIndex:2] intValue] &&
                                                                                         [[[cloud objectForKey:kGameStateHighScore] objectAtIndex:3] intValue] >= [[[[GameState sharedGameState] highScore] objectAtIndex:3] intValue] &&
                                                                                         [[[cloud objectForKey:kGameStateHighScore] objectAtIndex:4] intValue] >= [[[[GameState sharedGameState] highScore] objectAtIndex:4] intValue])
                                                                                     {
                                                                                         [defaults setObject:[cloud objectForKey:kGameStateHighScore] forKey:kGameStateHighScore];
                                                                                         
                                                                                     }
                                                                                     
                                                                                     // fish was unlocked (you cant lose fish)
                                                                                     if ([changedKeys containsObject:kGameStateUnlockedFishes]) {
                                                                                         [defaults setObject:[cloud objectForKey:kGameStateUnlockedFishes] forKey:kGameStateUnlockedFishes];
                                                                                     }
                                                                                     
                                                                                      [SDCloudUserDefaults synchronize];
                                                                                 }
                                                                                 
                                                                                 if ((reason == NSUbiquitousKeyValueStoreInitialSyncChange) || (reason == NSUbiquitousKeyValueStoreAccountChange)) {
                                                                                     UIAlertView *alert = [[UIAlertView alloc]
                                                                                                           initWithTitle:@"Saved game loaded"
                                                                                                           message:@"iCloud detected a previous game save"
                                                                                                           delegate:nil
                                                                                                           cancelButtonTitle:@"Ok"
                                                                                                           otherButtonTitles:nil, nil];
                                                                                     [alert show];
                                                                                     
                                                                                     NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                                                                                     NSUbiquitousKeyValueStore* cloud = [NSUbiquitousKeyValueStore defaultStore];
                                                                                     NSArray* changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
                                                                                     for (NSString* key in changedKeys) {
                                                                                         [defaults setObject:[cloud objectForKey:key] forKey:key];
                                                                                     }
                                                                                     [SDCloudUserDefaults synchronize];
                                                                                     
                                                                                 }
                                                                                 
                                                                                 [[GameState sharedGameState] loadSavedState];
                                                                                 
                                                                             }];
    }
    
}


+(void)removeNotifications {
    @synchronized(notificationObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
        notificationObserver = nil;
    }
}

@end
