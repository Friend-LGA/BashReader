//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "TopTableViewCell.h"

@class BashCashQuoteObject;

@interface TopTableViewCellStandartShort : TopTableViewCell

@property (assign, nonatomic) BashCashQuoteObject *quote;

@property (strong, nonatomic, readonly) UILabel     *dateLabel;
@property (strong, nonatomic, readonly) UILabel     *numberLabel;
@property (strong, nonatomic, readonly) UIImageView *favouriteImageView;

- (void)selectFavouriteButtonWithAction:(BOOL)action;

@end
