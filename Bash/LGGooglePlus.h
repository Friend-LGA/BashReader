//
//  LGGooglePlus.h
//  Rush
//
//  Created by Admin on 30.05.14.
//  Copyright (c) 2014 SoftInvent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGGooglePlus : NSObject

+ (instancetype)sharedManager;

- (void)postWithText:(NSString *)text image:(UIImage *)image link:(NSURL *)link completionHandler:(void(^)(BOOL result))completionHandler;

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

@end
