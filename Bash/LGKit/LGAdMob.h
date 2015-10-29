//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"

@interface LGAdMob : NSObject <GADBannerViewDelegate>

@property (strong, nonatomic, readonly) GADBannerView   *bannerView;
@property (assign, nonatomic, readonly) BOOL            isAdsReceive;

+ (instancetype)sharedManager;
- (UIView *)initialize;

- (void)sendRequest;
- (void)bannerHide;
- (void)resizeAndRepositionAfterRotateToSize:(CGSize)size;

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

@end
