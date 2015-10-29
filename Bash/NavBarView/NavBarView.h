//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class
NavBarButton,
NavBarSearchField;

@interface NavBarView : UIView

@property (strong, nonatomic, readonly) UILabel           *titleLabel;
@property (strong, nonatomic, readonly) NavBarButton      *leftButton;
@property (strong, nonatomic, readonly) NavBarButton      *rightButton;
@property (strong, nonatomic, readonly) NavBarSearchField *searchField;

- (BOOL)searchFieldIsFirstResponder;
- (void)searchFieldBecomeFirstResponder;
- (void)searchFieldResignFirstResponder;
- (void)resizeAndRepositionAfterRotateToSize:(CGSize)size;

@end