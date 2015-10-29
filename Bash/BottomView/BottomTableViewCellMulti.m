//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "BottomTableViewCellMulti.h"
#import "BottomTableViewCell+protected.h"
#import "LGKit.h"
#import "Settings.h"
#import "BottomThemeObject.h"
#import "PrerenderedImages.h"

#pragma mark - Private

@interface BottomTableViewCellMulti ()

@end

#pragma mark - Implementation

@implementation BottomTableViewCellMulti

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        //
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    
    CGFloat shift = 0.f;
    if (kSystemVersion < 7) shift += 9.f; // Костыль для iOS6
    
    CGFloat verticalShift = 0.f;
    if (kSystemVersion < 7 && self.isFirstCell) verticalShift = 1.f; // Костыль для iOS6
    
    self.imageView.center = CGPointMake(frame.size.width-self.imageView.frame.size.width/2-shift, frame.size.height/2-verticalShift);
    self.imageView.frame = CGRectIntegral(self.imageView.frame);
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    [self setSelected:self.isSelected animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted)
    {
        if (!self.isSelected)
        {
            self.bgView.backgroundColor = kBottomTheme.cellMultiBgSelectedColor;
            self.textLabel.textColor = kBottomTheme.cellMultiTextSelectedColor;
            self.leftStripeView.backgroundColor = kBottomTheme.cellMultiLeftStripeSelectedColor;
            self.imageView.image = kPrerenderedImages.multiCellPlusHighlightedImage;
        }
        else
        {
            self.bgView.backgroundColor = kBottomTheme.cellBgColor;
            self.textLabel.textColor = kBottomTheme.cellTextColor;
            self.leftStripeView.backgroundColor = kBottomTheme.cellMultiLeftStripeColor;
            self.imageView.image = kPrerenderedImages.multiCellMinusHighlightedImage;
        }
    }
    else
    {
        if (self.isSelected)
        {
            self.bgView.backgroundColor = kBottomTheme.cellMultiBgSelectedColor;
            self.textLabel.textColor = kBottomTheme.cellMultiTextSelectedColor;
            self.leftStripeView.backgroundColor = kBottomTheme.cellMultiLeftStripeSelectedColor;
            self.imageView.image = kPrerenderedImages.multiCellMinusImage;
        }
        else
        {
            self.bgView.backgroundColor = kBottomTheme.cellBgColor;
            self.textLabel.textColor = kBottomTheme.cellTextColor;
            self.leftStripeView.backgroundColor = kBottomTheme.cellMultiLeftStripeColor;
            self.imageView.image = kPrerenderedImages.multiCellPlusImage;
        }
    }
    
    //if (highlighted != self.isHighlighted) [self showAnimation];
    //if (!highlighted && highlighted != self.isHighlighted) [self showAnimation];
    
    [super setHighlighted:highlighted animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected)
    {
        self.bgView.backgroundColor = kBottomTheme.cellMultiBgSelectedColor;
        self.textLabel.textColor = kBottomTheme.cellMultiTextSelectedColor;
        self.leftStripeView.backgroundColor = kBottomTheme.cellMultiLeftStripeSelectedColor;
        self.imageView.image = kPrerenderedImages.multiCellMinusImage;
    }
    else
    {
        self.bgView.backgroundColor = kBottomTheme.cellBgColor;
        self.textLabel.textColor = kBottomTheme.cellTextColor;
        self.leftStripeView.backgroundColor = kBottomTheme.cellMultiLeftStripeColor;
        self.imageView.image = kPrerenderedImages.multiCellPlusImage;
    }
    
    //if (selected != self.isSelected) [self showAnimation];
    //if (!selected && selected != self.isSelected) [self showAnimation];
    
    [super setSelected:selected animated:animated];
}

@end
