//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "TopTableViewCellStandartFull.h"
#import "TopTableViewCell+protected.h"
#import "LGKit.h"
#import "Settings.h"
#import "TopThemeObject.h"
#import "PrerenderedImages.h"
#import "LGCoreData.h"
#import "BashCashQuoteObject.h"
#import "LGChapter.h"

static NSTimeInterval const kAnimationDuration = 0.2;

#pragma mark - Private

@interface TopTableViewCellStandartFull ()

@property (strong, nonatomic) UILabel   *bayanLabel;
@property (assign, nonatomic) BOOL      isButtonsEnable;

@end

#pragma mark - Implementation

@implementation TopTableViewCellStandartFull

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
        
        _ratingLabel = [UILabel new];
        _ratingLabel.backgroundColor = kColorClear;
        _ratingLabel.font = [UIFont systemFontOfSize:14];
        _ratingLabel.textAlignment = NSTextAlignmentCenter;
        _ratingLabel.numberOfLines = 1;
        [self addSubview:_ratingLabel];
        
        _numberLabel = [UILabel new];
        _numberLabel.backgroundColor = kColorClear;
        _numberLabel.font = [UIFont systemFontOfSize:14];
        _numberLabel.textAlignment = NSTextAlignmentRight;
        _numberLabel.numberOfLines = 1;
        [self addSubview:_numberLabel];
        
        _plusImageView = [UIImageView new];
        _plusImageView.backgroundColor = kColorClear;
        _plusImageView.clipsToBounds = YES;
        [self addSubview:_plusImageView];
        
        _minusImageView = [UIImageView new];
        _minusImageView.backgroundColor = kColorClear;
        _minusImageView.clipsToBounds = YES;
        [self addSubview:_minusImageView];
        
        _bayanImageView = [UIImageView new];
        _bayanImageView.backgroundColor = kColorClear;
        _bayanImageView.clipsToBounds = YES;
        [self addSubview:_bayanImageView];
        
        _bayanLabel = [UILabel new];
        _bayanLabel.text = @"[:||||:]";
        _bayanLabel.backgroundColor = kColorClear;
        _bayanLabel.font = [UIFont systemFontOfSize:13];
        _bayanLabel.textAlignment = NSTextAlignmentCenter;
        _bayanLabel.numberOfLines = 1;
        [self addSubview:_bayanLabel];
        
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
    
    if (_isButtonsEnable)
    {
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
        
        CGFloat ratingShift = 23.f;
        
        _ratingLabel.textColor = (_quote.ratingTaps ? kTopTheme.textColor : kTopTheme.subtextColor);
        [_ratingLabel sizeToFit];
        [_ratingLabel layoutIfNeeded];
        
        _plusImageView.image = (_quote.ratingSelected == QuoteRatingPlus ? kPrerenderedImages.ratingPlusSelectedImage : kPrerenderedImages.ratingPlusImage);
        [_plusImageView sizeToFit];
        [_plusImageView layoutIfNeeded];
        _plusImageView.center = CGPointMake(frame.origin.x+_plusImageView.frame.size.width/2, _textLabel.frame.origin.y+_textLabel.frame.size.height+_ratingLabel.frame.size.height/2+heightShift);
        _plusImageView.frame = CGRectIntegral(_plusImageView.frame);
        
        _ratingLabel.center = CGPointMake(_plusImageView.frame.origin.x+_plusImageView.frame.size.height+ratingShift, _plusImageView.center.y);
        _ratingLabel.frame = CGRectIntegral(_ratingLabel.frame);
        
        _minusImageView.image = (_quote.ratingSelected == QuoteRatingMinus ? kPrerenderedImages.ratingMinusSelectedImage : kPrerenderedImages.ratingMinusImage);
        [_minusImageView sizeToFit];
        [_minusImageView layoutIfNeeded];
        _minusImageView.center = CGPointMake(_ratingLabel.center.x+ratingShift+_minusImageView.frame.size.width/2, _plusImageView.center.y);
        _minusImageView.frame = CGRectIntegral(_minusImageView.frame);
        
        _bayanLabel.textColor = (_quote.ratingSelected == QuoteRatingBayan ? kTopTheme.plusMinusSelectedColor : kTopTheme.plusMinusColor);
        [_bayanLabel sizeToFit];
        [_bayanLabel layoutIfNeeded];
        
        UIImage *image = (_quote.ratingSelected == QuoteRatingBayan ? kPrerenderedImages.ratingBayanSelectedImage : kPrerenderedImages.ratingBayanImage);
        
        CGFloat side = image.size.width;
        CGFloat inset = side/2 - 0.5;
        
        _bayanImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(inset, inset, inset, inset)];
        _bayanImageView.frame = CGRectMake(0, 0, _bayanLabel.frame.size.width+30, side);
        _bayanImageView.center = CGPointMake(_minusImageView.frame.origin.x+_minusImageView.frame.size.width+widthShift+_bayanImageView.frame.size.width/2, _plusImageView.center.y);
        _bayanImageView.frame = CGRectIntegral(_bayanImageView.frame);
        
        _bayanLabel.center = CGPointMake(_bayanImageView.center.x+0.5, _plusImageView.center.y-1);
        _bayanLabel.frame = CGRectIntegral(_bayanLabel.frame);
        
        _favouriteImageView.image = (_quote.isFavourite ? kPrerenderedImages.favouriteSelectedImage : kPrerenderedImages.favouriteImage);
        [_favouriteImageView sizeToFit];
        [_favouriteImageView layoutIfNeeded];
        _favouriteImageView.center = CGPointMake(frame.origin.x+frame.size.width-_favouriteImageView.frame.size.width/2, _plusImageView.center.y);
        _favouriteImageView.frame = CGRectIntegral(_favouriteImageView.frame);
        
        self.height = _ratingLabel.frame.origin.y+_ratingLabel.frame.size.height+heightShift+verticalShift;
        
        // -----------------------------------------
        
        widthShift = 1.f;
        
        if (kTopTheme.cellBgType == TopThemeCellBgTypeFull)
            self.bgView.frame = CGRectMake(frame.origin.x-widthShift, 0, frame.size.width+widthShift*2, frame.size.height-verticalShift);
        else
            self.bgView.frame = CGRectMake(frame.origin.x-widthShift, _textLabel.frame.origin.y-heightShift/2, frame.size.width+widthShift*2, _textLabel.frame.size.height+heightShift);
        
        [self updateBgViewImage];
    }
}

#pragma mark -

- (void)setQuote:(BashCashQuoteObject *)quote
{
    _quote              = quote;
    _textLabel.text     = quote.text;
    _dateLabel.text     = quote.date;
    _numberLabel.text   = (quote.number ? [NSString stringWithFormat:@"%@%lu", (kLGChapter.type == LGChapterTypeAbyssBest ? @"#AA-" : @"#"), (unsigned long)quote.number] : @"");
    _ratingLabel.text   = [NSString stringWithFormat:@"%@", quote.ratingString];
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
        
        [kLGKit animationWithCrossDissolveView:_favouriteImageView duration:kAnimationDuration completionHandler:^(BOOL complete)
         {
             _isButtonsEnable = YES;
         }];
    }
}

#pragma mark -

- (void)setPlusButtonSelected:(BOOL)selected
{
    if (!_quote.ratingTaps) [self sendRequestToURLString:[NSString stringWithFormat:@"http://bash.im/quote/%lu/rulez", (unsigned long)_quote.number]];
    
    if (_isButtonsEnable || !selected)
    {
        _isButtonsEnable = NO;
        
        if ((_quote.ratingSelected != QuoteRatingPlus && selected) || !selected)
        {
            _plusImageView.image = (selected ? kPrerenderedImages.ratingPlusSelectedImage : kPrerenderedImages.ratingPlusImage);
            
            if (selected)
            {
                _quote.ratingSelected = QuoteRatingPlus;
                
                [self setMinusButtonSelected:NO];
                [self setBayanButtonSelected:NO];
            }
            
            [kLGKit animationWithCrossDissolveView:_plusImageView duration:kAnimationDuration];
        }
        
        if (selected)
        {
            _quote.ratingTaps++;
            
            [self updateRatingLabel];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                           {
                               _isButtonsEnable = YES;
                           });
        }
    }
}

- (void)setMinusButtonSelected:(BOOL)selected
{
    if (!_quote.ratingTaps) [self sendRequestToURLString:[NSString stringWithFormat:@"http://bash.im/quote/%lu/sux", (unsigned long)_quote.number]];
    
    if (_isButtonsEnable || !selected)
    {
        _isButtonsEnable = NO;
        
        if ((_quote.ratingSelected != QuoteRatingMinus && selected) || !selected)
        {
            _minusImageView.image = (selected ? kPrerenderedImages.ratingMinusSelectedImage : kPrerenderedImages.ratingMinusImage);
            
            if (selected)
            {
                _quote.ratingSelected = QuoteRatingMinus;
                
                [self setPlusButtonSelected:NO];
                [self setBayanButtonSelected:NO];
            }
            
            [kLGKit animationWithCrossDissolveView:_minusImageView duration:kAnimationDuration];
        }
        
        if (selected)
        {
            _quote.ratingTaps++;
            
            [self updateRatingLabel];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                           {
                               _isButtonsEnable = YES;
                           });
        }
    }
}

- (void)setBayanButtonSelected:(BOOL)selected
{
    if (!_quote.ratingTaps) [self sendRequestToURLString:[NSString stringWithFormat:@"http://bash.im/quote/%lu/bayan", (unsigned long)_quote.number]];
    
    if (_isButtonsEnable || !selected)
    {
        _isButtonsEnable = NO;
        
        if ((_quote.ratingSelected != QuoteRatingBayan && selected) || !selected)
        {
            UIImage *image = (selected ? kPrerenderedImages.ratingBayanSelectedImage : kPrerenderedImages.ratingBayanImage);
            
            CGFloat side = image.size.width;
            CGFloat inset = side/2 - 0.5;
            
            _bayanImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(inset, inset, inset, inset)];
            _bayanLabel.textColor = (selected ? kTopTheme.plusMinusSelectedColor : kTopTheme.plusMinusColor);
            
            if (selected)
            {
                _quote.ratingSelected = QuoteRatingBayan;
                
                [self setPlusButtonSelected:NO];
                [self setMinusButtonSelected:NO];
            }
            
            [kLGKit animationWithCrossDissolveView:_bayanImageView duration:kAnimationDuration];
        }
        
        if (selected)
        {
            _quote.ratingTaps++;
            
            [self updateRatingLabel];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                           {
                               _isButtonsEnable = YES;
                           });
        }
    }
}

#pragma mark -

- (void)sendRequestToURLString:(NSString *)URLString
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(self = %@)", URLString];
    NSArray *filtered = [kSettings.quotesNeedRating filteredArrayUsingPredicate:pred];
    
    if (!filtered.count)
    {
        if (kInternetStatus)
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString]]
                                               queue:[NSOperationQueue new]
                                   completionHandler:nil];
        else
            [kSettings.quotesNeedRating addObject:URLString];
    }
}

- (void)updateRatingLabel
{
    if (_quote.ratingTaps == 1)
    {
        CGFloat ratingLabelHeight = _ratingLabel.frame.size.height;
        
        [UIView animateWithDuration:kAnimationDuration/2
                         animations:^(void)
         {
             if (_quote.ratingSelected == QuoteRatingPlus)
                 _ratingLabel.center = CGPointMake(_ratingLabel.center.x, _ratingLabel.center.y-ratingLabelHeight/2);
             else
                 _ratingLabel.center = CGPointMake(_ratingLabel.center.x, _ratingLabel.center.y+ratingLabelHeight/2);
             
             _ratingLabel.transform = CGAffineTransformMakeScale(1, 0.01);
         }
                         completion:^(BOOL finished)
         {
             [self changeRatingLabel];
             
             if (_quote.ratingSelected == QuoteRatingPlus)
                 _ratingLabel.center = CGPointMake(_ratingLabel.center.x, _ratingLabel.center.y+ratingLabelHeight);
             else
                 _ratingLabel.center = CGPointMake(_ratingLabel.center.x, _ratingLabel.center.y-ratingLabelHeight);
             
             [UIView animateWithDuration:kAnimationDuration/2
                              animations:^(void)
              {
                  if (_quote.ratingSelected == QuoteRatingPlus)
                      _ratingLabel.center = CGPointMake(_ratingLabel.center.x, _ratingLabel.center.y-ratingLabelHeight/2);
                  else
                      _ratingLabel.center = CGPointMake(_ratingLabel.center.x, _ratingLabel.center.y+ratingLabelHeight/2);
                  
                  _ratingLabel.transform = CGAffineTransformIdentity;
              }];
         }];
    }
    else [self changeRatingLabel];
}

- (void)changeRatingLabel
{
    LOG(@"");
    
    NSUInteger ratingTaps = _quote.ratingTaps;
    
    if (ratingTaps > 0)
    {
        if (_quote.ratingSelected == QuoteRatingPlus)
        {
            if (ratingTaps == 1)
            {
                if (_quote.rating > 0)
                {
                    _quote.rating++;
                    _quote.ratingString = [NSString stringWithFormat:@"%lu", (unsigned long)_quote.rating];
                }
                else _quote.ratingString = @":-)";
            }
            else if (ratingTaps/3 == 0) { }
            else if (ratingTaps/3 == 1) _quote.ratingString = @"(･_･ )";
            else if (ratingTaps/3 == 2) _quote.ratingString = @"(¬_¬ )";
            else if (ratingTaps/3 == 3) _quote.ratingString = @"(ಠ_ಠ )";
            else if (ratingTaps/3 == 4) _quote.ratingString = @"(ಠ＿ಠ )";
            else if (ratingTaps/3 < 7)  _quote.ratingString = @"(ಠ益ಠ )";
            else if (ratingTaps/3 < 9)  _quote.ratingString = @"(>＿< )";
            else if (ratingTaps/3 >= 9) _quote.ratingString = @"(=＿= )";
        }
        else if (_quote.ratingSelected == QuoteRatingMinus || _quote.ratingSelected == QuoteRatingBayan)
        {
            if (ratingTaps == 1)
            {
                if (_quote.ratingSelected == QuoteRatingMinus)
                {
                    if (_quote.rating > 0)
                    {
                        _quote.rating--;
                        _quote.ratingString = [NSString stringWithFormat:@"%lu", (unsigned long)_quote.rating];
                    }
                    else _quote.ratingString = @":-(";
                }
                else _quote.ratingString = @"баян";
            }
            else if (ratingTaps/3 == 0) { }
            else if (ratingTaps/3 == 1) _quote.ratingString = @"( ･_･)";
            else if (ratingTaps/3 == 2) _quote.ratingString = @"( ¬_¬)";
            else if (ratingTaps/3 == 3) _quote.ratingString = @"( ಠ_ಠ)";
            else if (ratingTaps/3 == 4) _quote.ratingString = @"( ಠ＿ಠ)";
            else if (ratingTaps/3 < 7)  _quote.ratingString = @"( ಠ益ಠ)";
            else if (ratingTaps/3 < 9)  _quote.ratingString = @"( >＿<)";
            else if (ratingTaps/3 >= 9) _quote.ratingString = @"( =＿=)";
        }
        
        CGPoint ratingLabelCenter = _ratingLabel.center;
        _ratingLabel.textColor = kTopTheme.textColor;
        _ratingLabel.text = _quote.ratingString;
        [_ratingLabel sizeToFit];
        [_ratingLabel layoutIfNeeded];
        _ratingLabel.center = ratingLabelCenter;
    }
}

@end









