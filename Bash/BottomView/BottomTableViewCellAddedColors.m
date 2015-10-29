//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "BottomTableViewCellAddedColors.h"
#import "BottomTableViewCell+protected.h"
#import "LGKit.h"
#import "Settings.h"
#import "BottomThemeObject.h"

#pragma mark - Private

@interface BottomTableViewCellAddedColors ()

@end

#pragma mark - Implementation

@implementation BottomTableViewCellAddedColors

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
    
    self.imageView.image = [kLGKit circleWithColor:_color];
    [self.imageView sizeToFit];
    [self.imageView layoutIfNeeded];
    self.imageView.center = CGPointMake(self.textLabel.frame.origin.x+self.textLabel.frame.size.width+self.imageView.frame.size.width/2, frame.size.height/2);
    self.imageView.frame = CGRectIntegral(self.imageView.frame);
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
        self.leftStripeView.backgroundColor = kBottomTheme.cellAddedLeftStripeSelectedColor;
        self.textLabel.textColor = kBottomTheme.cellTextSelectedColor;
    }
    else
    {
        self.bgView.backgroundColor = kBottomTheme.cellBgColor;
        self.leftStripeView.backgroundColor = kBottomTheme.cellAddedLeftStripeColor;
        self.textLabel.textColor = kBottomTheme.cellTextColor;
    }
}

@end
