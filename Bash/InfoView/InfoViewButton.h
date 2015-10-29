//
//  InfoViewButton.h
//  Bash
//
//  Created by Friend_LGA on 24.01.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewButton : UIButton

@property (strong, nonatomic) UILabel   *titleLabel;
@property (assign, nonatomic) BOOL      *isAnimated;

- (id)initWithTitle:(NSString *)title;
- (void)doneAction;
- (void)undoneAction;

@end
