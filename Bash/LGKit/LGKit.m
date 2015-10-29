//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "LGKit.h"
#import "Settings.h"
#import "LGChapter.h"
#import "LGAdMob.h"
#import "LGGoogleAnalytics.h"
#import "LGCloud.h"
#import "LGDocuments.h"
#import "LGCoreData.h"
#import "LGInAppPurchases.h"
#import "LGColorConverter.h"
#import "LGVkontakte.h"
#import "Versions.h"
#import "AppDelegate.h"
#import "QuoteGetter.h"
#import "TopView.h"
#import "BottomView.h"
#import "Reachability.h"
#import "SSKeychain.h"
#import "InfoViewController.h"
#import "NavigationController.h"
#import "TopThemeObject.h"
#import "BottomThemeObject.h"
#import "PrerenderedImages.h"

#pragma mark - Private

@interface LGKit ()

@property (assign, nonatomic) int adsDelayedTimes;

@end

#pragma mark - Implementation

@implementation LGKit

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
        NSLog(@"LGKit: Shared Manager initialization...");
    }
    
	return self;
}

- (void)initialize
{
    LOG(@"");
        
    NSLog(@"LGKit: App Version ---------- %@", kAppVersion);
    NSLog(@"LGKit: Device Model --------- %@", kDeviceModel);
    NSLog(@"LGKit: iOS Version ---------- %.1f", kSystemVersion);
    NSLog(@"LGKit: App Directory -------- %@", kApplicationsDirectoryURL);
    NSLog(@"LGKit: Documents Directory -- %@", kDocumentsDirectoryURL);
    
    // In-App Purchases
    
    [kLGInAppPurchases initialize];
    
    // Google Analytics
    
    [kLGGoogleAnalytics initialize];
    
    // Reachability
    
    [kNotificationCenter addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[Reachability reachabilityForInternetConnection] startNotifier];
    
    // Загрузка настроек
    
    [kSettings load];
    
    // Versions
    
    [kVersions check];
    
    // iCloud && Documents
    
    [kLGCloud initialize];
    [kLGCoreData initialize];
    [kLGCloud sync];
    
    // подготовка изображений
    
    [kPrerenderedImages initialize];
    
    // выставление сохраненного рейтинга цитатам
    
    if (kSettings.quotesNeedRating.count && self.internetStatus)
    {
        for (NSString *requestString in kSettings.quotesNeedRating)
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestString]]
                                               queue:[NSOperationQueue new]
                                   completionHandler:nil];
        
        kSettings.quotesNeedRating = [NSMutableArray new];
    }
    
    // Reminder
    
    [self reminderCheck];
}

- (void)redrawViewAndSubviews:(UIView *)view
{
    //LOG(@"");
    
    [view setNeedsLayout];
    [view setNeedsDisplay];
    
    if (view.subviews)
        for (UIView *view_ in view.subviews)
            if ([view_ isKindOfClass:[UIView class]])
                [self redrawViewAndSubviews:view_];
}

#pragma mark - Reachability

- (void)reachabilityChanged:(NSNotification *)notification
{
    LOG(@"");
    
    NetworkStatus netStatus = [[Reachability reachabilityWithHostName:@"www.bash.im"] currentReachabilityStatus];
    
    switch (netStatus)
    {
        case NotReachable:
        {
            NSLog(@"Reachability: Access not available");

            if (_isAdMobEnabled) [kLGAdMob bannerHide];
        }
        case ReachableViaWWAN:
        {
            NSLog(@"Reachability: Reachable WWAN");

            if (_isAdMobEnabled) [kLGAdMob sendRequest];
        }
        case ReachableViaWiFi:
        {
            NSLog(@"Reachability: Reachable WiFi");

            if (_isAdMobEnabled) [kLGAdMob sendRequest];
        }
    }
}

- (int)internetStatus
{
    LOG(@"");
    
    return [[Reachability reachabilityWithHostName:@"www.bash.im"] currentReachabilityStatus];
}

- (int)getInternetStatusWithMessage
{
    LOG(@"");
    
    if (!self.internetStatus) [kInfoVC showInfoWithText:@"Отсутствует подключение к интернету.\n•   •   •\nНастройте соединение и попытайтесь снова."];
    
    return self.internetStatus;
}

#pragma mark - Reminder

- (void)reminderCheck
{
    LOG(@"");
    
    NSString *firstLaunchDateString = [SSKeychain passwordForService:@"ru.ApogeeStudio.Bash" account:@"firstLaunchDate"];
    
    if (!firstLaunchDateString)
    {
        if (![kStandartUserDefaults objectForKey:@"firstLaunchDate"]) _needsToShowFirstInfo = YES;
        
        NSDate *firstLaunchDate;
        if (![kStandartUserDefaults objectForKey:@"firstLaunchDate"]) firstLaunchDate = [NSDate date];
        else firstLaunchDate = [kStandartUserDefaults objectForKey:@"firstLaunchDate"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterFullStyle];
        [dateFormat setTimeStyle:NSDateFormatterFullStyle];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        NSLog(@"LGKit: First launch date (new) -------------- %@", [dateFormat stringFromDate:firstLaunchDate]);
        [SSKeychain setPassword:[dateFormat stringFromDate:firstLaunchDate] forService:@"ru.ApogeeStudio.Bash" account:@"firstLaunchDate"];
    }
    else
    {
        [kStandartUserDefaults setBool:YES forKey:@"isInfoShowed"];
        
        NSLog(@"LGKit: First launch date (saved) ------------ %@", firstLaunchDateString);
    }
    
    NSUInteger launchCountTotal = [kStandartUserDefaults integerForKey:@"launchCountTotal"];
    launchCountTotal++;
    [kStandartUserDefaults setInteger:launchCountTotal forKey:@"launchCountTotal"];
    NSLog(@"LGKit: Launch count total ------------------- %lu", (unsigned long)launchCountTotal);
    
    NSUInteger launchCounterAfterUpdate = [kStandartUserDefaults integerForKey:@"launchCounterAfterUpdate"];
    launchCounterAfterUpdate++;
    [kStandartUserDefaults setInteger:launchCounterAfterUpdate forKey:@"launchCounterAfterUpdate"];
    NSLog(@"LGKit: Launch count after update ------------ %lu", (unsigned long)launchCounterAfterUpdate);
    
    firstLaunchDateString = [SSKeychain passwordForService:@"ru.ApogeeStudio.Bash" account:@"firstLaunchDate"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterFullStyle];
    [dateFormat setTimeStyle:NSDateFormatterFullStyle];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate *firstLaunchDate = [dateFormat dateFromString:firstLaunchDateString];
    int daysSinceFirstLaunch = [[NSDate date] timeIntervalSinceDate:firstLaunchDate]/60/60/24;
    NSLog(@"LGKit: Days since first launch -------------- %i", daysSinceFirstLaunch);
    
    NSDate *firstLaunchAfterUpdateDate = [kStandartUserDefaults objectForKey:@"firstLaunchAfterUpdateDate"];
    int daysSinceFirstLaunchAfterUpdate = [[NSDate date] timeIntervalSinceDate:firstLaunchAfterUpdateDate]/60/60/24;
    NSLog(@"LGKit: Days since first launch after update - %i", daysSinceFirstLaunchAfterUpdate);
    
    if (![kStandartUserDefaults boolForKey:@"isRateReminderShowed"] && daysSinceFirstLaunchAfterUpdate >= 5 && launchCounterAfterUpdate >= 5 && (daysSinceFirstLaunchAfterUpdate % 2) &&
        daysSinceFirstLaunchAfterUpdate >= [kStandartUserDefaults integerForKey:@"isRateReminderShowLater"] && self.internetStatus)
        _needsToShowRateReminder = YES;
    else if (![kStandartUserDefaults boolForKey:@"isVkReminderShowed"] && daysSinceFirstLaunchAfterUpdate >= 5 && launchCounterAfterUpdate >= 5 && !(daysSinceFirstLaunchAfterUpdate % 2) &&
             daysSinceFirstLaunchAfterUpdate >= [kStandartUserDefaults integerForKey:@"isVkReminderShowLater"] && self.internetStatus)
        _needsToShowVkReminder = YES;
    
    if (!kIsRemoveAdsPurchased && daysSinceFirstLaunch > 7)
    {
        _isAdMobEnabled = YES;
    }
    else
    {
        _isAdMobEnabled = NO;
        NSLog(@"LGKit: AdMob is DISABLED");
    }
}

- (void)tempAdsHide
{
    LOG(@"");
    
    if (_isAdMobEnabled)
    {
        NSLog(@"LGKit: AdMob is temporary DISABLED on 10 min.");
        
        _adsDelayedTimes++;
        
        _isAdMobEnabled = NO;
        [kLGAdMob bannerHide];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(600 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                       {
                           _adsDelayedTimes--;
                           
                           if (_adsDelayedTimes == 0)
                           {
                               NSLog(@"LGKit: AdMob is ENABLED");
                               
                               _isAdMobEnabled = YES;
                               [kLGAdMob sendRequest];
                           }
                           else NSLog(@"LGKit: AdMob is NOT ENABLED yet");
                       });
    }
}

#pragma mark - Animations

- (void)animationWithCrossDissolveView:(UIView *)view duration:(NSTimeInterval)duration
{
    [self animationWithCrossDissolveView:view duration:duration completionHandler:nil];
}

- (void)animationWithCrossDissolveView:(UIView *)view completionHandler:(void(^)(BOOL complete))completionHandler
{
    [self animationWithCrossDissolveView:view duration:0.4 completionHandler:completionHandler];
}

- (void)animationWithCrossDissolveView:(UIView *)view duration:(NSTimeInterval)duration completionHandler:(void(^)(BOOL complete))completionHandler
{
    [UIView transitionWithView:view
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:^(BOOL finished)
     {
         if (completionHandler) completionHandler(finished);
     }];
}

#pragma mark

- (BOOL)isDeviceOld
{
    NSMutableString *devicePlatform = [LGHelper devicePlatform].mutableCopy;
    
    float phoneVersion = 4.1;
    float podVersion = 5.1;
    float padVersion = 2.1;
    
    [devicePlatform replaceOccurrencesOfString:@"," withString:@"."];
    
    if ([devicePlatform rangeOfString:@"iPhone"].location != NSNotFound)
    {
        [devicePlatform replaceOccurrencesOfString:@"iPhone" withString:@""];
        
        phoneVersion = devicePlatform.floatValue;
    }
    else if ([devicePlatform rangeOfString:@"iPod"].location != NSNotFound)
    {
        [devicePlatform replaceOccurrencesOfString:@"iPod" withString:@""];
        
        podVersion = devicePlatform.floatValue;
    }
    else if ([devicePlatform rangeOfString:@"iPad"].location != NSNotFound)
    {
        [devicePlatform replaceOccurrencesOfString:@"iPad" withString:@""];
        
        padVersion = devicePlatform.floatValue;
    }
    
    return (phoneVersion < 4.09 || podVersion < 5.09 || padVersion < 2.09);
}

#pragma mark

- (UIImage *)circleWithColor:(UIColor *)color
{
    CGFloat imageSize = 30.f;
    CGFloat size = 29.f;
    
    return [LGDrawer drawEllipseWithSize:CGSizeMake(size, size)
                               imageSize:CGSizeMake(imageSize, imageSize)
                         backgroundColor:nil
                               fillColor:color
                             strokeColor:(kBottomTheme.type == BottomThemeTypeLight ? [UIColor blackColor] : nil)
                         strokeThickness:1.f];
}

- (UIImage *)rectangleDottedWithSize:(CGSize)imageSize
{
    CGSize size = CGSizeMake(imageSize.width-1, imageSize.height-1);
    
    return [LGDrawer drawRectangleWithSize:size
                                 imageSize:imageSize
                           backgroundColor:nil
                                 fillColor:kTopTheme.cellBgColor
                               strokeColor:kTopTheme.separatorColor
                           strokeThickness:kTopTheme.separatorThickness
                                strokeType:LGDrawerStrokeTypeDash];
}

@end








