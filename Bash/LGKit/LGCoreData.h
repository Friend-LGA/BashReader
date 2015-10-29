//
//  LGCoreData.h
//  Bash
//
//  Created by Friend_LGA on 13.03.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class
BashCashQuotesEntity,
BashCashQuoteObject;

@interface LGCoreData : NSObject

+ (instancetype)sharedManager;
- (void)initialize;

- (BOOL)isBashFavouriteQuotesDataBaseRecreated;
- (void)saveBashFavouriteQuotesDataBaseToLocalBackup;

- (NSManagedObjectContext *)getContextOfBashFavouriteQuotesDataBase;
- (void)saveContextOfBashFavouriteQuotesDataBase;
- (NSArray *)getArrayOfBashFavouriteQuotesDataBaseWithSortDescriptor:(NSSortDescriptor *)sortDescriptor start:(NSUInteger)start limit:(NSUInteger)limit;
- (NSUInteger)getNumberOfObjectsInFavouriteDataBase;

- (NSManagedObjectContext *)getContextOfBashCashQuotesDataBase;
- (NSArray *)getArrayOfBashCashQuotesDataBaseWithEntity:(NSString *)entity sortDescriptor:(NSSortDescriptor *)sortDescriptor start:(NSUInteger)start limit:(NSUInteger)limit;
- (NSUInteger)getNumberOfObjectsInCashDataBaseWithEntity:(NSString *)entity;

- (int)getNumberOfQuotesInCash;
- (NSString *)getSizeOfQuotesInCash;
- (void)removeQuotesInCash;

- (BOOL)isQuoteInFavourites:(BashCashQuotesEntity *)quote;
- (void)addQuoteToFavourites:(BashCashQuoteObject *)quote;
- (void)removeQuoteFromFavourites:(BashCashQuoteObject *)quote;
- (void)clearBashCashQuotesDataBaseForEntity:(NSString *)entity;

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

@end
