//
//  LGVersions.h
//  Bash
//
//  Created by Friend_LGA on 03.03.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Versions : NSObject

+ (instancetype)sharedManager;

- (void)check;
- (BOOL)isNeedsToReplaceLocalDataBase;
- (void)setNeedsToReplaceLocalDataBase:(BOOL)needsToReplaceLocalDataBase;
- (BOOL)isNeedsToReplaceCloudDocument;
- (void)setNeedsToReplaceCloudDocument:(BOOL)needsToReplaceCloudDocument;

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

@end
