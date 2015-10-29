//
//  BottomView.h
//  Bash
//
//  Created by Friend_LGA on 26.12.13.
//  Copyright (c) 2013 Grigory Lutkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomView : UIView

@property (assign, nonatomic) BOOL isOpened;
@property (assign, nonatomic) BOOL isMoving;

- (void)resizeAndRepositionAfterRotateToSize:(CGSize)size;
- (void)tableViewChangeInsetsTopOn:(int)topInset bottomOn:(int)bottomInset;
- (void)tableViewSetScrollsToTop:(BOOL)k;
- (void)tableViewSetCloudSettingsTo:(BOOL)k;
- (void)tableViewCollapseCloudSettings;

//- (void)redrawViewAndSubviews;

@end
