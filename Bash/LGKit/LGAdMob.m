//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "LGAdMob.h"
#import "AppDelegate.h"
#import "TopView.h"
#import "BottomView.h"
#import "LGKit.h"
#import "LGGoogleAnalytics.h"

static NSString *const kPublisherId = @"ca-app-pub-9184702614709179/9474218440";

#pragma mark ----------------------------------------------------------------------------------------------------

@interface LGAdMob ()

@property (strong, nonatomic) GADRequest        *request;
@property (strong, nonatomic) GADBannerView     *bannerView;
@property (assign, nonatomic) BOOL              isAdsReceive;

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation LGAdMob

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
        NSLog(@"LGAdMob: Shared Manager initialization...");
    }
	return self;
}

- (void)resizeAndRepositionAfterRotateToSize:(CGSize)size
{
    if (kLGKit.isAdMobEnabled)
    {
        [self bannerHide];
        
        BOOL isPortrait = (size.width < size.height);
        
        _bannerView.adSize = (isPortrait ? kGADAdSizeSmartBannerPortrait : kGADAdSizeSmartBannerLandscape);
        _bannerView.frame = CGRectMake(0.f, size.height-_bannerView.frame.size.height, _bannerView.frame.size.width, _bannerView.frame.size.height);
    }
}

- (UIView *)initialize
{
    LOG(@"");
    
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    _bannerView = [[GADBannerView alloc] initWithAdSize:(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? kGADAdSizeSmartBannerPortrait : kGADAdSizeSmartBannerLandscape)];
    _bannerView.delegate = self;
    
    _bannerView.rootViewController = kNavController;
    _bannerView.opaque = YES;
    _bannerView.backgroundColor = kColorBlack;
    _bannerView.hidden = YES;
    _bannerView.alpha = 0.f;
    
    // Specify the ad's "unit identifier". This is your AdMob Publisher ID.
    _bannerView.adUnitID = kPublisherId;
    
    return _bannerView;
}

- (void)sendRequest
{
    LOG(@"");
    
    if (!_request)
    {
        _request = [GADRequest request];
        
#if LG_DEBUG_MODE
        // Make the request for a test ad. Put in an identifier for
        // the simulator as well as any devices you want to receive test ads.
        _request.testDevices = [NSArray arrayWithObjects:
                                @"GAD_SIMULATOR_ID",
                                @"b6abf9b32920cee19783207fb3abdf1f",
                                @"fd4408be761c3cc81ffb2c073ac257ea",
                                nil];
#endif
    }
    
    if (kLGKit.isAdMobEnabled) [_bannerView loadRequest:_request];
}

- (void)adViewDidReceiveAd:(GADBannerView *)banner
{
    LOG(@"");
    
    if (kLGKit.isAdMobEnabled)
    {
        NSLog(@"LGAdMob: AdView Did Receive Ad");
        
        for (UIWebView *webView in _bannerView.subviews)
        {
            webView.scrollView.scrollEnabled = NO;
            webView.scrollView.bounces = NO;
            webView.scrollView.showsVerticalScrollIndicator = NO;
            webView.scrollView.showsHorizontalScrollIndicator = NO;
            webView.scrollView.contentSize = _bannerView.frame.size;
        }
        
        [self bannerShow];
    }
}

- (void)adView:(GADBannerView *)banner didFailToReceiveAdWithError:(GADRequestError *)error
{
    LOG(@"");
    
    NSLog(@"LGAdMob: AdView Did Fail To Receive Ad With Error: %@", error.localizedDescription);
    
    [self bannerHide];
}

- (void)bannerShow
{
    LOG(@"");
    
    if (!_isAdsReceive)
    {
        _isAdsReceive = YES;
        
        [kTopView bringSubviewToFront:_bannerView];
        _bannerView.hidden = NO;
        
        [UIView animateWithDuration:0.5
                         animations:^(void)
         {
             _bannerView.alpha = 1.f;
             
             [kTopView tableViewContentInsetUpdate];
         }
                         completion:nil];
    }
}

- (void)bannerHide
{
    LOG(@"");
    
    if (_isAdsReceive)
    {
        _isAdsReceive = NO;
        
        [UIView animateWithDuration:0.5
                         animations:^(void)
         {
             _bannerView.alpha = 0;
             
             [kTopView tableViewContentInsetUpdate];
         }
                         completion:^(BOOL finished)
         {
             [kTopView sendSubviewToBack:_bannerView];
             _bannerView.hidden = YES;
         }];
    }
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView
{
    LOG(@"");
    
    NSLog(@"LGAdMob: AdView Did Dismiss Screen");
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView
{
    LOG(@"");
    
    NSLog(@"LGAdMob: AdView Will Present Screen");
    
    [kLGGoogleAnalytics sendEventWithCategory:@"AdMob" action:@"Open" label:nil value:nil];
}

@end














