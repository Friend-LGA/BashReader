//
//  BashCashQuotesDataBase.h
//  Bash
//
//  Created by Friend_LGA on 13.03.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BashCashQuotesDataBase : NSObject

+ (instancetype)sharedManager;

- (NSManagedObjectContext *)managedObjectContext;
- (void)saveContext;
- (void)recreate;

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

@end
