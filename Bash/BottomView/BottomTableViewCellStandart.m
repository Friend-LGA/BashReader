//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "BottomTableViewCellStandart.h"
#import "BottomTableViewCell+protected.h"
#import "LGKit.h"
#import "Settings.h"
#import "BottomThemeObject.h"

#pragma mark - Private

@interface BottomTableViewCellStandart ()

@end

#pragma mark - Implementation

@implementation BottomTableViewCellStandart

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
    }
    else
    {
        self.bgView.backgroundColor = kBottomTheme.cellBgColor;
        self.textLabel.textColor = kBottomTheme.cellTextColor;
        self.leftStripeView.backgroundColor = kBottomTheme.cellLeftStripeColor;
    }
}

@end
