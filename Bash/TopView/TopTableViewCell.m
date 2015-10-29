//
//  TopTableViewCell.m
//  Bash
//
//  Created by Friend_LGA on 02.11.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "TopTableViewCell.h"
#import "LGKit.h"
#import "Settings.h"
#import "TopThemeObject.h"
#import "PrerenderedImages.h"

#pragma mark - Private

@interface TopTableViewCell ()

@end

#pragma mark - Implementation

@implementation TopTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = kColorClear;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.userInteractionEnabled = NO;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundView = nil;
        self.selectedBackgroundView = nil;
        
        _bgView = [UIImageView new];
        _bgView.backgroundColor = kColorClear;
        [self insertSubview:_bgView atIndex:0];
    }
    return self;
}

- (void)updateBgViewImage
{
    if (kTopTheme.type == TopThemeTypeBash)
        self.bgView.image = [kLGKit rectangleDottedWithSize:self.bgView.frame.size];
    else
        self.bgView.image = [kPrerenderedImages.cellBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    
    self.bgView.backgroundColor = kTopTheme.cellBgColor;
}

@end
