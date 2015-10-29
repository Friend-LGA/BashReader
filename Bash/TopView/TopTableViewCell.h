//
//  TopTableViewCell.h
//  Bash
//
//  Created by Friend_LGA on 02.11.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopTableViewCell : UITableViewCell

@property (assign, nonatomic) CGFloat originX;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;

@property (strong, nonatomic, readonly) UIImageView *bgView;

@end
