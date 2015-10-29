//
//  LGVersions.m
//  Bash
//
//  Created by Friend_LGA on 03.03.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "Versions.h"
#import "LGKit.h"
#import "LGVkontakte.h"
#import "BashCashQuotesDataBase_OLD.h"
#import "Settings.h"
#import "BottomThemeObject.h"
#import "TopThemeObject.h"

#pragma mark ----------------------------------------------------------------------------------------------------

@interface Versions ()

@property (assign, nonatomic) BOOL isFirstLaunch;

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation Versions

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
        NSLog(@"LGVersions: Shared Manager initialization...");
    }
	return self;
}

- (void)check
{
    LOG(@"");

    if (![[kStandartUserDefaults stringForKey:@"version"] isEqualToString:kAppVersion])
    {
        if (!kLGKit.needsToShowFirstInfo) kLGKit.needsToShowUpdateInfo = YES;
        
        [kStandartUserDefaults setBool:NO forKey:@"isRateReminderShowed"];
        [kStandartUserDefaults setBool:NO forKey:@"isVkReminderShowed"];
        
        [kStandartUserDefaults setInteger:0 forKey:@"isRateReminderShowLater"];
        [kStandartUserDefaults setInteger:0 forKey:@"isVkReminderShowLater"];
        
        NSDate *firstLaunchAfterUpdateDate = [NSDate date];
        [kStandartUserDefaults setObject:firstLaunchAfterUpdateDate forKey:@"firstLaunchAfterUpdateDate"];
        [kStandartUserDefaults setInteger:0 forKey:@"launchCounterAfterUpdate"];
        
        // сброс настроек открытых секций
        [kStandartUserDefaults removeObjectForKey:@"openedSections"];
        
        // настройки информации цитаты и меню цитаты
        
        NSMutableString *versionSavedString = [kStandartUserDefaults stringForKey:@"version"].mutableCopy;
        [versionSavedString replaceOccurrencesOfString:@"." withString:@""];
        NSUInteger versionSaved = versionSavedString.integerValue;
        
        // сброс логина вконтакте
        if (versionSaved <= 102)
        {
            // осталось от первого контакта
            if ([kStandartUserDefaults objectForKey:@"VKAccessTokenKey"])
            {
                [kStandartUserDefaults removeObjectForKey:@"VKAccessTokenKey"];
                [kStandartUserDefaults removeObjectForKey:@"VKExpirationDateKey"];
                [kStandartUserDefaults removeObjectForKey:@"VKUserID"];
            }
            
            // во избежание проблем с новым контактом
            [kLGVkontakte logout];
        }
        
        // удаление базы с кэшем (настроек ячеек а не цитат)
        if (versionSaved <= 110)
        {
            if (kSettings.syncType) kSettings.syncType--;
            
            NSError *error;
            NSArray *urlArray = [kFileManager contentsOfDirectoryAtURL:kDocumentsDirectoryURL includingPropertiesForKeys:nil options:nil error:&error];
            
            for (NSURL *url in urlArray)
                if ([url.path rangeOfString:@"Cash.sqlite"].length)
                    [kFileManager removeItemAtURL:url error:&error];
        }
        
        // сброс настроек оформления
        if (versionSaved <= 115)
        {
            kSettings.bottomTheme = [BottomThemeObject themeWithType:BottomThemeTypeLight];
            kSettings.topTheme = [TopThemeObject themeWithType:TopThemeTypeLightIndent];
            
            [kStandartUserDefaults setInteger:kSettings.bottomTheme.type forKey:@"bottomThemeType"];
            [kStandartUserDefaults setInteger:kSettings.topTheme.type forKey:@"topThemeType"];
        }
        
        // сохранение новой версии
        [kStandartUserDefaults setObject:kAppVersion forKey:@"version"];
    }
    
    // проверяем, существет ли старая база и сохраненные в облаке цитаты
    {
        if (!kIsStandartUserDefaultsKeyExists(@"needsToReplaceLocalDataBase") &&
            [[BashCashQuotesDataBase_OLD sharedManager] isExists])
            [kStandartUserDefaults setBool:YES forKey:@"needsToReplaceLocalDataBase"];
        
        if (!kIsStandartUserDefaultsKeyExists(@"needsToReplaceCloudDocument"))
            [kStandartUserDefaults setBool:YES forKey:@"needsToReplaceCloudDocument"];
    }
}

- (BOOL)isNeedsToReplaceLocalDataBase
{
    return [kStandartUserDefaults boolForKey:@"needsToReplaceLocalDataBase"];
}

- (void)setNeedsToReplaceLocalDataBase:(BOOL)needsToReplaceLocalDataBase
{
    [kStandartUserDefaults setBool:needsToReplaceLocalDataBase forKey:@"needsToReplaceLocalDataBase"];
}

- (BOOL)isNeedsToReplaceCloudDocument
{
    return [kStandartUserDefaults boolForKey:@"needsToReplaceCloudDocument"];
}

- (void)setNeedsToReplaceCloudDocument:(BOOL)needsToReplaceCloudDocument
{
    [kStandartUserDefaults setBool:needsToReplaceCloudDocument forKey:@"needsToReplaceCloudDocument"];
}

@end

















