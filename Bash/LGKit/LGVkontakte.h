//
//  LGVkontakte.h
//  Bash
//
//  Created by Friend_LGA on 11.11.13.
//  Copyright (c) 2013 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKSdk.h"

@interface LGVkontakte : NSObject

+ (instancetype)sharedManager;

- (void)postWithText:(NSString *)text image:(UIImage *)image link:(NSURL *)link completionHandler:(void(^)(BOOL result))completionHandler;
- (BOOL)logout;

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

@end
