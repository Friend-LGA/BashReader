//
//  BottomTableViewCell_BottomTableViewCell_protected.h
//  Bash
//
//  Created by Friend_LGA on 23.10.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "BottomTableViewCell.h"

@interface BottomTableViewCell (protected)

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *bottomStripeView;
@property (strong, nonatomic) UIView *leftStripeView;

- (void)showAnimation;

@end
