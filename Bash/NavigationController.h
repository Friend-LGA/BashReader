//
//  NavigationController.h
//  Bash
//
//  Created by Friend_LGA on 26.12.13.
//  Copyright (c) 2013 Grigory Lutkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class
BottomView,
TopView,
InfoView;

@interface NavigationController : UINavigationController

@property (strong, nonatomic) BottomView    *menuView;
@property (strong, nonatomic) TopView       *mainView;
@property (strong, nonatomic) InfoView      *infoView;

@property (assign, nonatomic, readonly, getter=isLaunched)  BOOL launched;
@property (assign, nonatomic, getter=isMenuEnabled)         BOOL menuEnabled;
@property (assign, nonatomic, getter=isRotationBlocked)     BOOL rotationBlocked;

- (void)showUpdateInfo;
- (void)showHelpInfo;
- (void)showSyncInfo;
- (void)showFileVersionError;
- (void)openCloseMenuAction;
- (void)resizeViewsToSize:(CGSize)size;
- (void)updateMainViewAfterRotate;

@end
