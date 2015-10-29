//
//  LGGoogleAnalytics.h
//  Bash
//
//  Created by Friend_LGA on 01.02.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGGoogleAnalytics : NSObject

+ (instancetype)sharedManager;
- (void)initialize;

- (void)setScreenName:(NSString *)name sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
- (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

@end
