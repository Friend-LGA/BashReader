//
//  InfoViewButton.m
//  Bash
//
//  Created by Friend_LGA on 24.01.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "InfoViewButton.h"
#import "LGKit.h"
#import "Settings.h"
#import "TopThemeObject.h"
#import "PrerenderedImages.h"
#import "AppDelegate.h"

#pragma mark - Private

@interface InfoViewButton ()

@property (strong, nonatomic) UIImageView               *markDoneImageView;
@property (strong, nonatomic) UIActivityIndicatorView   *indicator;
@property (strong, nonatomic) UIView                    *stripeView;
@property (assign, nonatomic) BOOL                      isOnSuperview;

@end

#pragma mark - Implementation

@implementation InfoViewButton

@synthesize titleLabel = _titleLabel;

- (id)initWithTitle:(NSString *)title
{
    if ((self = [super init]))
    {
        _isAnimated = NO;
        
        _markDoneImageView = [[UIImageView alloc] initWithImage:kPrerenderedImages.tickImage];
        [self addSubview:_markDoneImageView];
        
        _indicator = [UIActivityIndicatorView new];
        _indicator.color = kTopTheme.infoButtonsColor;
        [self addSubview:_indicator];
        
        _titleLabel = [UILabel new];
        _titleLabel.text = title;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = kColorClear;
        _titleLabel.textColor = kTopTheme.infoButtonsColor;
        [self addSubview:_titleLabel];
        
        _stripeView = [UIView new];
        _stripeView.backgroundColor = kTopTheme.infoStripeColor;
        [self addSubview:_stripeView];
    }
    return self;
}

- (void)doneAction
{
    //[self.layer removeAllAnimations];
    
    _markDoneImageView.hidden = NO;
    
    [UIView animateWithDuration:0.3
                     animations:^(void)
     {
         _indicator.alpha = 0.f;
         _markDoneImageView.alpha = 1.f;
     }
                     completion:^(BOOL finished)
     {
         [_indicator stopAnimating];
         
         kNavController.view.userInteractionEnabled = YES;
     }];
}

- (void)undoneAction
{
    [UIView animateWithDuration:0.3
                     animations:^(void)
     {
         _indicator.alpha = 0.f;
         _markDoneImageView.alpha = 0.f;
         
         _titleLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
         
         CGFloat shift = 10.f;
         
         _markDoneImageView.center = CGPointMake(_titleLabel.frame.origin.x-shift/2-_markDoneImageView.frame.size.width/2, self.frame.size.height/2);
         _indicator.center = _markDoneImageView.center;
     }
                     completion:^(BOOL finished)
     {
         _titleLabel.frame = CGRectIntegral(_titleLabel.frame);
         _markDoneImageView.frame = CGRectIntegral(_markDoneImageView.frame);
         _indicator.frame = CGRectIntegral(_indicator.frame);
         
         [_indicator stopAnimating];
         _markDoneImageView.hidden = YES;
         
         kNavController.view.userInteractionEnabled = YES;
     }];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted)
    {
        self.backgroundColor = kTopTheme.infoCellHighlightedBgColor;
    }
    else
    {
        self.backgroundColor = kColorClear;
    }
}

- (void)setSelected:(BOOL)selected
{
    if (_isOnSuperview && _isAnimated && selected != self.isSelected)
    {
        kNavController.view.userInteractionEnabled = NO;
        
        [_indicator startAnimating];
        
        [UIView animateWithDuration:0.3
                         animations:^(void)
         {
             _indicator.alpha = 1.f;
             _markDoneImageView.alpha = 0.f;
             
             _titleLabel.center = CGPointMake(self.frame.size.width/2+_markDoneImageView.frame.size.width/2, self.frame.size.height/2);
             
             CGFloat shift = 10.f;
             
             _markDoneImageView.center = CGPointMake(_titleLabel.frame.origin.x-shift/2-_markDoneImageView.frame.size.width/2, self.frame.size.height/2);
             _indicator.center = _markDoneImageView.center;
         }
                         completion:^(BOOL finished)
         {
             _titleLabel.frame = CGRectIntegral(_titleLabel.frame);
             _markDoneImageView.frame = CGRectIntegral(_markDoneImageView.frame);
             _indicator.frame = CGRectIntegral(_indicator.frame);
         }];
    }
    
    [super setSelected:selected];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    CGFloat shift = 10.f;
    
    [_titleLabel sizeToFit];
    [_titleLabel layoutIfNeeded];
    _titleLabel.center = CGPointMake(self.frame.size.width/2+(_isAnimated && self.isSelected ? _markDoneImageView.frame.size.width/2 : 0), self.frame.size.height/2);
    _titleLabel.frame = CGRectIntegral(_titleLabel.frame);
    
    _markDoneImageView.center = CGPointMake(_titleLabel.frame.origin.x-shift/2-_markDoneImageView.frame.size.width/2, self.frame.size.height/2);
    _markDoneImageView.frame = CGRectIntegral(_markDoneImageView.frame);
    
    _indicator.center = _markDoneImageView.center;
    _indicator.frame = CGRectIntegral(_indicator.frame);
    
    if (_isAnimated && self.isSelected)
    {
        _markDoneImageView.hidden = NO;
        _markDoneImageView.alpha = 1.f;
    }
    else
    {
        _markDoneImageView.hidden = YES;
        _markDoneImageView.alpha = 0.f;
    }
    
    CGFloat stripeThinkness = (kIsRetina ? 0.5f : 1.f);
    
    _stripeView.frame = CGRectMake(0, self.frame.size.height-stripeThinkness, self.frame.size.width, stripeThinkness);
    
    _isOnSuperview = YES;
}

@end
