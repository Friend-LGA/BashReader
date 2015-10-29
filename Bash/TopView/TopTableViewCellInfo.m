//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "TopTableViewCellInfo.h"
#import "TopTableViewCell+protected.h"
#import "LGKit.h"
#import "Settings.h"
#import "TopThemeObject.h"

#pragma mark - Private

@interface TopTableViewCellInfo ()

@end

#pragma mark - Implementation

@implementation TopTableViewCellInfo

@synthesize textLabel = _textLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _textLabel = [UILabel new];
        _textLabel.backgroundColor = kColorClear;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = CGRectMake(self.originX, 0.f, self.width, self.frame.size.height);
    frame = CGRectIntegral(frame);
    
    CGFloat verticalShift = kTopTheme.cellIndent;
    CGFloat widthShift = 10.f;
    CGFloat heightShift = 15.f;
    
    _textLabel.font = kTopTheme.font;
    _textLabel.textColor = kTopTheme.subtextColor;
    _textLabel.frame = CGRectMake(0, 0, frame.size.width-widthShift*2, CGFLOAT_MAX);
    [_textLabel sizeToFit];
    [_textLabel layoutIfNeeded];
    _textLabel.center = CGPointMake(frame.origin.x+frame.size.width/2, _textLabel.frame.size.height/2+heightShift);
    _textLabel.frame = CGRectIntegral(_textLabel.frame);
    
    self.height = _textLabel.frame.size.height+heightShift*2+verticalShift;
    
    // -----------------------------------------
    
    widthShift = 1.f;
    
    if (kTopTheme.cellBgType == TopThemeCellBgTypeFull)
        self.bgView.frame = CGRectMake(frame.origin.x-widthShift, 0, frame.size.width+widthShift*2, frame.size.height-verticalShift);
    else
        self.bgView.frame = CGRectMake(frame.origin.x-widthShift, _textLabel.frame.origin.y-heightShift, frame.size.width+widthShift*2, _textLabel.frame.size.height+heightShift*2);
    
    [self updateBgViewImage];
}

@end
