//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "InfoView.h"
#import "InfoViewButton.h"
#import "AppDelegate.h"
#import "TopView.h"
#import "BottomView.h"
#import "LGKit.h"
#import "Settings.h"
#import "LGChapter.h"
#import "LGAdMob.h"
#import "LGCloud.h"
#import "LGCoreData.h"
#import "LGVkontakte.h"
#import "LGGooglePlus.h"
#import "LGColorConverter.h"
#import "LGGoogleAnalytics.h"
#import "BashCashQuoteObject.h"
#import "TopThemeObject.h"
#import "TopTableViewCellStandartFull.h"
#import "TopTableViewCellStandartShort.h"
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>

#pragma mark - Private

@interface InfoView ()

@property (assign, nonatomic) BOOL                  isPopViewNeedAppearDelay;
@property (assign, nonatomic) int                   indent;
@property (assign, nonatomic) CGFloat               rowHeight;
@property (assign, nonatomic) CGFloat               infoViewHeight;
@property (assign, nonatomic) LGChapterType         chapterType;
@property (assign, nonatomic) NSUInteger            butCount;
@property (assign, nonatomic) int                   animatingShift;
@property (assign, nonatomic) float                 lastStripe;
@property (assign, nonatomic) CGRect                frameTemp;
@property (assign, nonatomic) CGRect                alertFrame;
@property (assign, nonatomic) CGRect                buttonsArea;
@property (strong, nonatomic) NSString              *text;
@property (strong, nonatomic) UILabel               *textLabel;
@property (strong, nonatomic) UIView                *stripeView;

@property (assign, nonatomic) BashCashQuoteObject           *quote;
@property (assign, nonatomic) TopTableViewCellStandartFull  *cell;

@property (strong, nonatomic) InfoViewButton        *favouriteBut;
@property (strong, nonatomic) InfoViewButton        *buttonCopy;
@property (strong, nonatomic) InfoViewButton        *vkBut;
@property (strong, nonatomic) InfoViewButton        *fbBut;
@property (strong, nonatomic) InfoViewButton        *twBut;
@property (strong, nonatomic) InfoViewButton        *gpBut;
@property (strong, nonatomic) InfoViewButton        *mailBut;
@property (strong, nonatomic) InfoViewButton        *smsBut;
@property (strong, nonatomic) InfoViewButton        *photoBut;
@property (strong, nonatomic) InfoViewButton        *safariBut;
@property (strong, nonatomic) InfoViewButton        *vkFollowBut;
@property (strong, nonatomic) InfoViewButton        *rateBut;
@property (strong, nonatomic) InfoViewButton        *remindLaterBut;
@property (strong, nonatomic) InfoViewButton        *remindNeverBut;
@property (strong, nonatomic) InfoViewButton        *syncBoth;
@property (strong, nonatomic) InfoViewButton        *syncCloudToLocal;
@property (strong, nonatomic) InfoViewButton        *syncLocalToCloud;
@property (strong, nonatomic) InfoViewButton        *disableCloud;
@property (strong, nonatomic) InfoViewButton        *actionButton;
@property (strong, nonatomic) InfoViewButton        *okButton;

@end

#pragma mark - Implementation

@implementation InfoView

- (id)initWithText:(NSString *)text
{
    return [self initWithText:text type:LGInfoViewTypeTextOnly chapterType:nil quote:nil cell:nil];
}

- (id)initWithText:(NSString *)text type:(LGInfoViewType)type
{
    return [self initWithText:text type:LGInfoViewTypeTextOnly chapterType:type quote:nil cell:nil];
}

- (id)initWithText:(NSString *)text type:(LGInfoViewType)type chapterType:(LGChapterType)chapterType quote:(BashCashQuoteObject *)quote cell:(TopTableViewCellStandartFull *)cell
{
    CGRect frame = CGRectMake(0.f, 0.f, 300.f, 0.f);
    
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = kTopTheme.infoBgColor;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        
        _text = text;
        _type = type;
        _chapterType = chapterType;
        _quote = quote;
        _cell = cell;
        
        _rowHeight = 44.f;
        
        CGFloat shift = 10.f;
        
        _textLabel = [UILabel new];
        _textLabel.backgroundColor = kColorClear;
        _textLabel.frame = CGRectMake(shift, shift, frame.size.width-shift*2, CGFLOAT_MAX);
        _textLabel.textColor = (kTopTheme.isDark ? kColorWhite : kColorBlack);
        _textLabel.text = text;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        _textLabel.font = [UIFont systemFontOfSize:14];
        [_textLabel sizeToFit];
        [_textLabel layoutIfNeeded];
        _textLabel.center = CGPointMake(frame.size.width/2, shift+_textLabel.frame.size.height/2);
        _textLabel.frame = CGRectIntegral(_textLabel.frame);
        [self addSubview:_textLabel];
        
        _infoViewHeight = _textLabel.frame.size.height+shift*2;
        
        _butCount = 0;
        
        if (type == LGInfoViewTypeRateReminder || type == LGInfoViewTypeVkReminder)
        {
            if (type == LGInfoViewTypeRateReminder)
            {
                _rateBut = [[InfoViewButton alloc] initWithTitle:@"Оценить!"];
                [self addButton:_rateBut atIndex:_butCount];
                [self addSubview:_rateBut];
            }
            else
            {
                _vkFollowBut = [[InfoViewButton alloc] initWithTitle:@"Вступить!"];
                [self addButton:_vkFollowBut atIndex:_butCount];
                [self addSubview:_vkFollowBut];
            }
            _butCount++;
            
            _remindLaterBut = [[InfoViewButton alloc] initWithTitle:@"Напомнить позднее"];
            [self addButton:_remindLaterBut atIndex:_butCount];
            [self addSubview:_remindLaterBut];
            _butCount++;
            
            _remindNeverBut = [[InfoViewButton alloc] initWithTitle:@"Нет и больше не напоминать"];
            [self addButton:_remindNeverBut atIndex:_butCount];
            [self addSubview:_remindNeverBut];
            _butCount++;
        }
        else if (type == LGInfoViewTypeVersionError || type == LGInfoViewTypeCashClean)
        {
            _okButton = [[InfoViewButton alloc] initWithTitle:@"ОК"];
            [self addButton:_okButton atIndex:_butCount];
            [self addSubview:_okButton];
            _butCount++;
            
            if (type == LGInfoViewTypeCashClean) _okButton.isAnimated = YES;
        }
        else if (type == LGInfoViewTypeSync)
        {
            NSString *deviceModel = @"Девайс";
            if ([kDeviceModel rangeOfString:@"iPhone"].length != 0) deviceModel = @"iPhone";
            else if ([kDeviceModel rangeOfString:@"iPad"].length != 0) deviceModel = @"iPad";
            else if ([kDeviceModel rangeOfString:@"iPod"].length != 0) deviceModel = @"iPod";
            
            _syncBoth = [[InfoViewButton alloc] initWithTitle:[NSString stringWithFormat:@"Синхр. цитаты iCloud <--> %@", deviceModel]];
            [self addButton:_syncBoth atIndex:_butCount];
            if (kIsDevicePhone) _syncBoth.titleLabel.font = [UIFont systemFontOfSize:15];
            [self addSubview:_syncBoth];
            _butCount++;
            
            _syncCloudToLocal = [[InfoViewButton alloc] initWithTitle:[NSString stringWithFormat:@"Заменить цитаты iCloud --> %@", deviceModel]];
            [self addButton:_syncCloudToLocal atIndex:_butCount];
            if (kIsDevicePhone)_syncCloudToLocal.titleLabel.font = [UIFont systemFontOfSize:15];
            [self addSubview:_syncCloudToLocal];
            _butCount++;
            
            _syncLocalToCloud = [[InfoViewButton alloc] initWithTitle:[NSString stringWithFormat:@"Заменить цитаты %@ --> iCloud", deviceModel]];
            [self addButton:_syncLocalToCloud atIndex:_butCount];
            if (kIsDevicePhone)_syncLocalToCloud.titleLabel.font = [UIFont systemFontOfSize:15];
            [self addSubview:_syncLocalToCloud];
            _butCount++;
            
            _disableCloud = [[InfoViewButton alloc] initWithTitle:@"Отключить iCloud"];
            [self addButton:_disableCloud atIndex:_butCount];
            if (kIsDevicePhone)_disableCloud.titleLabel.font = [UIFont systemFontOfSize:15];
            [self addSubview:_disableCloud];
            _butCount++;
        }
        else if (type != LGInfoViewTypeTextOnly && type != LGInfoViewTypeFirstInfo && type != LGInfoViewTypeUpdateInfo && type != LGInfoViewTypeHelpInfo && type != LGInfoViewTypeCopyrightInfo)
        {
            _favouriteBut = [[InfoViewButton alloc] initWithTitle:(type == LGInfoViewTypeButtonsFavourites || quote.isFavourite ? @"Удалить из избранного" : @"Добавить в избранное")];
            [self addButton:_favouriteBut atIndex:_butCount];
            _favouriteBut.isAnimated = NO;
            if (type == LGInfoViewTypeButtonsFavourites || quote.isFavourite) _favouriteBut.selected = YES;
            [self addSubview:_favouriteBut];
            _butCount++;
            
            _buttonCopy = [[InfoViewButton alloc] initWithTitle:@"Скопировать цитату"];
            [self addButton:_buttonCopy atIndex:_butCount];
            _buttonCopy.isAnimated = YES;
            [self addSubview:_buttonCopy];
            _butCount++;
            
            _vkBut = [[InfoViewButton alloc] initWithTitle:@"Запостить ВКонтакте"];
            [self addButton:_vkBut atIndex:_butCount];
            _vkBut.isAnimated = YES;
            [self addSubview:_vkBut];
            _butCount++;
            
            _fbBut = [[InfoViewButton alloc] initWithTitle:@"Запостить в Facebook"];
            [self addButton:_fbBut atIndex:_butCount];
            _fbBut.isAnimated = YES;
            [self addSubview:_fbBut];
            _butCount++;
            
            _twBut = [[InfoViewButton alloc] initWithTitle:@"Запостить в Twitter"];
            [self addButton:_twBut atIndex:_butCount];
            _twBut.isAnimated = YES;
            [self addSubview:_twBut];
            _butCount++;
            
            _gpBut = [[InfoViewButton alloc] initWithTitle:@"Запостить в Google+"];
            [self addButton:_gpBut atIndex:_butCount];
            _gpBut.isAnimated = YES;
            [self addSubview:_gpBut];
            _butCount++;
            
            _mailBut = [[InfoViewButton alloc] initWithTitle:@"Отправить по почте"];
            [self addButton:_mailBut atIndex:_butCount];
            _mailBut.isAnimated = YES;
            [self addSubview:_mailBut];
            _butCount++;
            
            if ([MFMessageComposeViewController canSendText])
            {
                _smsBut = [[InfoViewButton alloc] initWithTitle:@"Отправить по SMS"];
                [self addButton:_smsBut atIndex:_butCount];
                _smsBut.isAnimated = YES;
                [self addSubview:_smsBut];
                _butCount++;
            }
            
            _photoBut = [[InfoViewButton alloc] initWithTitle:@"Сохранить в фотоплёнку"];
            [self addButton:_photoBut atIndex:_butCount];
            _photoBut.isAnimated = YES;
            [self addSubview:_photoBut];
            _butCount++;
            
            if (type == LGInfoViewTypeButtonsMain)
            {
                _safariBut = [[InfoViewButton alloc] initWithTitle:@"Открыть в Safari"];
                [self addButton:_safariBut atIndex:_butCount];
                _safariBut.isAnimated = NO;
                [self addSubview:_safariBut];
                _butCount++;
            }
        }
        
        if (_butCount)
        {
            _infoViewHeight += _rowHeight*_butCount;
            _infoViewHeight -= 1;
            
            _stripeView = [UIView new];
            _stripeView.backgroundColor = kTopTheme.infoStripeColor;
            _stripeView.frame = CGRectMake(0, _textLabel.frame.size.height+shift*2, frame.size.width, (kIsRetina ? 0.5f : 1.f));
            [self addSubview:_stripeView];
        }
        
        self.contentSize = CGSizeMake(frame.size.width, _infoViewHeight);
        
        CGFloat heightShift = 58.f;
        
        if (_infoViewHeight > kNavController.view.bounds.size.height-heightShift)
        {
            self.bounces = YES;
            self.scrollEnabled = YES;
            _infoViewHeight = kNavController.view.bounds.size.height-heightShift;
        }
        else
        {
            self.bounces = NO;
            self.scrollEnabled = NO;
        }
        
        CGSize size;
        if ((kSettings.orientation == LGOrientationAuto && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) || kSettings.orientation == LGOrientationLandscape)
            size = CGSizeMake(kMainScreenSideMax, kMainScreenSideMin);
        else
            size = CGSizeMake(kMainScreenSideMin, kMainScreenSideMax);
        
        frame = CGRectMake(size.width/2-300.f/2, size.height/2-_infoViewHeight/2, 300.f, _infoViewHeight);
        self.frame = CGRectIntegral(frame);
    }
    return self;
}

- (void)resizeAndRepositionAfterRotateToSize:(CGSize)size
{
    CGFloat heightShift = 58.f;
    
    _infoViewHeight = self.contentSize.height;
    
    if (_infoViewHeight > size.height-heightShift)
    {
        self.bounces = YES;
        self.scrollEnabled = YES;
        _infoViewHeight = size.height-heightShift;
    }
    else
    {
        self.bounces = NO;
        self.scrollEnabled = NO;
    }
    
    CGRect frame = CGRectMake(size.width/2-300.f/2, size.height/2-_infoViewHeight/2, 300.f, _infoViewHeight);
    self.frame = CGRectIntegral(frame);
}

- (void)addButton:(InfoViewButton *)button atIndex:(NSUInteger)index
{
    //LOG(@"");
    
    CGFloat shift = 10.f;
    
    button.selected = NO;
    button.frame = CGRectMake(0, _textLabel.frame.size.height+shift*2+_rowHeight*index, self.frame.size.width, _rowHeight);
    button.frame = CGRectIntegral(button.frame);
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonTapped:(InfoViewButton *)button
{
    LOG(@"");
    
    button.selected = !button.isSelected;
    
    NSLog(@"Button tapped: %@", button.titleLabel.text);
    
    _actionButton = button;
    
    if ([button isEqual:_favouriteBut]) // избранное
    {
        kNavController.view.userInteractionEnabled = NO;
        
        if (kLGChapter.type == LGChapterTypeFavourites) // удалить из избранного (раздел - избранное)
        {
            [kLGCoreData removeQuoteFromFavourites:_quote];
            
            [kTopView tableViewDeleteTappedRow];
            
            [kInfoVC remove];
            
            kNavController.view.userInteractionEnabled = YES;
            
            [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Quote Menu)" action:@"Удалить из избранного" label:nil value:nil];
        }
        else
        {
            if (button.isSelected) // добавить в избранное
            {
                [kLGCoreData addQuoteToFavourites:_quote];
                
                button.titleLabel.text = @"Удалить из избранного";
                
                [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Quote Menu)" action:@"Добавить в избранное" label:nil value:nil];
            }
            else // удалить из избранного
            {
                [kLGCoreData removeQuoteFromFavourites:_quote];
                
                button.titleLabel.text = @"Добавить в избранное";
                
                [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Quote Menu)" action:@"Удалить из избранного" label:nil value:nil];
            }
            
            [button.titleLabel sizeToFit];
            [button.titleLabel layoutIfNeeded];
            button.titleLabel.center = CGPointMake(button.frame.size.width/2, button.frame.size.height/2);
            button.titleLabel.frame = CGRectIntegral(button.titleLabel.frame);
            
            if ([_cell isKindOfClass:[TopTableViewCellStandartFull class]] ||
                [_cell isKindOfClass:[TopTableViewCellStandartShort class]])
                [_cell selectFavouriteButtonWithAction:NO];
            else
                _quote.isFavourite = !_quote.isFavourite;
            
            [kLGKit animationWithCrossDissolveView:button.titleLabel duration:0.3 completionHandler:^(BOOL complete)
             {
                 if (kSettings.quoteMenuAction == LGQuoteMenuActionClose) [kInfoVC remove];
                 else kNavController.view.userInteractionEnabled = YES;
             }];
        }
    }
    else if ([button isEqual:_buttonCopy]) // скопировать цитату
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _quote.text;
        
        [button doneAction];
        if (kSettings.quoteMenuAction == LGQuoteMenuActionClose) [kInfoVC remove];
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Quote Menu)" action:@"Скопировать цитату" label:nil value:nil];
    }
    else if ([button isEqual:_vkBut]) // запостить вконтакте
    {
        if (kInternetStatusWithMessage)
        {
            __weak typeof(button) wbutton = button;
            
            if (kSettings.postingType == LGPostingByText)
            {
                [kLGVkontakte postWithText:[NSString stringWithFormat:@"@club51449639 (ApogeeStudio) | #bash #баш #юмор\n\n%@", _quote.text]
                                     image:nil
                                      link:[NSURL URLWithString:kLinkItunes]
                         completionHandler:^(BOOL result)
                 {
                     if (wbutton)
                     {
                         if (result)
                         {
                             [wbutton doneAction];
                             if (kSettings.quoteMenuAction == LGQuoteMenuActionClose) [kInfoVC remove];
                             if (!kIsRemoveAdsPurchased) [kLGKit tempAdsHide];
                         }
                         else
                         {
                             [wbutton undoneAction];
                             [kInfoVC showInfoWithText:@"Операция была отменена или при отправлении цитаты произошла ошибка."];
                         }
                     }
                 }];
            }
            else
            {
                UIImage *capturedImage = [LGHelper makeScreenshotOfView:_cell.textLabel inPixels:YES];
                capturedImage = [LGHelper image:capturedImage
                             cropCenterWithSize:CGSizeMake(capturedImage.size.width+20.f, capturedImage.size.height+20.f)
                                backgroundColor:kTopTheme.cellBgColor
                                       inPixels:YES];
                
                [kLGVkontakte postWithText:@"@club51449639 (ApogeeStudio) | #bash #баш #юмор"
                                     image:[UIImage imageWithData:UIImagePNGRepresentation(capturedImage)]
                                      link:[NSURL URLWithString:kLinkItunes]
                         completionHandler:^(BOOL result)
                 {
                     if (wbutton)
                     {
                         if (result)
                         {
                             [wbutton doneAction];
                             if (kSettings.quoteMenuAction == LGQuoteMenuActionClose) [kInfoVC remove];
                             if (!kIsRemoveAdsPurchased) [kLGKit tempAdsHide];
                         }
                         else
                         {
                             [wbutton undoneAction];
                             [kInfoVC showInfoWithText:@"Операция была отменена или при отправлении цитаты произошла ошибка."];
                         }
                     }
                 }];
            }
        }
        else [button undoneAction];
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Quote Menu)" action:@"Запостить Вконтакте" label:nil value:nil];
    }
    else if ([button isEqual:_fbBut]) // запостить на фэйсбук
    {
        if (kInternetStatusWithMessage)
        {
            UIImage *capturedImage = [LGHelper makeScreenshotOfView:_cell.textLabel inPixels:YES];
            capturedImage = [LGHelper image:capturedImage
                         cropCenterWithSize:CGSizeMake(capturedImage.size.width+20.f, capturedImage.size.height+20.f)
                            backgroundColor:kTopTheme.cellBgColor
                                   inPixels:YES];
            
            SLComposeViewController *facebookVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            [facebookVC setCompletionHandler:^(SLComposeViewControllerResult result)
             {
                 if (result == SLComposeViewControllerResultDone)
                 {
                     [button doneAction];
                     if (kSettings.quoteMenuAction == LGQuoteMenuActionClose) [kInfoVC remove];
                     if (!kIsRemoveAdsPurchased) [kLGKit tempAdsHide];
                 }
                 else
                 {
                     [button undoneAction];
                     [kInfoVC showInfoWithText:@"Операция была отменена или при отправлении цитаты произошла ошибка."];
                 }
                 
                 [kNavController dismissViewControllerAnimated:YES completion:nil];
             }];
            
            if (kSettings.postingType == LGPostingByText)
            {
                [facebookVC setInitialText:[NSString stringWithFormat:@"#bash #баш #юмор\n\n%@", _quote.text]];
                [facebookVC addImage:nil];
                [facebookVC addURL:[NSURL URLWithString:kLinkItunes]];
            }
            else
            {
                [facebookVC setInitialText:[NSString stringWithFormat:@"#bash #баш #юмор\nBash.Reader для iPhone / iPad - %@", kShortLink]];
                [facebookVC addImage:[UIImage imageWithData:UIImagePNGRepresentation(capturedImage)]];
                [facebookVC addURL:nil];
            }
            
            [kNavController presentViewController:facebookVC animated:YES completion:nil];
        }
        else [button undoneAction];
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Quote Menu)" action:@"Запостить в Facebook" label:nil value:nil];
    }
    else if ([button isEqual:_twBut]) // запостить в твиттер
    {
        if (kInternetStatusWithMessage)
        {
            UIImage *capturedImage = [LGHelper makeScreenshotOfView:_cell.textLabel inPixels:YES];
            capturedImage = [LGHelper image:capturedImage
                         cropCenterWithSize:CGSizeMake(capturedImage.size.width+20.f, capturedImage.size.height+20.f)
                            backgroundColor:kTopTheme.cellBgColor
                                   inPixels:YES];
            
            SLComposeViewController *twitterVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            [twitterVC setCompletionHandler:^(SLComposeViewControllerResult result)
             {
                 if (result == SLComposeViewControllerResultDone)
                 {
                     [button doneAction];
                     if (kSettings.quoteMenuAction == LGQuoteMenuActionClose) [kInfoVC remove];
                     if (!kIsRemoveAdsPurchased) [kLGKit tempAdsHide];
                 }
                 else
                 {
                     [button undoneAction];
                     [kInfoVC showInfoWithText:@"Операция была отменена или при отправлении цитаты произошла ошибка."];
                 }
                 
                 [kNavController dismissViewControllerAnimated:YES completion:nil];
             }];
            
            [twitterVC setInitialText:[NSString stringWithFormat:@"@ApogeeStudioRu #bash #баш\nBash.Reader для iPhone / iPad - %@", kShortLink]];
            [twitterVC addImage:[UIImage imageWithData:UIImagePNGRepresentation(capturedImage)]];
            
            [kNavController presentViewController:twitterVC animated:YES completion:nil];
        }
        else [button undoneAction];
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Quote Menu)" action:@"Запостить в Twitter" label:nil value:nil];
    }
    else if ([button isEqual:_gpBut]) // запостить в google+
    {
        if (kInternetStatusWithMessage)
        {
            __weak typeof(button) wbutton = button;
            
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            CGSize size = kNavController.view.bounds.size;
            
            if (kSettings.postingType == LGPostingByText)
            {
                [kLGGooglePlus postWithText:[NSString stringWithFormat:@"#bash #баш #юмор\n\n%@", _quote.text]
                                      image:nil
                                       link:[NSURL URLWithString:kLinkItunes]
                          completionHandler:^(BOOL result)
                 {
                     if (wbutton)
                     {
                         [[UIApplication sharedApplication] setStatusBarOrientation:orientation];
                         [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
                         
                         if (!CGSizeEqualToSize(size, kNavController.view.bounds.size))
                         {
                             [kNavController resizeViewsToSize:size];
                             [kNavController updateMainViewAfterRotate];
                         }
                         
                         if (result)
                         {
                             [wbutton doneAction];
                             if (kSettings.quoteMenuAction == LGQuoteMenuActionClose) [kInfoVC remove];
                             if (!kIsRemoveAdsPurchased) [kLGKit tempAdsHide];
                         }
                         else
                         {
                             [wbutton undoneAction];
                             [kInfoVC showInfoWithText:@"Операция была отменена или при отправлении цитаты произошла ошибка."];
                         }
                     }
                 }];
            }
            else
            {
                UIImage *capturedImage = [LGHelper makeScreenshotOfView:_cell.textLabel inPixels:YES];
                capturedImage = [LGHelper image:capturedImage
                             cropCenterWithSize:CGSizeMake(capturedImage.size.width+20.f, capturedImage.size.height+20.f)
                                backgroundColor:kTopTheme.cellBgColor
                                       inPixels:YES];
                
                [kLGGooglePlus postWithText:@"#bash #баш #юмор"
                                      image:[UIImage imageWithData:UIImagePNGRepresentation(capturedImage)]
                                       link:nil
                          completionHandler:^(BOOL result)
                 {
                     if (wbutton)
                     {
                         if (result)
                         {
                             [wbutton doneAction];
                             if (kSettings.quoteMenuAction == LGQuoteMenuActionClose) [kInfoVC remove];
                             if (!kIsRemoveAdsPurchased) [kLGKit tempAdsHide];
                         }
                         else
                         {
                             [wbutton undoneAction];
                             [kInfoVC showInfoWithText:@"Операция была отменена или при отправлении цитаты произошла ошибка."];
                         }
                     }
                 }];
            }
        }
        else [button undoneAction];
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Quote Menu)" action:@"Запостить в Google+" label:nil value:nil];
    }
    else if ([button isEqual:_mailBut]) // отправить по почте
    {
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailer = [MFMailComposeViewController new];
            mailer.mailComposeDelegate = self;
            [mailer setSubject:@"Зацени цитату с баша :)"];
            [mailer setMessageBody:[NSString stringWithFormat:@"%@\n\n\nBash.Reader для iPhone / iPad - %@", _quote.text, kShortLink] isHTML:NO];
            
            if (kIsDevicePad) mailer.modalPresentationStyle = UIModalPresentationFormSheet;
            
            [kNavController presentViewController:mailer animated:YES completion:nil];
        }
        else
        {
            [button undoneAction];
            
            [kInfoVC showInfoWithText:@"У вас не настроена почта."];
        }
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Quote Menu)" action:@"Отправить по почте" label:nil value:nil];
    }
    else if ([button isEqual:_smsBut]) // отправить по SMS
    {
        if ([MFMessageComposeViewController canSendText])
        {
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate = self;
            [picker setBody:[NSString stringWithFormat:@"%@\n\nBash.Reader - %@", _quote.text, kShortLink]];
            
            [kNavController presentViewController:picker animated:YES completion:nil];
        }
        else
        {
            [button undoneAction];
            
            [kInfoVC showInfoWithText:@"Вы не можете отправлять SMS."];
        }
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Quote Menu)" action:@"Отправить по SMS" label:nil value:nil];
    }
    else if ([button isEqual:_photoBut]) // сохранить в фотопленку
    {
        UIImage *capturedImage = [LGHelper makeScreenshotOfView:_cell.textLabel inPixels:NO];
        capturedImage = [LGHelper image:capturedImage
                     cropCenterWithSize:CGSizeMake(capturedImage.size.width+20.f, capturedImage.size.height+20.f)
                        backgroundColor:kTopTheme.cellBgColor
                               inPixels:NO];
        
        UIImageWriteToSavedPhotosAlbum(capturedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Quote Menu)" action:@"Сохранить в фотопленку" label:nil value:nil];
    }
    else if ([button isEqual:_safariBut]) // открыть в сафари
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://bash.im/quote/%lu", (unsigned long)_quote.number]]];
        
        if (kSettings.quoteMenuAction == LGQuoteMenuActionClose) [kInfoVC remove];
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Quote Menu)" action:@"Открыть в сафари" label:nil value:nil];
    }
    else if ([button isEqual:_rateBut]) // оценить
    {
        if (kInternetStatusWithMessage)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", kAppStoreId]]];
            
            [kStandartUserDefaults setBool:YES forKey:@"isRateReminderShowed"];
            
            [kInfoVC remove];
        }
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Rate App Reminder)" action:@"Оценить!" label:nil value:nil];
    }
    else if ([button isEqual:_vkFollowBut]) // подписаться вконтакте
    {
        if (kInternetStatusWithMessage)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://vk.com/apogeestudio"]];
            
            [kStandartUserDefaults setBool:YES forKey:@"isVkReminderShowed"];
            
            [kInfoVC remove];
        }
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Vkontakte Reminder)" action:@"Вступить!" label:nil value:nil];
    }
    else if ([button isEqual:_remindLaterBut]) // напомнить позже
    {
        NSDate *firstLaunchAfterUpdateDate = [kStandartUserDefaults objectForKey:@"firstLaunchAfterUpdateDate"];
        int daysSinceFirstLaunchAfterUpdate = [[NSDate date] timeIntervalSinceDate:firstLaunchAfterUpdateDate]/60/60/24;
        
        if (_type == LGInfoViewTypeRateReminder) [kStandartUserDefaults setInteger:daysSinceFirstLaunchAfterUpdate+4 forKey:@"isRateReminderShowLater"];
        else if (_type == LGInfoViewTypeVkReminder) [kStandartUserDefaults setInteger:daysSinceFirstLaunchAfterUpdate+4 forKey:@"isVkReminderShowLater"];
        
        [kInfoVC remove];
        
        if (_type == LGInfoViewTypeRateReminder) [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Rate App Reminder)" action:@"Напомнить позже" label:nil value:nil];
        else if (_type == LGInfoViewTypeVkReminder) [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Vkontakte Reminder)" action:@"Напомнить позже" label:nil value:nil];
    }
    else if ([button isEqual:_remindNeverBut]) // больше не напоминать
    {
        if (_type == LGInfoViewTypeRateReminder) [kStandartUserDefaults setBool:YES forKey:@"isRateReminderShowed"];
        else if (_type == LGInfoViewTypeVkReminder) [kStandartUserDefaults setBool:YES forKey:@"isVkReminderShowed"];
        
        [kInfoVC remove];
        
        if (_type == LGInfoViewTypeRateReminder) [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Rate App Reminder)" action:@"Больше не напоминать" label:nil value:nil];
        else if (_type == LGInfoViewTypeVkReminder) [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Vkontakte Reminder)" action:@"Больше не напоминать" label:nil value:nil];
    }
    else if ([button isEqual:_syncBoth]) // iCloud <--> Local
    {
        kSettings.syncType = LGSyncBoth;
        [kStandartUserDefaults setInteger:kSettings.syncType forKey:@"syncType"];
        
        [kLGCloud saveNewTokenAndSyncInfo];
        
        [kInfoVC remove];
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (iCloud Info)" action:@"Синхронизовать iCloud <--> Local" label:nil value:nil];
    }
    else if ([button isEqual:_syncCloudToLocal]) // iCloud --> Local
    {
        kSettings.syncType = LGSyncCloudToLocal;
        [kStandartUserDefaults setInteger:kSettings.syncType forKey:@"syncType"];
        
        [kLGCloud saveNewTokenAndSyncInfo];
        
        [kInfoVC remove];
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (iCloud Info)" action:@"Синхронизовать iCloud --> Local" label:nil value:nil];
    }
    else if ([button isEqual:_syncLocalToCloud]) // Local --> iCloud
    {
        kSettings.syncType = LGSyncLocalToCloud;
        [kStandartUserDefaults setInteger:kSettings.syncType forKey:@"syncType"];
        
        [kLGCloud saveNewTokenAndSyncInfo];
        
        [kInfoVC remove];
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (iCloud Info)" action:@"Синхронизовать Local --> iCloud" label:nil value:nil];
    }
    else if ([button isEqual:_disableCloud]) // отключить iCloud
    {
        [kLGCloud disableCloud];
        
        if (kLGChapter.type == LGChapterTypeFavourites) [kTopView tableViewLoadQuotes];
        
        [kBottomView tableViewSetCloudSettingsTo:NO];
        
        [kInfoVC remove];
        
        [kLGGoogleAnalytics sendEventWithCategory:@"Info View (iCloud Info)" action:@"Отключить iCloud" label:nil value:nil];
    }
    else if ([button isEqual:_okButton]) // не соответствие версий файлов
    {
        if (_type == LGInfoViewTypeVersionError)
        {
            [kInfoVC remove];
            
            [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Version Error)" action:nil label:nil value:nil];
        }
        else if (_type == LGInfoViewTypeCashClean)
        {
            [kLGGoogleAnalytics sendEventWithCategory:@"Info View (Cash Clean)" action:nil label:nil value:nil];
            
            kNavController.view.userInteractionEnabled = NO;
            
            [kTopView tableViewCancelLoading];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                           {
                               [kLGCoreData removeQuotesInCash];
                               
                               if (kLGChapter.type != LGChapterTypeFavourites)
                               {
                                   dispatch_async(dispatch_get_main_queue(), ^(void)
                                                  {
                                                      [kTopView reload];
                                                  });
                               }
                               
                               dispatch_async(dispatch_get_main_queue(), ^(void)
                                              {
                                                  [kInfoVC remove];
                                                  
                                                  kNavController.view.userInteractionEnabled = YES;
                                              });
                           });
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    LOG(@"");
    
    if (!error)
    {
        [_actionButton doneAction];
        if (kSettings.quoteMenuAction == LGQuoteMenuActionClose) [kInfoVC remove];
    }
    else
    {
        [_actionButton undoneAction];
        
        [kInfoVC showInfoWithText:@"При сохранении цитаты произошла ошибка."];
    }
}

#pragma mark - Mail/SMS Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    LOG(@"");
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            [_actionButton undoneAction];
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            [_actionButton doneAction];
            if (kSettings.quoteMenuAction == LGQuoteMenuActionClose) [kInfoVC remove];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            [_actionButton doneAction];
            if (kSettings.quoteMenuAction == LGQuoteMenuActionClose) [kInfoVC remove];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            [_actionButton undoneAction];
            [kInfoVC showInfoWithText:@"При отправлении цитаты произошла ошибка."];
            break;
        default:
            [_actionButton undoneAction];
            NSLog(@"Mail not sent.");
            break;
    }
    
    [kNavController dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    LOG(@"");
    
    switch (result)
    {
        case MessageComposeResultCancelled:
            NSLog(@"Result: SMS sending canceled");
            [_actionButton undoneAction];
            break;
        case MessageComposeResultSent:
            NSLog(@"Result: SMS sent");
            [_actionButton doneAction];
            if (kSettings.quoteMenuAction == LGQuoteMenuActionClose) [kInfoVC remove];
            break;
        case MessageComposeResultFailed:
            NSLog(@"Result: SMS sending failed");
            [_actionButton undoneAction];
            [kInfoVC showInfoWithText:@"При отправлении цитаты произошла ошибка."];
            break;
        default:
            [_actionButton undoneAction];
            NSLog(@"Result: SMS not sent");
            break;
    }
    
    [kNavController dismissViewControllerAnimated:YES completion:nil];
}

@end








