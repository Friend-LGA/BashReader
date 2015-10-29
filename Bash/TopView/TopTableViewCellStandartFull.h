//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "TopTableViewCell.h"

@class BashCashQuoteObject;

@interface TopTableViewCellStandartFull : TopTableViewCell

@property (assign, nonatomic) BashCashQuoteObject *quote;

@property (strong, nonatomic, readonly) UILabel             *dateLabel;
@property (strong, nonatomic, readonly) UILabel             *ratingLabel;
@property (strong, nonatomic, readonly) UILabel             *numberLabel;
@property (strong, nonatomic, readonly) UIImageView         *plusImageView;
@property (strong, nonatomic, readonly) UIImageView         *minusImageView;
@property (strong, nonatomic, readonly) UIImageView         *bayanImageView;
@property (strong, nonatomic, readonly) UIImageView         *favouriteImageView;

- (void)setPlusButtonSelected:(BOOL)selected;
- (void)setMinusButtonSelected:(BOOL)selected;
- (void)setBayanButtonSelected:(BOOL)selected;
- (void)selectFavouriteButtonWithAction:(BOOL)action;

@end
