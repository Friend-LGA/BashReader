//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "NavBarView.h"
#import "NavBarButton.h"
#import "NavBarSearchField.h"
#import "AppDelegate.h"
#import "TopView.h"
#import "LGKit.h"
#import "Settings.h"
#import "LGChapter.h"
#import "TopThemeObject.h"
#import "PrerenderedImages.h"

@interface NavBarView () <UITextFieldDelegate>

@property (strong, nonatomic) UIImageView   *shadowImageView;
@property (strong, nonatomic) UIView        *stripeView;

@end

@implementation NavBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = kTopTheme.navBarBgColor;
        self.userInteractionEnabled = YES;
        self.clipsToBounds = NO;
        
        CGFloat statusBarSize = 20.f;
        CGFloat navBarSize = 44.f;
        
        _titleLabel = [UILabel new];
        _titleLabel.text = kLGChapter.name;
        _titleLabel.textColor = kTopTheme.navBarTextColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.opaque = NO;
        _titleLabel.backgroundColor = kColorClear;
        [_titleLabel sizeToFit];
        [_titleLabel layoutIfNeeded];
        _titleLabel.center = CGPointMake(frame.size.width/2, statusBarSize+navBarSize/2);
        _titleLabel.frame = CGRectIntegral(_titleLabel.frame);
        [self addSubview:_titleLabel];
        
        _leftButton = [NavBarButton buttonWithType:UIButtonTypeCustom];
        _leftButton.type = LGNavBarButtonLeft;
        [_leftButton addTarget:kNavController action:@selector(openCloseMenuAction) forControlEvents:UIControlEventTouchUpInside];
        _leftButton.frame = CGRectMake(0.f, 0.f, navBarSize, navBarSize);
        _leftButton.center = CGPointMake(_leftButton.frame.size.width/2, statusBarSize+navBarSize/2);
        _leftButton.frame = CGRectIntegral(_leftButton.frame);
        [self addSubview:_leftButton];
        
        _rightButton = [NavBarButton buttonWithType:UIButtonTypeCustom];
        _rightButton.type = LGNavBarButtonRight;
        [_rightButton addTarget:kNavController action:@selector(showHelpInfo) forControlEvents:UIControlEventTouchUpInside];
        [_rightButton setTitle:@"?" forState:UIControlStateNormal];
        [_rightButton setTitleColor:kTopTheme.navBarTextColor forState:UIControlStateNormal];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:26];
        _rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _rightButton.frame = CGRectMake(0.f, 0.f, navBarSize, navBarSize);
        _rightButton.center = CGPointMake(frame.size.width-_rightButton.frame.size.width/2, statusBarSize+navBarSize/2);
        _rightButton.frame = CGRectIntegral(_rightButton.frame);
        [self addSubview:_rightButton];
        
        if (kLGChapter.type == LGChapterTypeSearch && kSettings.loadingFrom == LGLoadingFromInternet)
        {
            _searchField = [NavBarSearchField new];
            _searchField.delegate = self;
            _searchField.frame = CGRectMake(5.f, statusBarSize+navBarSize, frame.size.width-10.f, 32.f);
            [self addSubview:_searchField];
            
            [_searchField becomeFirstResponder];
        }
        
        _shadowImageView = [[UIImageView alloc] initWithImage:[kPrerenderedImages.navBarShadowBottomImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
        _shadowImageView.backgroundColor = kColorClear;
        _shadowImageView.clipsToBounds = YES;
        _shadowImageView.frame = CGRectMake(0.f, frame.size.height, frame.size.width, _shadowImageView.frame.size.height);
        [self addSubview:_shadowImageView];
        
        _stripeView = [UIView new];
        _stripeView.backgroundColor = kTopTheme.navBarStripeColor;
        _stripeView.frame = CGRectMake(0.f, frame.size.height-kTopTheme.navBarStripeThickness, frame.size.width, kTopTheme.navBarStripeThickness);
        [self addSubview:_stripeView];
    }
    return self;
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    self.backgroundColor = kTopTheme.navBarBgColor;
    _titleLabel.textColor = kTopTheme.navBarTextColor;
    [_rightButton setTitleColor:kTopTheme.navBarTextColor forState:UIControlStateNormal];
    _stripeView.backgroundColor = kTopTheme.navBarStripeColor;
}

- (void)resizeAndRepositionAfterRotateToSize:(CGSize)size
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, self.frame.size.height);
    
    CGRect frame = self.frame;
    
    CGFloat statusBarSize = 20.f;
    CGFloat navBarSize = 44.f;
    
    _titleLabel.center = CGPointMake(frame.size.width/2, statusBarSize+navBarSize/2);
    _titleLabel.frame = CGRectIntegral(_titleLabel.frame);
    
    _leftButton.center = CGPointMake(_leftButton.frame.size.width/2, statusBarSize+navBarSize/2);
    _leftButton.frame = CGRectIntegral(_leftButton.frame);
    
    _rightButton.center = CGPointMake(frame.size.width-_rightButton.frame.size.width/2, statusBarSize+navBarSize/2);
    _rightButton.frame = CGRectIntegral(_rightButton.frame);
    
    if (kLGChapter.type == LGChapterTypeSearch && kSettings.loadingFrom == LGLoadingFromInternet)
        _searchField.frame = CGRectMake(5.f, statusBarSize+navBarSize, frame.size.width-10.f, 32.f);
    
    _shadowImageView.frame = CGRectMake(0.f, frame.size.height, frame.size.width, _shadowImageView.frame.size.height);
    
    _stripeView.frame = CGRectMake(0.f, frame.size.height-kTopTheme.navBarStripeThickness, frame.size.width, kTopTheme.navBarStripeThickness);
}

#pragma mark -

- (BOOL)searchFieldIsFirstResponder
{
    LOG(@"");
    
    return _searchField.isFirstResponder;
}

- (void)searchFieldBecomeFirstResponder
{
    LOG(@"");
    
    [_searchField becomeFirstResponder];
}

- (void)searchFieldResignFirstResponder
{
    LOG(@"");
    
    [_searchField resignFirstResponder];
}

#pragma mark - UITextField Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    LOG(@"");
    
    [_searchField saveSearchText:textField.text];
    
    [_searchField resignFirstResponder];
    
    [kTopView tableViewRefreshWithCompletionHandler:^(void)
    {
        [kTopView tableViewLoadQuotes];
    }];

    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    LOG(@"");
    
    [_searchField saveSearchText:textField.text];
    
    return YES;
}
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    LOG(@"");
    
    //[kTopView tableViewLoadQuotes];
    
    return YES;
}
*/
@end






