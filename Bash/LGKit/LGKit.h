//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

//#warning LG_DEBUG_MODE
#define LG_DEBUG_MODE 0

#if LG_DEBUG_MODE
#define LOG(...) NSLog(@"%s:%i %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define LOG(...) //
#endif

#define kDocumentsBashDirectoryURL          [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"Bash"]

#define kAppStoreId                         @"670966490"

#define kShortLink                          @"http://j.mp/17Ikvh"
#define kShortLinkVk                        @"http://vk.cc/1Vc2wq"
#define kLinkItunes                         @"https://itunes.apple.com/ru/app/id670966490"

////////// цвета

#define kColorSet(r, g, b, a)       [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:(a)]
#define kColorClear                 [UIColor clearColor]
#define kColorShadow                kColorSet(0, 0, 0, 0.5)

#define kColorBlack                 kColorSet(0, 0, 0, 1)
#define kColorWhite                 kColorSet(255, 255, 255, 1)
#define kColorRed                   kColorSet(255, 0, 0, 1)
#define kColorBlue                  kColorSet(0, 0, 255, 1)
#define kColorGreen                 kColorSet(0, 255, 0, 1)
#define kColorYellow                kColorSet(255, 255, 0, 1)
#define kColorViolet                kColorSet(128, 0, 255, 1)
#define kColorOrange                kColorSet(255, 128, 0, 1)
#define kColorAquamarine            kColorSet(125, 255, 210, 1)

////////// цветовые схемы

#define kColorSchemaWhite           kColorSet(255, 255, 255, 1)
#define kColorSchemaBlue1           kColorSet(10, 160, 250, 1)
#define kColorSchemaBlue2           kColorSet(10, 90, 200, 1)
#define kColorSchemaDutchTeal       kColorSet(20, 150, 165, 1)
#define kColorSchemaAquamarine      kColorSet(125, 255, 210, 1)
#define kColorSchemaGreenBlue       kColorSet(45, 195, 165, 1)
#define kColorSchemaGreen           kColorSet(125, 200, 25, 1)
#define kColorSchemaPurple          kColorSet(120, 85, 180, 1)
#define kColorSchemaYellow          kColorSet(255, 200, 0, 1)
#define kColorSchemaOrange          kColorSet(255, 150, 50, 1)
#define kColorSchemaRedPink         kColorSet(255, 65, 100, 1)
#define kColorSchemaPink            kColorSet(240, 60, 145, 1)

////////// ссылки

#define kNavController              [(AppDelegate *)[[UIApplication sharedApplication] delegate] rootNC]
#define kBottomView                 [[(AppDelegate *)[[UIApplication sharedApplication] delegate] rootNC] menuView]
#define kTopView                    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] rootNC] mainView]
#define kLGChapter                  [[Settings sharedManager] chapter]

////////// синглтоны

#define kStandartUserDefaults       [NSUserDefaults standardUserDefaults]
#define kFileManager                [NSFileManager defaultManager]

#define kLGInAppPurchases           [LGInAppPurchases sharedManager]
#define kLGKit                      [LGKit sharedManager]
#define kSettings                   [Settings sharedManager]
#define kLGAdMob                    [LGAdMob sharedManager]
#define kLGGoogleAnalytics          [LGGoogleAnalytics sharedManager]
#define kLGCloud                    [LGCloud sharedManager]
#define kLGVkontakte                [LGVkontakte sharedManager]
#define kLGGooglePlus               [LGGooglePlus sharedManager]
#define kInfoVC                     [InfoViewController sharedManager]
#define kVkontakte                  [Vkontakte sharedManager]
#define kBashQuotesCashDB           [BashQuotesCashDB sharedManager]
#define kBashQuotesSettingsCashDB   [BashQuotesSettingsCashDB sharedManager]
#define kLGDocuments                [LGDocuments sharedManager]
#define kLGCoreData                 [LGCoreData sharedManager]
#define kVersions                   [Versions sharedManager]
#define kPrerenderedImages          [PrerenderedImages sharedManager]

////////// дополнительно

#define kIsBottomViewOpened         [[(AppDelegate *)[[UIApplication sharedApplication] delegate] rootNC] menuView].isOpened

#define kInternetStatus             [[LGKit sharedManager] internetStatus]
#define kInternetStatusWithMessage  [[LGKit sharedManager] getInternetStatusWithMessage]

#define kBottomTheme                [[Settings sharedManager] bottomTheme]
#define kTopTheme                   [[Settings sharedManager] topTheme]

#define kColorMain                  [[Settings sharedManager] colorMain]

#define kSlideStock                 100.f

////////// покупки

#define kIsRemoveAdsPurchased       ([[NSUserDefaults standardUserDefaults] boolForKey:@"isRemoveAdsPurchased"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemoveAds33Purchased"])

//////////

#import <UIKit/UIKit.h>

@class
BashQuotesCashDB,
BashQuotesSettingsCashDB;

@interface LGKit : NSObject <NSURLConnectionDelegate>

typedef enum
{
    LGAnimationLaunch,
    LGAnimationLaunchCenter,
    
    LGAnimationTopCenter,
    LGAnimationTopRight,
    LGAnimationTopRightCenter,
    LGAnimationTopLeft,
    LGAnimationTopChange,
    LGAnimationTopChangeEndLong1,
    LGAnimationTopChangeEndLong2,
    LGAnimationTopChangeEndShort,
    
    LGAnimationBottomCenter,
    LGAnimationBottomChange,
    LGAnimationBottomChangeEnd,
    
    LGAnimationBothChange,
    LGAnimationBothChangeEnd
}
LGAnimationType;

@property (strong, nonatomic)           NSString    *searchText;
@property (assign, nonatomic)           int         isUpdating;
@property (assign, nonatomic)           NSUInteger  pagesAmount;
@property (assign, nonatomic)           NSUInteger  pagesAbyssAmount;
@property (assign, nonatomic)           NSUInteger  currentPage;
@property (assign, nonatomic)           int         currentAbyssPage;
@property (assign, nonatomic)           BOOL        isSearchResultClearing;
@property (assign, nonatomic)           BOOL        isAdMobEnabled;
@property (assign, nonatomic)           BOOL        needsToShowFirstInfo;
@property (assign, nonatomic)           BOOL        needsToShowUpdateInfo;
@property (assign, nonatomic)           BOOL        needsToShowRateReminder;
@property (assign, nonatomic)           BOOL        needsToShowVkReminder;
@property (assign, nonatomic)           BOOL        needsToShowSyncInfo;
@property (assign, nonatomic)           BOOL        needsToShowFileVersionError;

+ (instancetype)sharedManager;
- (void)initialize;

- (int)internetStatus;
- (int)getInternetStatusWithMessage;
- (void)reminderCheck;
- (void)animationWithCrossDissolveView:(UIView *)view duration:(NSTimeInterval)duration;
- (void)animationWithCrossDissolveView:(UIView *)view completionHandler:(void(^)(BOOL complete))completionHandler;
- (void)animationWithCrossDissolveView:(UIView *)view duration:(NSTimeInterval)duration completionHandler:(void(^)(BOOL complete))completionHandler;
- (void)tempAdsHide;
- (void)redrawViewAndSubviews:(UIView *)view;
- (BOOL)isDeviceOld;
- (UIImage *)circleWithColor:(UIColor *)color;
- (UIImage *)rectangleDottedWithSize:(CGSize)imageSize;

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

@end











