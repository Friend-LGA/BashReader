//
//  BottomView.m
//  Bash
//
//  Created by Friend_LGA on 26.12.13.
//  Copyright (c) 2013 Grigory Lutkov. All rights reserved.
//

#import "BottomView.h"
#import "BottomTableViewController.h"
#import "LGKit.h"
#import "Settings.h"
#import "LGAdMob.h"
#import "BottomThemeObject.h"
#import "PrerenderedImages.h"

#pragma mark - Private

@interface BottomView ()

@property (strong, nonatomic) BottomTableViewController *tableViewController;
@property (strong, nonatomic) UIImageView               *shadowTopImageView;
@property (strong, nonatomic) UIImageView               *shadowRightImageView;
@property (strong, nonatomic) UIImageView               *shadowTopRightImageView;
@property (strong, nonatomic) UIView                    *topStripeView;
@property (strong, nonatomic) UIView                    *rightStripeView;

@end

#pragma mark - Implementation

@implementation BottomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = kColorClear;
        self.userInteractionEnabled = YES;
        
        CGFloat topInset = 0;
        CGFloat bottomInset = frame.size.height/3;
        
        _tableViewController = [BottomTableViewController new];
        _tableViewController.tableView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _tableViewController.tableView.contentInset = UIEdgeInsetsMake(topInset, 0, bottomInset, 0);
        _tableViewController.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(topInset, 0, bottomInset, 0);
        _tableViewController.tableView.scrollsToTop = NO;
        [self addSubview:_tableViewController.tableView];

        // Shadows -------------------------------------------
        
        _shadowRightImageView = [[UIImageView alloc] initWithImage:[kPrerenderedImages.menuShadowRightImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
        _shadowRightImageView.backgroundColor = kColorClear;
        _shadowRightImageView.clipsToBounds = YES;
        _shadowRightImageView.frame = CGRectMake(frame.size.width, 0, _shadowRightImageView.frame.size.width, frame.size.height);
        [self addSubview:_shadowRightImageView];
        
        if (kSystemVersion >= 7)
        {
            _shadowTopImageView = [[UIImageView alloc] initWithImage:[kPrerenderedImages.menuShadowTopImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
            _shadowTopImageView.backgroundColor = kColorClear;
            _shadowTopImageView.clipsToBounds = YES;
            _shadowTopImageView.frame = CGRectMake(0, -_shadowTopImageView.frame.size.height, frame.size.width, _shadowTopImageView.frame.size.height);
            [self addSubview:_shadowTopImageView];
            
            _shadowTopRightImageView = [[UIImageView alloc] initWithImage:kPrerenderedImages.menuShadowTopRightImage];
            _shadowTopRightImageView.backgroundColor = kColorClear;
            _shadowTopRightImageView.clipsToBounds = YES;
            _shadowTopRightImageView.frame = CGRectMake(frame.size.width, -_shadowTopRightImageView.frame.size.height, _shadowTopRightImageView.frame.size.width, _shadowTopRightImageView.frame.size.height);
            [self addSubview:_shadowTopRightImageView];
        }
        
        _topStripeView = [UIView new];
        _topStripeView.backgroundColor = kBottomTheme.stripeColor;
        _topStripeView.frame = CGRectMake(0, 0, frame.size.width, kBottomTheme.stripeThickness);
        [self addSubview:_topStripeView];
        
        _rightStripeView = [UIView new];
        _rightStripeView.backgroundColor = kBottomTheme.stripeColor;
        _rightStripeView.frame = CGRectMake(frame.size.width-kBottomTheme.stripeThickness, 0, kBottomTheme.stripeThickness, frame.size.height);
        [self addSubview:_rightStripeView];
    }
    return self;
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    _topStripeView.backgroundColor = kBottomTheme.stripeColor;
    _rightStripeView.backgroundColor = kBottomTheme.stripeColor;
}

#pragma mark -

- (void)resizeAndRepositionAfterRotateToSize:(CGSize)size
{
    CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, size.height);
    
    CGFloat topInset = 0;
    CGFloat bottomInset = frame.size.height/3;
    
    _tableViewController.tableView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _tableViewController.tableView.contentInset = UIEdgeInsetsMake(topInset, 0, bottomInset, 0);
    _tableViewController.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(topInset, 0, bottomInset, 0);
    
    _shadowRightImageView.frame = CGRectMake(frame.size.width, 0, _shadowRightImageView.frame.size.width, frame.size.height);
    
    if (kSystemVersion >= 7)
    {
        _shadowTopImageView.frame = CGRectMake(0, -_shadowTopImageView.frame.size.height, frame.size.width, _shadowTopImageView.frame.size.height);
        _shadowTopRightImageView.frame = CGRectMake(frame.size.width, -_shadowTopRightImageView.frame.size.height, _shadowTopRightImageView.frame.size.width, _shadowTopRightImageView.frame.size.height);
    }
    
    _topStripeView.frame = CGRectMake(0, 0, frame.size.width, kBottomTheme.stripeThickness);
    _rightStripeView.frame = CGRectMake(frame.size.width-kBottomTheme.stripeThickness, 0, kBottomTheme.stripeThickness, frame.size.height);
}

#pragma mark - TableView Methods

- (void)tableViewChangeInsetsTopOn:(int)topInset bottomOn:(int)bottomInset
{
    LOG(@"");
    
    _tableViewController.tableView.contentInset = UIEdgeInsetsMake(_tableViewController.tableView.contentInset.top+topInset, 0, _tableViewController.tableView.contentInset.bottom+bottomInset, 0);
    _tableViewController.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(_tableViewController.tableView.scrollIndicatorInsets.top+topInset, 0, _tableViewController.tableView.scrollIndicatorInsets.bottom+bottomInset, 0);
}

- (void)tableViewSetScrollsToTop:(BOOL)k
{
    LOG(@"");
    
    _tableViewController.tableView.scrollsToTop = k;
}

- (void)tableViewSetCloudSettingsTo:(BOOL)k
{
    LOG(@"");
    
    [_tableViewController setCloudSettingsTo:k];
}

- (void)tableViewCollapseCloudSettings
{
    LOG(@"");
    
    [_tableViewController collapseCloudSettings];
}

@end
