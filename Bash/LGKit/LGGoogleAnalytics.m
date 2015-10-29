//
//  LGGoogleAnalytics.m
//  Bash
//
//  Created by Friend_LGA on 01.02.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "LGGoogleAnalytics.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "LGKit.h"

static NSString *const kTrackingId = @"UA-47703464-1";

#pragma mark ----------------------------------------------------------------------------------------------------

@interface LGGoogleAnalytics ()

@property (strong, nonatomic) id <GAITracker> tracker;
@property (assign, nonatomic) BOOL isGoogleAnalyticsOn;

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation LGGoogleAnalytics

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static id sharedManager = nil;
    
    dispatch_once(&once, ^
                  {
                      sharedManager = [super new];
                  });
    
    return sharedManager;
}

- (id)init
{
    LOG(@"");
    
    if ((self = [super init]))
    {
        NSLog(@"LGGoogleAnalytics: Shared Manager initialization...");
    }
	return self;
}

- (void)initialize
{
    LOG(@"");
    //[GAI sharedInstance].optOut = YES;
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to:
    [GAI sharedInstance].dispatchInterval = 60;
//#warning GOOGLE ANALYTICS
    
    // Optional: set Logger to VERBOSE for debug information.
    //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker.
    _tracker = [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
    
#if LG_DEBUG_MODE
    _isGoogleAnalyticsOn = NO;
#else
    _isGoogleAnalyticsOn = YES;
#endif
    
    [self setScreenName:@"Loading App" sendEventWithCategory:@"Loading App" action:nil label:nil value:nil];
}

- (void)setScreenName:(NSString *)name sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    if (_isGoogleAnalyticsOn)
    {
        [_tracker set:kGAIScreenName value:name];
        [_tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                               action:action
                                                                label:label
                                                                value:value] build]];
    }
}

- (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    if (_isGoogleAnalyticsOn)
    {
        [_tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                               action:action
                                                                label:label
                                                                value:value] build]];
    }
}

@end
