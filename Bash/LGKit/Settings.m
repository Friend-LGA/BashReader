//
//  Settings.m
//  Bash
//
//  Created by Friend_LGA on 03.02.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "Settings.h"
#import "LGChapter.h"
#import "LGKit.h"
#import "LGGoogleAnalytics.h"
#import "BottomThemeObject.h"
#import "TopThemeObject.h"

#pragma mark - Private

@interface Settings ()

@property (assign, nonatomic) BOOL isFirstLaunch;

@end

#pragma mark - Implementation

@implementation Settings

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
        NSLog(@"Settings: Shared Manager initialization...");
    }
	return self;
}

- (void)load
{
    LOG(@"");
    
    if (![kStandartUserDefaults boolForKey:@"isFirstLaunchDone"]) _isFirstLaunch = YES;
    
    NSData *colorMainData       = [kStandartUserDefaults objectForKey:@"colorMain"];
    
    if (colorMainData)
        _colorMain              = [NSKeyedUnarchiver unarchiveObjectWithData:colorMainData];
    else
        _colorMain              = kColorSchemaBlue1;
    
    if (kIsStandartUserDefaultsKeyExists(@"chapterType"))
        _chapter                = [LGChapter chapterWithType:(LGChapterType)[kStandartUserDefaults integerForKey:@"chapterType"]];
    else
        _chapter                = [LGChapter chapterWithType:LGChapterTypeNew];
    
    if (kIsStandartUserDefaultsKeyExists(@"bottomThemeType"))
        _bottomTheme            = [BottomThemeObject themeWithType:(BottomThemeType)[kStandartUserDefaults integerForKey:@"bottomThemeType"]];
    else
        _bottomTheme            = [BottomThemeObject themeWithType:BottomThemeTypeLight];
    
    if (kIsStandartUserDefaultsKeyExists(@"topThemeType"))
        _topTheme               = [TopThemeObject themeWithType:(TopThemeType)[kStandartUserDefaults integerForKey:@"topThemeType"]];
    else
        _topTheme               = [TopThemeObject themeWithType:TopThemeTypeLightIndent];
    
    if (kIsStandartUserDefaultsKeyExists(@"loadingFrom"))
        _loadingFrom            = (LGLoadingFromType)[kStandartUserDefaults integerForKey:@"loadingFrom"];
    else
        _loadingFrom            = LGLoadingFromInternet;
    
    if (kIsStandartUserDefaultsKeyExists(@"isCloudEnabled"))
        _isCloudEnabled         = [kStandartUserDefaults boolForKey:@"isCloudEnabled"];
    else
        _isCloudEnabled         = YES;
    
    if (kIsStandartUserDefaultsKeyExists(@"fontSize"))
        _fontSize               = [kStandartUserDefaults integerForKey:@"fontSize"];
    else
        _fontSize               = 14;
    
    if (kIsStandartUserDefaultsKeyExists(@"isNavBarHidden"))
        _isNavBarHidden         = [kStandartUserDefaults boolForKey:@"isNavBarHidden"];
    else
        _isNavBarHidden         = 0;
    
    if (kIsStandartUserDefaultsKeyExists(@"postingType"))
        _postingType            = (LGPostingType)[kStandartUserDefaults integerForKey:@"postingType"];
    else
        _postingType            = LGPostingByText;
    
    if (kIsStandartUserDefaultsKeyExists(@"quoteInfoVisibility"))
        _quoteInfoVisibility    = (LGQuoteInfoVisibility)[kStandartUserDefaults integerForKey:@"quoteInfoVisibility"];
    else
        _quoteInfoVisibility    = LGQuoteInfoVisibilityShow;

    if (kIsStandartUserDefaultsKeyExists(@"quoteMenuAction"))
        _quoteMenuAction        = (LGQuoteMenuAction)[kStandartUserDefaults integerForKey:@"quoteMenuAction"];
    else
        _quoteMenuAction        = LGQuoteMenuActionClose;
    
    if (kIsStandartUserDefaultsKeyExists(@"syncType"))
        _syncType               = (LGSyncType)[kStandartUserDefaults integerForKey:@"syncType"];
    else
        _syncType               = LGSyncBoth;
    
    if (kIsStandartUserDefaultsKeyExists(@"isAutoLockOn"))
        _isAutoLockOn           = [kStandartUserDefaults boolForKey:@"isAutoLockOn"];
    else
        _isAutoLockOn           = YES;
    
    if (kIsStandartUserDefaultsKeyExists(@"orientation"))
        _orientation            = (LGOrientation)[kStandartUserDefaults integerForKey:@"orientation"];
    else
        _orientation            = LGOrientationAuto;
    
    if (kIsStandartUserDefaultsKeyExists(@"indentVertical"))
        _indentVertical         = (LGIndent)[kStandartUserDefaults integerForKey:@"indentVertical"];
    else
    {
        _indentVertical         = (kIsDevicePhone ? LGIndentNone : LGIndentSmall);
    }
    
    if (kIsStandartUserDefaultsKeyExists(@"indentHorizontal"))
        _indentHorizontal       = (LGIndent)[kStandartUserDefaults integerForKey:@"indentHorizontal"];
    else
        _indentHorizontal       = LGIndentSmall;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:!_isAutoLockOn];
    
    NSArray *quotesNeedRatingArray = [kStandartUserDefaults objectForKey:@"quotesNeedRating"];
    
    if (quotesNeedRatingArray)
        _quotesNeedRating       = [NSMutableArray arrayWithArray:quotesNeedRatingArray];
    else
        _quotesNeedRating       = [NSMutableArray new];
        
    [self showLogs];
}

- (void)showLogs
{
    NSLog(@"Settings: Выбранный раздел ------ %@ (%i)", _chapter.name, _chapter.type);
    [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Выбранный раздел" label:[NSString stringWithFormat:@"%@ (%i)", _chapter.name, _chapter.type] value:nil];
    
    if (_loadingFrom == LGLoadingFromInternet)
    {
        NSLog(@"Settings: Загрузка цитат -------- из интернета (%i)", _loadingFrom);
        [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Загрузка цитат" label:[NSString stringWithFormat:@"Из интернета (%i)", _loadingFrom] value:nil];
    }
    else if (_loadingFrom == LGLoadingFromLocal)
    {
        NSLog(@"Settings: Загрузка цитат -------- из локальной базы (%i)", _loadingFrom);
        [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Загрузка цитат" label:[NSString stringWithFormat:@"Из локальной базы (%i)", _loadingFrom] value:nil];
    }
    
    if (_isCloudEnabled == YES)
    {
        NSLog(@"Settings: iCloud ---------------- включить (%i)", _isCloudEnabled);
        [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"iCloud" label:[NSString stringWithFormat:@"Включить (%i)", _isCloudEnabled] value:nil];
    }
    else if (_isCloudEnabled == NO)
    {
        NSLog(@"Settings: iCloud ---------------- выключить (%i)", _isCloudEnabled);
        [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"iCloud" label:[NSString stringWithFormat:@"Выключить (%i)", _isCloudEnabled] value:nil];
    }
    
    NSLog(@"Settings: Размер шрифта --------- %lu", (unsigned long)_fontSize);
    [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Размер шрифта" label:[NSString stringWithFormat:@"%lu", (unsigned long)_fontSize] value:nil];
    
    NSLog(@"Settings: Тема верхнего экрана -- %@", _topTheme.name);
    [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Тема верхнего экрана" label:_topTheme.name value:nil];
    
    NSLog(@"Settings: Тема нижнего экрана --- %@", _bottomTheme.name);
    [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Тема нижнего экрана" label:_bottomTheme.name value:nil];
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [_colorMain getRed:&red green:&green blue:&blue alpha:&alpha];
    red = red * 255; green = green * 255; blue = blue * 255;
    
    NSLog(@"Settings: Цветовая схема -------- RGB(%i, %i, %i)", (int)red, (int)green, (int)blue);
    [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Цветовая схема" label:[NSString stringWithFormat:@"RGB(%i, %i, %i)", (int)red, (int)green, (int)blue] value:nil];
    
    if (_postingType == LGPostingByText)
    {
        NSLog(@"Settings: Отправка в соц. сети -- текстом (%i)", _postingType);
        [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Отправка в соц. сети" label:[NSString stringWithFormat:@"Текстом (%i)", _postingType] value:nil];
    }
    else if (_postingType == LGPostingByPicture)
    {
        NSLog(@"Settings: Отправка в соц. сети -- картинкой (%i)", _postingType);
        [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Отправка в соц. сети" label:[NSString stringWithFormat:@"Картинкой (%i)", _postingType] value:nil];
    }
    
    if (_quoteInfoVisibility == LGQuoteInfoVisibilityShow)
    {
        NSLog(@"Settings: Информация о цитате --- показать (%i)", _quoteInfoVisibility);
        [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Информация о цитате" label:[NSString stringWithFormat:@"Показать (%i)", _quoteInfoVisibility] value:nil];
    }
    else if (_quoteInfoVisibility == LGQuoteInfoVisibilityHide)
    {
        NSLog(@"Settings: Информация о цитате --- скрыть (%i)", _quoteInfoVisibility);
        [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Информация о цитате" label:[NSString stringWithFormat:@"Скрыть (%i)", _quoteInfoVisibility] value:nil];
    }
    
    if (_isAutoLockOn == YES)
    {
        NSLog(@"Settings: Автоблокировка -------- включить (%i)", _isAutoLockOn);
        [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Автоблокировка" label:[NSString stringWithFormat:@"Включить (%i)", _isAutoLockOn] value:nil];
    }
    else if (_isAutoLockOn == NO)
    {
        NSLog(@"Settings: Автоблокировка -------- выключить (%i)", _isAutoLockOn);
        [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Автоблокировка" label:[NSString stringWithFormat:@"Выключить (%i)", _isAutoLockOn] value:nil];
    }
    
    if (_orientation == LGOrientationAuto)
    {
        NSLog(@"Settings: Ориентация ------------ авто (%i)", _orientation);
        [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Ориентация" label:[NSString stringWithFormat:@"Авто (%i)", _orientation] value:nil];
    }
    else if (_orientation == LGOrientationPortrait)
    {
        NSLog(@"Settings: Ориентация ------------ portrait (%i)", _orientation);
        [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Ориентация" label:[NSString stringWithFormat:@"Portrait (%i)", _orientation] value:nil];
    }
    else if (_orientation == LGOrientationLandscape)
    {
        NSLog(@"Settings: Ориентация ------------ landscape (%i)", _orientation);
        [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Ориентация" label:[NSString stringWithFormat:@"Landscape (%i)", _orientation] value:nil];
    }
    
    NSLog(@"Settings: Вертикальные поля ----- %i", _indentVertical);
    [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Вертикальные поля" label:[NSString stringWithFormat:@"%i", _indentVertical] value:nil];
    
    NSLog(@"Settings: Горизонтальные поля --- %i", _indentHorizontal);
    [kLGGoogleAnalytics sendEventWithCategory:@"Настройки" action:@"Горизонтальные поля" label:[NSString stringWithFormat:@"%i", _indentHorizontal] value:nil];
}

- (void)save
{
    LOG(@"");
    
    if (_isFirstLaunch) [kStandartUserDefaults setBool:YES      forKey:@"isFirstLaunchDone"];
    
    NSData *colorMainData = [NSKeyedArchiver archivedDataWithRootObject:_colorMain];
    [kStandartUserDefaults setObject:   colorMainData           forKey:@"colorMain"];
    
    [kStandartUserDefaults setInteger:  _chapter.type           forKey:@"chapterType"];
    [kStandartUserDefaults setInteger:  _bottomTheme.type       forKey:@"bottomThemeType"];
    [kStandartUserDefaults setInteger:  _topTheme.type          forKey:@"topThemeType"];
    [kStandartUserDefaults setInteger:  _loadingFrom            forKey:@"loadingFrom"];
    [kStandartUserDefaults setInteger:  _fontSize               forKey:@"fontSize"];
    [kStandartUserDefaults setBool:     _isNavBarHidden         forKey:@"isNavBarHidden"];
    [kStandartUserDefaults setInteger:  _postingType            forKey:@"postingType"];
    [kStandartUserDefaults setInteger:  _quoteInfoVisibility    forKey:@"quoteInfoVisibility"];
    [kStandartUserDefaults setInteger:  _quoteMenuAction        forKey:@"quoteMenuAction"];
    [kStandartUserDefaults setObject:   _quotesNeedRating       forKey:@"quotesNeedRating"];
    [kStandartUserDefaults setBool:     _isCloudEnabled         forKey:@"isCloudEnabled"];
    [kStandartUserDefaults setBool:     _isAutoLockOn           forKey:@"isAutoLockOn"];
    [kStandartUserDefaults setInteger:  _orientation            forKey:@"orientation"];
    [kStandartUserDefaults setInteger:  _indentVertical         forKey:@"indentVertical"];
    [kStandartUserDefaults setInteger:  _indentHorizontal       forKey:@"indentHorizontal"];
    
    [kStandartUserDefaults synchronize];
}

@end
