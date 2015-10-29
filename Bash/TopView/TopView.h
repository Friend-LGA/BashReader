//
//  TopView.h
//  Bash
//
//  Created by Friend_LGA on 26.12.13.
//  Copyright (c) 2013 Grigory Lutkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopView : UIView

typedef enum
{
    LGTopStatusBarViewAnimationTypeShow,
    LGTopStatusBarViewAnimationTypeHide
}
LGTopStatusBarViewAnimationType;

- (void)reload;
- (void)resizeAndRepositionAfterRotateToSize:(CGSize)size;
- (void)doubleTapGesture:(UITapGestureRecognizer *)sender;

- (BOOL)navBarViewSearchFieldIsFirstResponder;
- (void)navBarViewSearchFieldBecomeFirstResponder;
- (void)navBarViewSearchFieldResignFirstResponder;

- (void)tableViewReloadWithCompletionHandler:(void(^)())completionHandler;
- (void)tableViewSetScrollsToTop:(BOOL)k;
- (void)tableViewRefreshWithCompletionHandler:(void(^)())completionHandler;
- (void)tableViewLoadQuotes;
- (void)tableViewCancelLoading;
- (void)tableViewDeleteTappedRow;
- (void)tableViewHidden:(BOOL)hidden animated:(BOOL)animated;
- (BOOL)tableViewIsHidden;
- (void)tableViewContentInsetUpdate;

@end
