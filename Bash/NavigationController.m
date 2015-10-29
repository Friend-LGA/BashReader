//
//  NavigationController.m
//  Bash
//
//  Created by Friend_LGA on 26.12.13.
//  Copyright (c) 2013 Grigory Lutkov. All rights reserved.
//

#import "NavigationController.h"
#import "BottomView.h"
#import "TopView.h"
#import "InfoViewController.h"
#import "LGKit.h"
#import "Settings.h"
#import "LGChapter.h"
#import "LGGoogleAnalytics.h"
#import "LGCloud.h"
#import "LGAdMob.h"
#import "TopThemeObject.h"

#pragma mark - Private

static CGFloat const kVisibleMenuWidth  = 250.f;
static CGFloat const kVelocityMax       = 1000.f;

@interface NavigationController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView        *loadingView;
@property (strong, nonatomic) UIImageView   *imageView;
@property (strong, nonatomic) UIView        *darkView;
@property (assign, nonatomic) CGFloat       diff;
@property (assign, nonatomic) BOOL          needToCancelRotate;
@property (assign, nonatomic) BOOL          isDifferentOrientation;

@end

#pragma mark - Implementation

@implementation NavigationController

- (id)init
{
    LOG(@"");
    
    self = [super init];
    if (self)
    {
        self.navigationBar.hidden = YES;
        self.toolbar.hidden = YES;
        self.view.userInteractionEnabled = NO;
        
        NSArray *imagesArray = @[@"Launch-Pad-P",
                                 @"Launch-Pad-L",
                                 @"Launch-Phone-35-P",
                                 @"Launch-Phone-35-L",
                                 @"Launch-Phone-40-P",
                                 @"Launch-Phone-40-L",
                                 @"Launch-Phone-47-P",
                                 @"Launch-Phone-47-L",
                                 @"Launch-Phone-55-P",
                                 @"Launch-Phone-55-L"];
        UIImage *launchImage;
        
        for (NSString *imageName in imagesArray)
        {
            UIImage *image = [UIImage imageNamed:imageName];
            
            if (self.view.frame.size.width == image.size.width && self.view.frame.size.height == image.size.height)
                launchImage = [UIImage imageNamed:imageName];
        }
        
        _imageView = [[UIImageView alloc] initWithImage:launchImage];
        _imageView.clipsToBounds = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

        self.view = _imageView;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if (!self.isLaunched) [self showLoadingView];
}

#pragma mark -

- (void)showLoadingView
{
    CGRect frame = self.view.frame;
    
    _loadingView = [UIView new];
    _loadingView.opaque = NO;
    _loadingView.backgroundColor = kColorSchemaBlue1;
    _loadingView.layer.cornerRadius = 15;
    _loadingView.alpha = 0;
    [self.view addSubview:_loadingView];
    
    UIActivityIndicatorView *loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadingIndicatorView.backgroundColor = kColorClear;
    [loadingIndicatorView startAnimating];
    [_loadingView addSubview:loadingIndicatorView];
    
    UILabel *loadingLabel = [UILabel new];
    loadingLabel.text = @"Загрузка...";
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.textColor = kColorWhite;
    loadingLabel.backgroundColor = kColorClear;
    [loadingLabel sizeToFit];
    [loadingLabel layoutIfNeeded];
    [_loadingView addSubview:loadingLabel];
    
    int widthShift = 20;
    int heightShift = 10;
    int betweenShift = 5;
    
    _loadingView.frame = CGRectMake(0, 0, loadingIndicatorView.frame.size.width+loadingLabel.frame.size.width+widthShift+betweenShift, loadingLabel.frame.size.height+heightShift);
    _loadingView.center = CGPointMake(frame.size.width/2, frame.size.height*0.9);
    _loadingView.frame = CGRectIntegral(_loadingView.frame);
    
    loadingIndicatorView.center = CGPointMake(_loadingView.frame.size.width/2-loadingLabel.frame.size.width/2-betweenShift/2, _loadingView.frame.size.height/2);
    loadingIndicatorView.frame = CGRectIntegral(loadingIndicatorView.frame);
    
    loadingLabel.center = CGPointMake(loadingIndicatorView.frame.origin.x+loadingIndicatorView.frame.size.width+betweenShift+loadingLabel.frame.size.width/2, _loadingView.frame.size.height/2);
    loadingLabel.frame = CGRectIntegral(loadingLabel.frame);
    
    [UIView animateWithDuration:0.4 animations:^(void)
     {
         _loadingView.alpha = 1;
     }
                     completion:^(BOOL finished)
     {
         [kLGKit initialize];
         [self initAllViews];
         [self showAnimation];
     }];
}

- (void)initAllViews
{
    CGRect frame = self.view.bounds;
    
    _mainView = [[TopView alloc] initWithFrame:CGRectMake(0.f, 0.f, frame.size.width, frame.size.height)];
    _mainView.alpha = 0.f;
    [self.view addSubview:_mainView];
    
    _darkView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, frame.size.width, frame.size.height)];
    _darkView.backgroundColor = kColorSet(0, 0, 0, 0.5);
    _darkView.alpha = 0.f;
    _darkView.hidden = YES;
    [self.view addSubview:_darkView];
    
    _menuView = [[BottomView alloc] initWithFrame:CGRectMake(-kVisibleMenuWidth-kSlideStock, 20.f, kVisibleMenuWidth+kSlideStock, frame.size.height-20.f)];
    _menuView.hidden = YES;
    [self.view addSubview:_menuView];
    
    _menuEnabled = YES;
    
    // Активируем быструю перемотку на topTableView ---------------------------------------------------------
    
    for (UIScrollView *scrollView in self.view.subviews)
        if ([scrollView isKindOfClass:[UIScrollView class]])
            [scrollView setScrollsToTop:NO];
    
    [_mainView tableViewSetScrollsToTop:YES];
    
    // Gesture Recognizers ----------------------------------------------------------------------------------

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGesture.delegate = self;
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [_darkView addGestureRecognizer:tapGesture];
}

- (void)showAnimation
{
    if (kSettings.orientation != LGOrientationAuto)
    {
        UIInterfaceOrientation orientation = (kSettings.orientation == LGOrientationPortrait ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft);
        
        if ([[UIApplication sharedApplication] statusBarOrientation] != orientation)
        {
            [[UIApplication sharedApplication] setStatusBarOrientation:orientation];
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
            
            CGSize size;
            if (UIInterfaceOrientationIsLandscape(orientation))
                size = CGSizeMake(kMainScreenSideMax, kMainScreenSideMin);
            else
                size = CGSizeMake(kMainScreenSideMin, kMainScreenSideMax);
            
            [self resizeViewsToSize:size];
        }
    }
    
    UIStatusBarStyle statusBarStyle;
    if (kSystemVersion >= 7)
    {
        if (!kSettings.isNavBarHidden && kTopTheme.isColorConflict) statusBarStyle = UIStatusBarStyleDefault;
        else statusBarStyle = UIStatusBarStyleLightContent;
    }
    else statusBarStyle = UIStatusBarStyleBlackTranslucent;

    [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void)
     {
         _mainView.alpha = 1.f;
     }
                     completion:^(BOOL finished)
     {
         [self showAlertIfNeeded];
         
         if (kLGChapter.type == LGChapterTypeSearch && !kInfoVC.isPopViewOnScreen && kSettings.loadingFrom == LGLoadingFromInternet && ![_mainView navBarViewSearchFieldIsFirstResponder])
             [_mainView navBarViewSearchFieldBecomeFirstResponder];
         
         self.view.userInteractionEnabled = YES;
         
         [_loadingView removeFromSuperview];
         _loadingView = nil;
         
         _launched = YES;
         
         if (!(kLGChapter.type == LGChapterTypeFavourites && kLGCloud.status == LGCloudStatusSyncing))
             [_mainView tableViewLoadQuotes];
     }];
}

- (void)showAlertIfNeeded
{
    if (kLGKit.needsToShowFirstInfo)
    {
        kLGKit.needsToShowFirstInfo = NO;
        
        kLGKit.needsToShowUpdateInfo = NO;
        
        [self showFirstInfo];
    }
    
    if (kLGKit.needsToShowUpdateInfo)
    {
        kLGKit.needsToShowUpdateInfo = NO;
        
        [self showUpdateInfo];
    }
    
    if (kLGKit.needsToShowRateReminder)
    {
        kLGKit.needsToShowRateReminder = NO;
        
        [self showRateReminder];
    }
    
    if (kLGKit.needsToShowVkReminder)
    {
        kLGKit.needsToShowVkReminder = NO;
        
        [self showVkReminder];
    }
    
    if (kLGKit.needsToShowSyncInfo)
    {
        kLGKit.needsToShowSyncInfo = NO;
        
        [self showSyncInfo];
    }
    
    if (kLGKit.needsToShowFileVersionError)
    {
        kLGKit.needsToShowFileVersionError = NO;
        
        [self showFileVersionError];
    }
}

#pragma mark -

- (void)showFirstInfo
{
    LOG(@"");
    
    [kInfoVC showInfoWithText:@"Спасибо за то что скачали Bash.Reader!\n•   •   •\nДля получения информации по управлению приложением нажмите на знак \"?\" в правом верхнем углу."
                         type:LGInfoViewTypeFirstInfo];
}

- (void)showUpdateInfo
{
    LOG(@"");
    
    [kInfoVC showInfoWithText:@"Новости обновления.\n•   •   •\nПриложение было адаптировано для\niOS 8 и новых устройств\n(iPhone 6 и iPhone 6 Plus).\n•   •   •\nБыл произведен редизайн и оптимизирован код. Повышена производительность и надежность.\n•   •   •\nТеперь горизонтальная ориентация доступна и для iPhone. Загляните в настройки!\n•   •   •\nПоявилась возможность настраивать боковые поля. Причем отдельно для каждой ориентации.\n•   •   •\nДля любителей социальных сетей мы добавили возможность постинга еще и в Google+\n•   •   •\nНадеемся что вам понравится новая версия! И рассчитываем на ваши положительные отзывы :)"
                         type:LGInfoViewTypeUpdateInfo];
}

- (void)showRateReminder
{
    LOG(@"");
    
    [kInfoVC showInfoWithText:@"Хотите оценить приложение?\n•   •   •\nЕсли вам нравится пользоваться нашей программой и вы хотите чтобы она продолжала развиваться, а обновления выходили почаще, - поддержите разработчиков морально, - выставляйте рейтинг и пишите комментарии для каждой новой версии. Это не займет много времени, а нам будет приятно =)\nЗаранее спасибо!"
                         type:LGInfoViewTypeRateReminder];
}

- (void)showVkReminder
{
    LOG(@"");
    
    [kInfoVC showInfoWithText:@"Есть идеи и предложения по улучшению программы?\n•   •   •\nПрисоединяйтесь к нашей группе ВКонтакте и обсудите свои идеи с разработчиками и другими пользователями.\nСделаем Bash.Reader удобным для всех!"
                         type:LGInfoViewTypeVkReminder];
}

- (void)showSyncInfo
{
    LOG(@"");
    
    [kInfoVC showInfoWithText:@"iCloud включен впервые, или была сменена учетная запись.\n•   •   •\nВыберите желаемое действие:"
                         type:LGInfoViewTypeSync];
}

- (void)showFileVersionError
{
    LOG(@"");
    
    [kInfoVC showInfoWithText:@"В iCloud хранятся файлы более новой версии программы.\nРекомендуем не затягивать с обновлением, а пока синхронизация с iCloud будет отключена."
                         type:LGInfoViewTypeVersionError];
}

- (void)showHelpInfo
{
    LOG(@"");
    
    [self.view endEditing:YES];
    
    if (kIsRemoveAdsPurchased)
        [kInfoVC showInfoWithText:[NSString stringWithFormat:@"%@\n•   •   •\nЧтобы открыть меню настроек, нажмите на кнопку в левом верхнем углу, или проведите пальцем с левого края экрана.\n•   •   •\nЧтобы увидеть дополнительное меню, тапните один раз по цитате.\n•   •   •\nЧтобы скрыть верхнюю панель навигации, тапните два раза по экрану.", kLGCloud.statusDescription]
                             type:LGInfoViewTypeHelpInfo];
    else
        [kInfoVC showInfoWithText:[NSString stringWithFormat:@"%@\n•   •   •\nЧтобы бесплатно отключить рекламу на 10 минут - запостите любую цитату ВКонтакт, Facebook или Twitter. Количество повторений не ограничено.\n•   •   •\nЧтобы открыть меню настроек, нажмите на кнопку в левом верхнем углу, или проведите пальцем с левого края экрана.\n•   •   •\nЧтобы увидеть дополнительное меню, тапните один раз по цитате.\n•   •   •\nЧтобы скрыть верхнюю панель навигации, тапните два раза по экрану.", kLGCloud.statusDescription]
                             type:LGInfoViewTypeHelpInfo];
}

#pragma mark - Gesture Recognizer

- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (!kInfoVC.isPopViewOnScreen && self.isMenuEnabled)
    {
        CGPoint location = [gestureRecognizer locationInView:self.view];
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            if (!_menuView.isMoving)
            {
                CGFloat rightPosition = _menuView.frame.origin.x+_menuView.frame.size.width;
                
                if (location.x >= rightPosition && location.x <= rightPosition+44.f)
                {
                    _diff = location.x - rightPosition;
                    
                    _menuView.hidden = NO;
                    _menuView.isMoving = YES;
                    
                    _darkView.hidden = NO;
                    
                    [self.view endEditing:YES];
                }
            }
            else _diff = 0.f;
        }
        else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {
            CGFloat rightPosition = _menuView.frame.origin.x+_menuView.frame.size.width;
            CGFloat posX = location.x-_menuView.frame.size.width/2-_diff;
            
            if (_menuView.isMoving)
            {
                BOOL isChange = YES;
                
                if (posX > kVisibleMenuWidth-_menuView.frame.size.width/2)
                {
                    CGFloat posXMin     = kVisibleMenuWidth-_menuView.frame.size.width/2;
                    CGFloat excess      = posX - posXMin;
                    CGFloat excessMax   = 200.f;

                    CGFloat coef = excess / excessMax;
                    if (coef > 0.5) isChange = NO;
                    else
                    {
                        coef = 1.f - coef;
                        
                        posX = posXMin + excess * coef;
                    }
                }
                
                if (isChange)
                {
                    _menuView.center = CGPointMake(posX, _menuView.center.y);
                    _darkView.alpha = (_menuView.frame.origin.x+_menuView.frame.size.width)/kVisibleMenuWidth;
                }
            }
            else if (location.x >= rightPosition && location.x <= rightPosition+44.f)
            {
                _diff = location.x - rightPosition;
                
                _menuView.hidden = NO;
                _menuView.isMoving = YES;
                
                _darkView.hidden = NO;
                
                [self.view endEditing:YES];
            }
        }
        else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            if (_menuView.isMoving)
            {
                CGPoint velocity = [gestureRecognizer velocityInView:self.view];
                
                [self openCloseMenuActionWithVelocity:velocity force:NO];
            }
        }
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if (!kInfoVC.isPopViewOnScreen && self.isMenuEnabled)
        [self openCloseMenuActionWithVelocity:CGPointZero force:YES];
}

#pragma mark -

- (void)openCloseMenuAction
{
    if (!_menuView.isOpened) [self.view endEditing:YES];
    
    [self openCloseMenuActionWithVelocity:CGPointZero force:YES];
}

- (void)openCloseMenuActionWithVelocity:(CGPoint)velocity force:(BOOL)force
{
    [UIView setAnimationsEnabled:YES];
    
    CGFloat distance = 0;
    CGFloat distanceMax;
    NSTimeInterval animationDuration = 0.25f;
    NSTimeInterval animationDurationMin = 0.1f;
    NSTimeInterval animationDurationDiff = animationDuration - animationDurationMin;
    BOOL toOpen;
    UIViewAnimationOptions options;
    
    if (force)
    {
        distance = kVisibleMenuWidth;
        
        toOpen = (_menuView.frame.origin.x+_menuView.frame.size.width == 0);
        
        if (toOpen)
        {
            _menuView.hidden = NO;
            _darkView.hidden = NO;
        }
        
        options = UIViewAnimationOptionCurveEaseIn;
    }
    else if (_menuView.frame.origin.x+_menuView.frame.size.width >= kVisibleMenuWidth)
    {
        distance = (kVisibleMenuWidth-(_menuView.frame.origin.x+_menuView.frame.size.width));
        if (fabsf(distance) > 5) distance *= 2;
        else distance = 0;
        
        animationDuration = 0.1f;
        
        toOpen = YES;
        
        options = UIViewAnimationOptionCurveLinear;
    }
    else
    {
        distanceMax = kVisibleMenuWidth;
        
        if (velocity.x > 0.f || (velocity.x == 0 && _menuView.frame.origin.x+_menuView.frame.size.width >= kVisibleMenuWidth/2))
            distance = kVisibleMenuWidth-(_menuView.frame.origin.x+_menuView.frame.size.width);
        else if (velocity.x < 0.f || (velocity.x == 0 && _menuView.frame.origin.x+_menuView.frame.size.width < kVisibleMenuWidth/2))
            distance = _menuView.frame.origin.x+_menuView.frame.size.width;
        
        if (fabsf(velocity.x) >= kVelocityMax)
        {
            if (fabsf(distance) < 20) distance *= 2;
            
            animationDuration -= animationDurationDiff - ((fabsf(distance) / fabsf(velocity.x)) * animationDurationDiff / (distanceMax / kVelocityMax));
            
            toOpen = (velocity.x > 0.f);
            
            options = (toOpen ? UIViewAnimationOptionCurveLinear : UIViewAnimationOptionCurveEaseIn);
        }
        else
        {
            if (fabsf(distance) < 10) distance = 0;
            
            animationDuration -= animationDurationDiff - (distance * animationDurationDiff / distanceMax);
            
            toOpen = (velocity.x > 0.f || (_menuView.frame.origin.x+_menuView.frame.size.width >= kVisibleMenuWidth/2 && velocity.x == 0.f));
            
            options = (toOpen ? UIViewAnimationOptionCurveLinear : UIViewAnimationOptionCurveEaseIn);
        }
    }
    
    [self showAnimationWithDuration:animationDuration
                            options:options
                           distance:distance
                             toOpen:toOpen];
}

- (void)showAnimationWithDuration:(NSTimeInterval)duration
                          options:(UIViewAnimationOptions)options
                         distance:(CGFloat)distance
                           toOpen:(BOOL)toOpen
{
    self.view.userInteractionEnabled = NO;
    
    if (toOpen)
    {
        CGFloat position = kVisibleMenuWidth-_menuView.frame.size.width/2;
        
        if (distance == 0)
        {
            [UIView animateWithDuration:0.1f animations:^(void)
             {
                 _menuView.center = CGPointMake(position, _menuView.center.y);
             }
                             completion:^(BOOL finished)
             {
                 _menuView.isOpened = YES;
                 _menuView.isMoving = NO;
                 
                 _darkView.alpha = 1.f;
                 
                 self.view.userInteractionEnabled = YES;
             }];
        }
        else
        {
            distance /= 15.f;
            
            [UIView animateWithDuration:duration animations:^(void)
             {
                 _menuView.center = CGPointMake(position+distance, _menuView.center.y);
                 _darkView.alpha = 1.f;
             }
                             completion:^(BOOL finished)
             {
                 [UIView animateWithDuration:0.1f animations:^(void)
                  {
                      _menuView.center = CGPointMake(position-distance/2, _menuView.center.y);
                  }
                                  completion:^(BOOL finished)
                  {
                      [UIView animateWithDuration:0.1f animations:^(void)
                       {
                           _menuView.center = CGPointMake(position, _menuView.center.y);
                       }
                                       completion:^(BOOL finished)
                       {
                           _menuView.isOpened = YES;
                           _menuView.isMoving = NO;
                           
                           _darkView.alpha = 1.f;
                           
                           self.view.userInteractionEnabled = YES;
                       }];
                  }];
             }];
        }
    }
    else
    {
        CGFloat position = -_menuView.frame.size.width/2;
        
        if (_menuView.frame.origin.x+_menuView.frame.size.width <= 0.f)
        {
            _menuView.center = CGPointMake(position, _menuView.center.y);
            _menuView.isOpened = NO;
            _menuView.isMoving = NO;
            _menuView.hidden = YES;
            
            _darkView.alpha = 0.f;
            _darkView.hidden = YES;
            
            self.view.userInteractionEnabled = YES;
        }
        else
        {
            [UIView animateWithDuration:duration
                                  delay:0.f
                                options:options
                             animations:^(void)
             {
                 _menuView.center = CGPointMake(position, _menuView.center.y);
                 _darkView.alpha = 0.f;
             }
                             completion:^(BOOL finished)
             {
                 _menuView.isOpened = NO;
                 _menuView.isMoving = NO;
                 _menuView.hidden = YES;
                 
                 _darkView.alpha = 0.f;
                 _darkView.hidden = YES;
                 
                 self.view.userInteractionEnabled = YES;
             }];
        }
    }
}

#pragma mark - Interface Orientation Rotate

- (NSUInteger)supportedInterfaceOrientations
{
    if (kSettings.orientation == LGOrientationAuto)
        return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscape;
    else if (kSettings.orientation == LGOrientationPortrait)
        return UIInterfaceOrientationMaskPortrait;
    else if (kSettings.orientation == LGOrientationLandscape)
        return UIInterfaceOrientationMaskLandscape;
    else
        return 0;
}

- (BOOL)shouldAutorotate
{
    //return (kSettings.orientation == LGOrientationAuto);
    return (!self.isRotationBlocked);
}

// iOS < 8

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    LOG(@"");
    
    [UIView setAnimationsEnabled:NO];
    
    if (!self.isRotationBlocked)
    {
        CGSize size;
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
            size = CGSizeMake(kMainScreenSideMax, kMainScreenSideMin);
        else
            size = CGSizeMake(kMainScreenSideMin, kMainScreenSideMax);
        
        _isDifferentOrientation = (!CGSizeEqualToSize(size, self.view.bounds.size));
        
        if (_isDifferentOrientation)
        {
            [_mainView tableViewHidden:YES animated:NO];
            
            [self resizeViewsToSize:size];
        }
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    LOG(@"");
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [UIView setAnimationsEnabled:YES];
    
    if (!self.isRotationBlocked && _isDifferentOrientation) [self updateMainViewAfterRotate];
}

// iOS >= 8

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    LOG(@"");
    
    [UIView setAnimationsEnabled:NO];
    
    if (!self.isRotationBlocked)
    {
        _isDifferentOrientation = (!CGSizeEqualToSize(size, self.view.bounds.size));
        
        if (_isDifferentOrientation) [_mainView tableViewHidden:YES animated:NO];
        
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
         {
             if (_isDifferentOrientation) [self resizeViewsToSize:size];
         }
                                     completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
         {
             [UIView setAnimationsEnabled:YES];
             
             if (_isDifferentOrientation) [self updateMainViewAfterRotate];
             
             [[UIApplication sharedApplication] setStatusBarHidden:NO];
         }];
    }
    else
    {
        [coordinator animateAlongsideTransition:nil
                                     completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
         {
             [UIView setAnimationsEnabled:YES];
             
             [[UIApplication sharedApplication] setStatusBarHidden:NO];
         }];
    }
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)updateMainViewAfterRotate
{
    _rotationBlocked = YES;
    
    __weak typeof(self) wself = self;
    
    if (_mainView)
    {
        [_mainView tableViewReloadWithCompletionHandler:^(void)
         {
             if (wself)
             {
                 __strong typeof(wself) self = wself;
                 
                 [self.mainView tableViewHidden:NO animated:YES];
                 
                 _rotationBlocked = NO;
             }
         }];
    }
    else _rotationBlocked = NO;
}

- (void)resizeViewsToSize:(CGSize)size
{
    NSArray *imagesArray = @[@"Launch-Pad-P",
                             @"Launch-Pad-L",
                             @"Launch-Phone-35-P",
                             @"Launch-Phone-35-L",
                             @"Launch-Phone-40-P",
                             @"Launch-Phone-40-L",
                             @"Launch-Phone-47-P",
                             @"Launch-Phone-47-L",
                             @"Launch-Phone-55-P",
                             @"Launch-Phone-55-L"];
    UIImage *launchImage;
    
    for (NSString *imageName in imagesArray)
    {
        UIImage *image = [UIImage imageNamed:imageName];
        
        if (image.size.width == size.width && image.size.height == size.height)
            launchImage = [UIImage imageNamed:imageName];
    }
    
    _imageView.image = launchImage;
    
    if (_loadingView)
    {
        _loadingView.center = CGPointMake(size.width/2, size.height*0.9);
        _loadingView.frame = CGRectIntegral(_loadingView.frame);
    }
    
    if (_mainView)
    {
        _mainView.frame = CGRectMake(0.f, 0.f, size.width, size.height);
        [_mainView resizeAndRepositionAfterRotateToSize:_mainView.frame.size];
    }
    
    if (_menuView)
    {
        _menuView.frame = CGRectMake(_menuView.frame.origin.x, _menuView.frame.origin.y, _menuView.frame.size.width, size.height-20.f);
        [_menuView resizeAndRepositionAfterRotateToSize:_menuView.frame.size];
    }
    
    if (_darkView) _darkView.frame = CGRectMake(0.f, 0.f, size.width, size.height);
    
    [kInfoVC resizeAndRepositionAfterRotateToSize:size];
    [kLGAdMob resizeAndRepositionAfterRotateToSize:size];
}

@end






