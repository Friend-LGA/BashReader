//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "TopTableViewCellStandartShort.h"
#import "TopTableViewCell+protected.h"
#import "LGKit.h"
#import "Settings.h"
#import "TopThemeObject.h"
#import "PrerenderedImages.h"
#import "LGCoreData.h"
#import "BashCashQuoteObject.h"
#import "LGChapter.h"

#pragma mark - Private

@interface TopTableViewCellStandartShort ()

@property (assign, nonatomic) BOOL isButtonsEnable;

@end

#pragma mark - Implementation

@implementation TopTableViewCellStandartShort

@synthesize textLabel = _textLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _isButtonsEnable = YES;
        
        _textLabel = [UILabel new];
        _textLabel.backgroundColor = kColorClear;
        _textLabel.font = [UIFont systemFontOfSize:kSettings.fontSize];
        _textLabel.numberOfLines = 0;
        [self addSubview:_textLabel];
        
        _dateLabel = [UILabel new];
        _dateLabel.backgroundColor = kColorClear;
        _dateLabel.font = [UIFont systemFontOfSize:14];
        _dateLabel.textAlignment = NSTextAlignmentLeft;
        _dateLabel.numberOfLines = 1;
        [self addSubview:_dateLabel];
        
        _numberLabel = [UILabel new];
        _numberLabel.backgroundColor = kColorClear;
        _numberLabel.font = [UIFont systemFontOfSize:14];
        _numberLabel.textAlignment = NSTextAlignmentRight;
        _numberLabel.numberOfLines = 1;
        [self addSubview:_numberLabel];
        
        _favouriteImageView = [UIImageView new];
        _favouriteImageView.backgroundColor = kColorClear;
        _favouriteImageView.clipsToBounds = YES;
        [self addSubview:_favouriteImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = CGRectMake(self.originX, 0.f, self.width, self.frame.size.height);
    frame = CGRectIntegral(frame);
    
    CGFloat verticalShift = kTopTheme.cellIndent;
    CGFloat widthShift = 5.f;
    CGFloat heightShift = 10.f;
    
    _dateLabel.textColor = kTopTheme.subtextColor;
    [_dateLabel sizeToFit];
    [_dateLabel layoutIfNeeded];
    _dateLabel.center = CGPointMake(frame.origin.x+_dateLabel.frame.size.width/2+widthShift, _dateLabel.frame.size.height/2+heightShift);
    _dateLabel.frame = CGRectIntegral(_dateLabel.frame);
    
    _numberLabel.textColor = kTopTheme.subtextColor;
    [_numberLabel sizeToFit];
    [_numberLabel layoutIfNeeded];
    _numberLabel.center = CGPointMake(frame.origin.x+frame.size.width-_numberLabel.frame.size.width/2-widthShift, _numberLabel.frame.size.height/2+heightShift);
    _numberLabel.frame = CGRectIntegral(_numberLabel.frame);
    
    _textLabel.font = [UIFont systemFontOfSize:kSettings.fontSize];
    _textLabel.textColor = kTopTheme.textColor;
    _textLabel.frame = CGRectMake(0.f, 0.f, frame.size.width-widthShift*2, CGFLOAT_MAX);
    [_textLabel sizeToFit];
    [_textLabel layoutIfNeeded];
    _textLabel.center = CGPointMake(frame.origin.x+_textLabel.frame.size.width/2+widthShift, _dateLabel.frame.origin.y+_dateLabel.frame.size.height+_textLabel.frame.size.height/2+heightShift);
    _textLabel.frame = CGRectIntegral(_textLabel.frame);
    
    _favouriteImageView.image = (_quote.isFavourite ? kPrerenderedImages.favouriteSelectedImage : kPrerenderedImages.favouriteImage);
    [_favouriteImageView sizeToFit];
    [_favouriteImageView layoutIfNeeded];
    _favouriteImageView.center = CGPointMake(frame.origin.x+frame.size.width-_favouriteImageView.frame.size.width/2, _textLabel.frame.origin.y+_textLabel.frame.size.height+_dateLabel.frame.size.height/2+heightShift);
    _favouriteImageView.frame = CGRectIntegral(_favouriteImageView.frame);
    
    self.height = _favouriteImageView.frame.origin.y+_favouriteImageView.frame.size.height+heightShift+verticalShift;
    
    // -----------------------------------------
    
    widthShift = 1.f;
    
    if (kTopTheme.cellBgType == TopThemeCellBgTypeFull)
        self.bgView.frame = CGRectMake(frame.origin.x-widthShift, 0, frame.size.width+widthShift*2, frame.size.height-verticalShift);
    else
        self.bgView.frame = CGRectMake(frame.origin.x-widthShift, _textLabel.frame.origin.y-heightShift/2, frame.size.width+widthShift*2, _textLabel.frame.size.height+heightShift);
    
    [self updateBgViewImage];
}

#pragma mark -

- (void)setQuote:(BashCashQuoteObject *)quote
{
    _quote              = quote;
    _textLabel.text     = quote.text;
    _dateLabel.text     = quote.date;
    _numberLabel.text   = (quote.number ? [NSString stringWithFormat:@"%@%lu", (kLGChapter.type == LGChapterTypeAbyssBest ? @"#AA-" : @"#"), (unsigned long)quote.number] : @"");
}

#pragma mark -

- (void)selectFavouriteButtonWithAction:(BOOL)action
{
    if (_isButtonsEnable)
    {
        _isButtonsEnable = NO;
        
        if (!_quote.isFavourite)
        {
            _favouriteImageView.image = kPrerenderedImages.favouriteSelectedImage;
            
            if (action) [kLGCoreData addQuoteToFavourites:_quote];
        }
        else
        {
            _favouriteImageView.image = kPrerenderedImages.favouriteImage;
            
            if (action) [kLGCoreData removeQuoteFromFavourites:_quote];
        }
        
        _quote.isFavourite = !_quote.isFavourite;
        
        [kLGKit animationWithCrossDissolveView:_favouriteImageView duration:0.2 completionHandler:^(BOOL complete)
         {
             _isButtonsEnable = YES;
         }];
    }
}

@end









