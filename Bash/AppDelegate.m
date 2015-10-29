//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "AppDelegate.h"
#import "LGKit.h"
#import "Settings.h"
#import "LGInAppPurchases.h"
#import "LGChapter.h"
#import "LGGoogleAnalytics.h"
#import "VKSdk.h"
#import "GPPURLHandler.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LOG(@"");
    
    self.rootNC = [NavigationController new];
        
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.rootNC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    LOG(@"");
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    LOG(@"");
    
    //[kLGGoogleAnalytics sendEventWithCategory:@"App Delegate" action:@"Application Did Enter Background" label:nil value:nil];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [kSettings save];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    LOG(@"");
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    LOG(@"");
    
    //[kLGGoogleAnalytics sendEventWithCategory:@"App Delegate" action:@"Application Did Become Active" label:nil value:nil];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    LOG(@"");
    
    //[kLGGoogleAnalytics sendEventWithCategory:@"App Delegate" action:@"Application Will Terminate" label:nil value:nil];
    
    // Saves changes in the application's managed object context before the application terminates.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    LOG(@"");
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
    
    return YES;
}

void uncaughtExceptionHandler(NSException *exception)
{
    LOG(@"");
    
    NSString *crashString = [NSString stringWithFormat:@"Crash info: %@ \nStack: %@", exception, [exception callStackSymbols]];
    
    NSLog(@"%@", crashString);
}

@end
