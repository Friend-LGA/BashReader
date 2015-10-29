//
//  InfoViewController.m
//  Bash
//
//  Created by Friend_LGA on 04.01.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "InfoViewController.h"
#import "InfoView.h"
#import "TopView.h"
#import "AppDelegate.h"
#import "LGKit.h"
#import "LGAdMob.h"
#import "LGGoogleAnalytics.h"
#import "Settings.h"
#import "BashCashQuoteObject.h"
#import "TopTableViewCellStandartFull.h"
#import "PrerenderedImages.h"

#pragma mark - Private

@interface InfoViewController ()

@property (strong, nonatomic) NSMutableArray    *viewsArray;
@property (assign, nonatomic) BOOL              canClosedByTouch;

@end

#pragma mark - Implementation

@implementation InfoViewController

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
    if ((self = [super init]))
    {
        NSLog(@"InfoViewController: Initialising...");
        
        _viewsArray = [NSMutableArray new];
    }
    return self;
}

- (void)initialize
{
    LOG(@"");
}

- (void)resizeAndRepositionAfterRotateToSize:(CGSize)size
{
    for (NSDictionary *viewsDictionary in _viewsArray)
    {
        UIView *backgroundView = viewsDictionary[@"backgroundView"];
        backgroundView.frame = CGRectMake(0, 0, size.width, size.height);

        InfoView *infoView = viewsDictionary[@"infoView"];
        [infoView resizeAndRepositionAfterRotateToSize:size];

        UIImageView *closeButton = viewsDictionary[@"closeButton"];
        if (closeButton)
        {
            closeButton.center = CGPointMake(infoView.frame.origin.x+5.f, infoView.frame.origin.y+5.f);
            closeButton.frame = CGRectIntegral(closeButton.frame);
        }
    }
}

- (void)showInfoWithText:(NSString *)text
{
    [self showInfoWithText:text type:LGInfoViewTypeTextOnly chapterType:nil quote:nil cell:nil];
}

- (void)showInfoWithText:(NSString *)text type:(LGInfoViewType)type
{
    [self showInfoWithText:text type:type chapterType:nil quote:nil cell:nil];
}

- (void)showInfoWithText:(NSString *)text type:(LGInfoViewType)type chapterType:(LGChapterType)chapterType quote:(BashCashQuoteObject *)quote cell:(TopTableViewCellStandartFull *)cell
{
    LOG(@"");
    
    kNavController.view.userInteractionEnabled = NO;

    _canClosedByTouch = (type != LGInfoViewTypeRateReminder && type != LGInfoViewTypeVkReminder && type != LGInfoViewTypeSync && type != LGInfoViewTypeVersionError);
    
    if (_isPopViewOnScreen)
    {
        [self hideLastViewAndRemove:NO completionHandler:nil];
    }
    
    _isPopViewOnScreen = YES;
    
    // google analytics
    /*
     NSString *googleAnalyticsLabel;
     if (type == LGInfoViewTypeFirstInfo)            googleAnalyticsLabel = @"First Info";
     else if (type == LGInfoViewTypeUpdateInfo)      googleAnalyticsLabel = @"Update Info";
     else if (type == LGInfoViewTypeHelpInfo)        googleAnalyticsLabel = @"Help Info";
     else if (type == LGInfoViewTypeCopyrightInfo)   googleAnalyticsLabel = @"Copyright Info";
     else if (type == LGInfoViewTypeVkReminder)      googleAnalyticsLabel = @"Vkontakte Reminder";
     else if (type == LGInfoViewTypeRateReminder)    googleAnalyticsLabel = @"Rate App Reminder";
     else if (type == LGInfoViewTypeSync)            googleAnalyticsLabel = @"iCloud Info";
     else if (type == LGInfoViewTypeCashClean)       googleAnalyticsLabel = @"Cash Clean";
     else if (type == LGInfoViewTypeVersionError)    googleAnalyticsLabel = @"iCloud File Version Error";
     else if (type == LGInfoViewTypeButtonsMain || type == LGInfoViewTypeButtonsAbyss || type == LGInfoViewTypeButtonsFavourites) googleAnalyticsLabel = @"Quote Menu";
     
     [kLGGoogleAnalytics sendEventWithCategory:@"Info View" action:@"Open" label:googleAnalyticsLabel value:nil];
     */
    //
    
    [kTopView endEditing:YES];
    
    CGSize size;
    if ((kSettings.orientation == LGOrientationAuto && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) || kSettings.orientation == LGOrientationLandscape)
        size = CGSizeMake(kMainScreenSideMax, kMainScreenSideMin);
    else
        size = CGSizeMake(kMainScreenSideMin, kMainScreenSideMax);
    
    // ---------------------------------------------
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, size.width, size.height)];
    backgroundView.backgroundColor = kColorBlack;
    backgroundView.alpha = 0.f;
    [kNavController.view addSubview:backgroundView];
    
    // ---------------------------------------------
    
    InfoView *infoView = [[InfoView alloc] initWithText:text
                                                   type:type
                                            chapterType:chapterType
                                                  quote:quote
                                                   cell:cell];
    infoView.alpha = 0.f;
    infoView.transform = CGAffineTransformMakeScale(1.125, 1.125);
    [kNavController.view addSubview:infoView];
    
    NSDictionary *viewDictionary;
    UIButton *closeButton;
    
    if (_canClosedByTouch)
    {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remove)];
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [backgroundView addGestureRecognizer:tapGesture];
        
        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:kPrerenderedImages.closeImage forState:UIControlStateNormal];
        [closeButton sizeToFit];
        [closeButton layoutIfNeeded];
        [closeButton addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
        closeButton.center = CGPointMake(infoView.frame.origin.x+5.f, infoView.frame.origin.y+5.f);
        closeButton.alpha = 0;
        closeButton.transform = CGAffineTransformMakeScale(1.125, 1.125);
        [kNavController.view addSubview:closeButton];
        
        viewDictionary = @{@"backgroundView"  : backgroundView,
                           @"infoView"        : infoView,
                           @"closeButton"  : closeButton};
    }
    else
    {
        viewDictionary = @{@"backgroundView"  : backgroundView,
                           @"infoView"        : infoView};
    }
    
    [_viewsArray addObject:viewDictionary];
    
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         backgroundView.alpha = 0.5;
         
         infoView.alpha = 1.f;
         infoView.transform = CGAffineTransformMakeScale(1.f, 1.f);
         
         if (closeButton)
         {
             closeButton.alpha = 1.f;
             closeButton.transform = CGAffineTransformMakeScale(1.f, 1.f);
             closeButton.center = CGPointMake(infoView.frame.origin.x+5.f, infoView.frame.origin.y+5.f);
         }
     }
                     completion:^(BOOL finished)
     {
         if (closeButton)
             closeButton.frame = CGRectIntegral(closeButton.frame);
         
         [infoView flashScrollIndicators];
         
         kNavController.view.userInteractionEnabled = YES;
     }];
}

- (void)showLastView
{
    LOG(@"");
    
    if (_viewsArray.count)
    {
        kNavController.view.userInteractionEnabled = NO;
        
        _isPopViewOnScreen = YES;
        
        NSDictionary *viewsDictionary = _viewsArray.lastObject;
        
        UIView *backgroundView = viewsDictionary[@"backgroundView"];
        backgroundView.alpha = 0.f;
        
        InfoView *infoView = viewsDictionary[@"infoView"];
        infoView.alpha = 0.f;
        infoView.transform = CGAffineTransformMakeScale(1.125, 1.125);
        
        UIImageView *closeButton = viewsDictionary[@"closeButton"];
        if (closeButton)
        {
            closeButton.center = CGPointMake(infoView.frame.origin.x+5.f, infoView.frame.origin.y+5.f);
            closeButton.alpha = 0.f;
            closeButton.transform = CGAffineTransformMakeScale(1.125, 1.125);
        }
        
        [UIView animateWithDuration:0.3 animations:^(void)
         {
             backgroundView.alpha = 0.5;
             infoView.alpha = 1.f;
             infoView.transform = CGAffineTransformMakeScale(1.f, 1.f);
             
             if (closeButton)
             {
                 closeButton.center = CGPointMake(infoView.frame.origin.x+5.f, infoView.frame.origin.y+5.f);
                 closeButton.alpha = 1.f;
                 closeButton.transform = CGAffineTransformMakeScale(1.f, 1.f);
             }
         }
                         completion:^(BOOL finished)
         {
             if (closeButton)
                 closeButton.frame = CGRectIntegral(closeButton.frame);
             
             kNavController.view.userInteractionEnabled = YES;
         }];
    }
    else
    {
        _isPopViewOnScreen = NO;
        
        kNavController.view.userInteractionEnabled = YES;
    }
}

- (void)remove
{
    LOG(@"");
    
    [self hideLastViewAndRemove:YES completionHandler:nil];
    
    [self showLastView];
}

- (void)hideLastViewAndRemove:(BOOL)remove completionHandler:(void(^)())completionHandler
{
    LOG(@"");
    
    if (_viewsArray.count)
    {
        kNavController.view.userInteractionEnabled = NO;
        
        NSDictionary *viewsDictionary = _viewsArray.lastObject;
        
        UIView *backgroundView = viewsDictionary[@"backgroundView"];
        InfoView *infoView = viewsDictionary[@"infoView"];
        UIImageView *closeButton = viewsDictionary[@"closeButton"];
        
        if (remove) [_viewsArray removeLastObject];
        
        [UIView animateWithDuration:0.3 animations:^(void)
         {
             backgroundView.alpha = 0.f;
             infoView.alpha = 0.f;
             infoView.transform = CGAffineTransformMakeScale(0.875, 0.875);
             
             if (closeButton)
             {
                 closeButton.center = CGPointMake(infoView.frame.origin.x+5.f, infoView.frame.origin.y+5.f);
                 closeButton.alpha = 0.f;
                 closeButton.transform = CGAffineTransformMakeScale(0.875, 0.875);
             }
         }
                         completion:^(BOOL finished)
         {
             if (remove)
             {
                 [backgroundView removeFromSuperview];
                 [infoView removeFromSuperview];
                 if (closeButton) [closeButton removeFromSuperview];
             }
             else
             {
                 infoView.transform = CGAffineTransformMakeScale(1.f, 1.f);
                 if (closeButton) closeButton.transform = CGAffineTransformMakeScale(1.f, 1.f);
             }
             
             if (completionHandler) completionHandler();
         }];
    }
}

@end












