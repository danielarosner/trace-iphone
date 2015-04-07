//
//  AppDelegate.m
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/07/15.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

// what Parse db to connect to below
Boolean gUseAndroidDb = NO;         // DO NOT SET TO YES until compatable iOS and Android versions



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (gUseAndroidDb)
    {
        // Android Parse db
        [Parse setApplicationId:@"7QgrBfPkXxcgHJKSaTTVcaiQHVJV5OxV84YdRrCC"
                      clientKey:@"6ohugWbOCsePh0QO7fC1w5ro428kupfBw7Q1k0Kz"];
    }
    else
    {
        // iOS Parse db
        [Parse setApplicationId:@"Ksi8Iy1x3K26UU28BxDNuMor8NN28PKwvFmUUg16"
                      clientKey:@"e8uJjose8iYAJg6ZQHIrgIt7kznSN85IcOz0qnk4"];

        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
 
@end
