//
//  TopView.m
//  Bash
//
//  Created by Friend_LGA on 26.12.13.
//  Copyright (c) 2013 Grigory Lutkov. All rights reserved.
//

#import "TopView.h"
#import "TopTableView.h"
#import "NavBarView.h"
#import "LGKit.h"
#import "Settings.h"
#import "LGAdMob.h"
#import "LGChapter.h"
#import "AppDelegate.h"
#import "BottomView.h"
#import "TopThemeObject.h"
#import "LGGoogleAnalytics.h"
#import "TopTableViewController.h"
#import "TopTableViewControllerNew.h"
#import "TopTableViewControllerBest.h"
#import "TopTableViewControllerRating.h"
#import "TopTableViewControllerAbyss.h"
#import "TopTableViewControllerAbyssTop.h"
#import "TopTableViewControllerAbyssBest.h"
#import "TopTableViewControllerRandom.h"
#import "TopTableViewControllerSearch.h"
#import "TopTableViewControllerFavourites.h"

#pragma mark - Private

@interface TopView ()

@property (strong, nonatomic) NavBarView                *navBarView;
@property (strong, nonatomic) TopTableViewController    *tableViewController;
@property (strong, nonatomic) UIView                    *statusBarView;
@property (strong, nonatomic) UIView                    *statusBarStripeView;
@property (assign, nonatomic) CGFloat                   keyboardHeight;
@property (assign, nonatomic) UIView                    *bannerView;

@end

#pragma mark - Implementation

@implementation TopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = kTopTheme.backgroundColor;
        self.userInteractionEnabled = YES;
        
        [LGHelper keyboardNotificationsAddToTarget:self selector:@selector(keyboardNotification:)];
        
        [self reload];
        
        if (kLGKit.isAdMobEnabled)
        {
            _bannerView = [kLGAdMob initialize];
            _bannerView.center = CGPointMake(frame.size.width/2, frame.size.height-_bannerView.frame.size.height/2);
            [self addSubview:_bannerView];
            
            [kLGAdMob sendRequest];
        }
    }
    return self;
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    self.backgroundColor = kTopTheme.backgroundColor;
    _statusBarStripeView.backgroundColor = kTopTheme.navBarStripeColor;
}

#pragma mark -

- (void)resizeAndRepositionAfterRotateToSize:(CGSize)size
{
    _tableViewController.tableView.frame = CGRectMake(0.f, 0.f, size.width, size.height);
    
    [self tableViewContentInsetUpdateWithSize:size];
    
    [_navBarView resizeAndRepositionAfterRotateToSize:size];
    
    //_navBarView.frame = CGRectMake(0.f, (kSettings.isNavBarHidden ? -64.f : 0.f), size.width, 64.f);
    _statusBarView.frame = CGRectMake(0.f, 0.f, size.width, 20.f);
    _statusBarStripeView.frame = CGRectMake(0, _statusBarView.frame.size.height, _statusBarView.frame.size.width, kTopTheme.navBarStripeThickness);
}

- (void)keyboardNotification:(NSNotification *)notification
{
    NSDictionary *info      = notification.userInfo;
    NSValue      *value     = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame         = [value CGRectValue];
    CGRect keyboardFrame    = [self convertRect:rawFrame fromView:nil];
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification])
        _keyboardHeight = keyboardFrame.size.height;
    else
        _keyboardHeight = 0.f;
    
    [self tableViewContentInsetUpdate];
}

- (void)reload;
{
    LOG(@"");
    
    CGRect frame = self.frame;
    
    // ------------------------------------------------------------------------------------------------------
    
    if (_statusBarView)
    {
        [_statusBarStripeView removeFromSuperview];
        _statusBarStripeView = nil;
        
        [_statusBarView removeFromSuperview];
        _statusBarView = nil;
    }
    
    if (_navBarView)
    {
        [_navBarView removeFromSuperview];
        _navBarView = nil;
    }
    
    if (_tableViewController)
    {
        [_tableViewController.tableView removeFromSuperview];
        _tableViewController.tableView = nil;
        _tableViewController = nil;
    }
    
    // ------------------------------------------------------------------------------------------------------
    
    if (kLGChapter.type == LGChapterTypeNew)                _tableViewController = [TopTableViewControllerNew new];
    else if (kLGChapter.type == LGChapterTypeBest)          _tableViewController = [TopTableViewControllerBest new];
    else if (kLGChapter.type == LGChapterTypeRating)        _tableViewController = [TopTableViewControllerRating new];
    else if (kLGChapter.type == LGChapterTypeAbyss)         _tableViewController = [TopTableViewControllerAbyss new];
    else if (kLGChapter.type == LGChapterTypeAbyssTop)      _tableViewController = [TopTableViewControllerAbyssTop new];
    else if (kLGChapter.type == LGChapterTypeAbyssBest)     _tableViewController = [TopTableViewControllerAbyssBest new];
    else if (kLGChapter.type == LGChapterTypeRandom)        _tableViewController = [TopTableViewControllerRandom new];
    else if (kLGChapter.type == LGChapterTypeSearch)        _tableViewController = [TopTableViewControllerSearch new];
    else if (kLGChapter.type == LGChapterTypeFavourites)    _tableViewController = [TopTableViewControllerFavourites new];
    _tableViewController.tableView.frame = CGRectMake(0.f, 0.f, frame.size.width, frame.size.height);
    [_tableViewController reloadTableViewDataAnimated:NO completionHandler:nil];
    [self addSubview:_tableViewController.tableView];
    
    // ------------------------------------------------------------------------------------------------------
    
    CGFloat navBarHeight = 64.f;
    
    if (kLGChapter.type == LGChapterTypeSearch && kSettings.loadingFrom == LGLoadingFromInternet)
    {
        kSettings.isNavBarHidden = NO;
        
        navBarHeight += 37;
    }
    
    _navBarView = [[NavBarView alloc] initWithFrame:CGRectMake(0.f, (kSettings.isNavBarHidden ? -navBarHeight : 0.f), frame.size.width, navBarHeight)];
    if (kSettings.isNavBarHidden)
    {
        _navBarView.hidden = YES;
        _navBarView.alpha = 1.f;
    }
    [self addSubview:_navBarView];
    
    // ------------------------------------------------------------------------------------------------------
    
    _statusBarView = [UIView new];
    _statusBarView.backgroundColor = (kSystemVersion >= 7 ? kColorSet(0, 0, 0, 0.8) : kColorSet(0, 0, 0, 0.5));
    if (!kSettings.isNavBarHidden)
    {
        _statusBarView.hidden = YES;
        _statusBarView.alpha = 0.f;
    }
    _statusBarView.frame = CGRectMake(0.f, 0.f, frame.size.width, 20.f);
    [self addSubview:_statusBarView];
    
    _statusBarStripeView = [UIView new];
    _statusBarStripeView.backgroundColor = kTopTheme.navBarStripeColor;
    _statusBarStripeView.frame = CGRectMake(0, _statusBarView.frame.size.height, _statusBarView.frame.size.width, kTopTheme.navBarStripeThickness);
    [_statusBarView addSubview:_statusBarStripeView];
    
    // ------------------------------------------------------------------------------------------------------
    
    [self tableViewContentInsetUpdateWithSize:self.frame.size];
    
    [self bringSubviewToFront:_bannerView];
    
    NSLog(@"TopView: Выбранный раздел - %@ (%i)", kLGChapter.name, kLGChapter.type);
    
    [kLGGoogleAnalytics setScreenName:[NSString stringWithFormat:@"Top View - %@ (%@)", kLGChapter.name, (kSettings.loadingFrom == LGLoadingFromInternet ? @"из интернета" : @"из локальной базы")]
                sendEventWithCategory:@"Top View"
                               action:@"Loaded"
                                label:[NSString stringWithFormat:@"%@ (%@)", kLGChapter.name, (kSettings.loadingFrom == LGLoadingFromInternet ? @"из интернета" : @"из локальной базы")]
                                value:nil];
}

#pragma mark - Gesture Recognizer

- (void)doubleTapGesture:(UITapGestureRecognizer *)sender
{
    LOG(@"");
    
    [kNavController.view endEditing:YES];
    
    int indent;
    int alpha;
    int shift;
    int center;
    
    if (!kSettings.isNavBarHidden)
    {
        indent = _navBarView.frame.size.height-20;
        alpha = 0;
        shift = -(_navBarView.frame.size.height-20);
        center = _navBarView.frame.size.height/2;
        
        kSettings.isNavBarHidden = YES;
        
        _statusBarView.hidden = NO;
        
        if (kSystemVersion >= 7 && kTopTheme.isColorConflict)
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    else
    {
        indent = -(_navBarView.frame.size.height-20);
        alpha = 1;
        shift = (_navBarView.frame.size.height-20);
        center = _navBarView.frame.size.height/2-shift;
        
        kSettings.isNavBarHidden = NO;
        
        _navBarView.hidden = NO;
        
        if (kSystemVersion >= 7 && kTopTheme.isColorConflict)
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
    
    self.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.35
                     animations:^(void)
     {
         _tableViewController.tableView.contentInset = UIEdgeInsetsMake(_tableViewController.tableView.contentInset.top-indent,
                                                                        _tableViewController.tableView.contentInset.left,
                                                                        _tableViewController.tableView.contentInset.bottom,
                                                                        _tableViewController.tableView.contentInset.right);
         
         _tableViewController.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(_tableViewController.tableView.scrollIndicatorInsets.top-indent,
                                                                                 _tableViewController.tableView.scrollIndicatorInsets.left,
                                                                                 _tableViewController.tableView.scrollIndicatorInsets.bottom,
                                                                                 _tableViewController.tableView.scrollIndicatorInsets.right);
         
         _navBarView.alpha = alpha;
         _statusBarView.alpha = 1-alpha;
         
         _navBarView.center = CGPointMake(_navBarView.center.x, center);
         _navBarView.center = CGPointMake(_navBarView.center.x, _navBarView.center.y+shift);
     }
                     completion:^(BOOL finished)
     {
         self.userInteractionEnabled = YES;
         
         if (!kSettings.isNavBarHidden) _statusBarView.hidden = YES;
         
         if (kSettings.isNavBarHidden) _navBarView.hidden = YES;
     }];
}

#pragma mark - TableView Methods

- (void)tableViewContentInsetUpdate
{
    [self tableViewContentInsetUpdateWithSize:self.frame.size];
}

- (void)tableViewContentInsetUpdateWithSize:(CGSize)size
{
    CGFloat topInset = _navBarView.frame.size.height;
    if (kSettings.isNavBarHidden) topInset = 20.f;
    
    CGFloat scrollBottomInset = (_keyboardHeight ? _keyboardHeight : (kLGAdMob.isAdsReceive ? kLGAdMob.bannerView.frame.size.height : 0.f));
    CGFloat bottomInset = scrollBottomInset + size.height * 0.2;
    
    _tableViewController.tableView.contentInset = UIEdgeInsetsMake(topInset, 0.f, bottomInset, 0.f);
    _tableViewController.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(topInset, 0.f, scrollBottomInset, 0.f);
}

- (void)tableViewReloadWithCompletionHandler:(void(^)())completionHandler
{
    LOG(@"");
    
    [_tableViewController reloadTableViewDataAnimated:NO completionHandler:completionHandler];
}

- (void)tableViewSetScrollsToTop:(BOOL)k
{
    LOG(@"");
    
    _tableViewController.tableView.scrollsToTop = k;
}

- (void)tableViewRefreshWithCompletionHandler:(void(^)())completionHandler;
{
    LOG(@"");
    
    [_tableViewController refreshTableViewDataWithCompletionHandler:completionHandler];
}

- (void)tableViewLoadQuotes
{
    LOG(@"");
    
    [_tableViewController loadQuotes];
}

- (void)tableViewCancelLoading
{
    LOG(@"");
    
    [_tableViewController cancelLoading];
}

- (void)tableViewDeleteTappedRow
{
    LOG(@"");
    
    [_tableViewController deleteTappedRow];
}

- (void)tableViewHidden:(BOOL)hidden animated:(BOOL)animated
{
    self.tableViewController.tableView.hidden = hidden;
    
    if (animated)
        [UIView transitionWithView:self.tableViewController.tableView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
}

- (BOOL)tableViewIsHidden
{
    return self.tableViewController.tableView.isHidden;
}

#pragma mark - NavBarView Methods

- (BOOL)navBarViewSearchFieldIsFirstResponder
{
    LOG(@"");
    
    return [_navBarView searchFieldIsFirstResponder];
}

- (void)navBarViewSearchFieldBecomeFirstResponder
{
    LOG(@"");
    
    [_navBarView searchFieldBecomeFirstResponder];
}

- (void)navBarViewSearchFieldResignFirstResponder
{
    LOG(@"");
    
    [_navBarView searchFieldResignFirstResponder];
}

@end









