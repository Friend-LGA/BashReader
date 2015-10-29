//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "BottomTableViewSectionHeader.h"
#import "LGKit.h"
#import "Settings.h"
#import "BottomThemeObject.h"

#pragma mark - Private

@interface BottomTableViewSectionHeader ()

@property (strong, nonatomic) UIView *bottomStripeView;

@end

#pragma mark - Implementation

@implementation BottomTableViewSectionHeader

- (id)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = kBottomTheme.backgroundColor;
        self.userInteractionEnabled = NO;
        
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = kColorClear;
        _titleLabel.font = kBottomTheme.font;
        _titleLabel.textColor = kBottomTheme.sectionTextColor;
        _titleLabel.numberOfLines = 1;
        [self addSubview:_titleLabel];
        
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
    
    CGFloat verticalShift = 0.f;
    if (!_isFirstSection) verticalShift = 1.f; // Костыль для iOS6 и iOS7
    
    [_titleLabel sizeToFit];
    [_titleLabel layoutIfNeeded];
    _titleLabel.center = CGPointMake(shift+_titleLabel.frame.size.width/2, frame.size.height/2-verticalShift);
    _titleLabel.frame = CGRectIntegral(_titleLabel.frame);
    
    _bottomStripeView.frame = CGRectMake(0, frame.size.height-kBottomTheme.cellSeparatorThickness, frame.size.width, kBottomTheme.cellSeparatorThickness);
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    self.backgroundColor = kBottomTheme.backgroundColor;
    _titleLabel.textColor = kBottomTheme.sectionTextColor;
    _bottomStripeView.backgroundColor = kBottomTheme.cellSeparatorColor;
}

@end
