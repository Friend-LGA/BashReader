//
//  LGDocument.h
//  Bash
//
//  Created by Friend_LGA on 21.02.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BashCashQuotesEntity.h"

@interface LGDocuments : NSObject

@property (strong, nonatomic) NSError *initializationError;

+ (instancetype)sharedManager;

- (void)initOpenSyncCloudDocuments;
- (void)initOpenReplaceOldCloudDocuments;
- (void)closeAllCloudDocuments;
- (NSMutableArray *)getArrayOfCloudDocument;
- (void)saveCloudDocumentWithArray:(NSMutableArray *)array;

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

@end
