//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LGChapter;

@interface QuoteGetter : NSObject

@property (strong, nonatomic, readonly) NSMutableArray  *statsArray;
@property (assign, nonatomic, readonly) NSUInteger      quotesAmount;

- (void)getQuotesForChapter:(LGChapter *)chapter completionHandler:(void(^)(NSError *error, NSMutableArray *quotesArray))completionHandler;
- (void)cancell;

@end
