//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "BottomTableViewCellLoading.h"
#import "BottomTableViewCell+protected.h"
#import "LGKit.h"
#import "Settings.h"
#import "BottomThemeObject.h"

#pragma mark - Private

@interface BottomTableViewCellLoading ()

@end

#pragma mark - Implementation

@implementation BottomTableViewCellLoading

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _indicator = [UIActivityIndicatorView new];
        _indicator.backgroundColor = kColorClear;
        [_indicator stopAnimating];
        [self addSubview:_indicator];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    
    CGFloat verticalShift = 0.f;
    if (kSystemVersion < 7 && self.isFirstCell) verticalShift = 1.f; // Костыль для iOS6
    
    _indicator.center = CGPointMake(frame.size.width-20.f, frame.size.height/2-verticalShift);
    _indicator.frame = CGRectIntegral(_indicator.frame);
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    [self setSelected:self.isSelected animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [self setHighlighted:highlighted selected:self.isSelected];
    
    //if (highlighted != self.isHighlighted) [self showAnimation];
    //if (!highlighted && highlighted != self.isHighlighted) [self showAnimation];
    
    [super setHighlighted:highlighted animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self setHighlighted:self.isHighlighted selected:selected];
    
    //if (selected != self.isSelected) [self showAnimation];
    //if (!selected && selected != self.isSelected) [self showAnimation];
    
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted selected:(BOOL)selected
{
    if (highlighted || selected)
    {
        self.bgView.backgroundColor = kBottomTheme.cellBgSelectedColor;
        self.textLabel.textColor = kBottomTheme.cellTextSelectedColor;
        self.leftStripeView.backgroundColor = kBottomTheme.cellLeftStripeSelectedColor;
        self.indicator.color = kBottomTheme.cellTextSelectedColor;
    }
    else
    {
        self.bgView.backgroundColor = kBottomTheme.cellBgColor;
        self.textLabel.textColor = kBottomTheme.cellTextColor;
        self.leftStripeView.backgroundColor = kBottomTheme.cellLeftStripeColor;
        self.indicator.color = kBottomTheme.cellTextColor;
    }
}

@end
