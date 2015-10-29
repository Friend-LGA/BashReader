//
//  BottomTableViewCell.m
//  Bash
//
//  Created by Friend_LGA on 23.10.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "BottomTableViewCell.h"
#import "LGKit.h"
#import "Settings.h"
#import "BottomThemeObject.h"

#pragma mark - Private

@interface BottomTableViewCell ()

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *bottomStripeView;
@property (strong, nonatomic) UIView *leftStripeView;

@end

@implementation BottomTableViewCell

#pragma mark - Implementation

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = kColorClear;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.userInteractionEnabled = YES;
        self.backgroundView = nil;
        self.selectedBackgroundView = nil;
        
        self.textLabel.backgroundColor = kColorClear;
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.font = kBottomTheme.font;
        
        _bgView = [UIView new];
        [self insertSubview:_bgView atIndex:0];
        
        _leftStripeView = [UIView new];
        [self addSubview:_leftStripeView];
        
        _bottomStripeView = [UIView new];
        _bottomStripeView.backgroundColor = kBottomTheme.cellSeparatorColor;
        [self addSubview:_bottomStripeView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    
    CGFloat shift = 10.f+kSlideStock;
    if (kSystemVersion < 7) shift -= 9.f; // Костыль для iOS6
    
    CGFloat verticalShift = 0.f;
    if (kSystemVersion < 7 && _isFirstCell) verticalShift = 1.f; // Костыль для iOS6
    
    [self.textLabel sizeToFit];
    [self.textLabel layoutIfNeeded];
    self.textLabel.center = CGPointMake(self.textLabel.frame.size.width/2+shift, frame.size.height/2-verticalShift);
    self.textLabel.frame = CGRectIntegral(self.textLabel.frame);
    
    _bgView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _leftStripeView.frame = CGRectMake(0, 0, kBottomTheme.cellLeftStripeThickness+kSlideStock, frame.size.height);
    _bottomStripeView.frame = CGRectMake(0, frame.size.height-kBottomTheme.cellSeparatorThickness, frame.size.width, kBottomTheme.cellSeparatorThickness);
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    _bottomStripeView.backgroundColor = kBottomTheme.cellSeparatorColor;
}

- (void)showAnimation
{
    [UIView transitionWithView:self
                      duration:0.15
                       options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
}

@end
