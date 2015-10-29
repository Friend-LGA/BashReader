//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#define kCloudDirectoryURL              [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil]
#define kCloudDocumentsDirectoryURL     [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"]
#define kCloudDocumentsBashDirectoryURL [[[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"Bash"]

#import <Foundation/Foundation.h>

@class BashFavouriteQuotesEntity;

@interface LGCloud : NSObject

typedef enum
{
    LGCloudStatusDisabled = 0,
    LGCloudStatusSyncing = 1,
    LGCloudStatusWorking = 2
}
LGCloudStatus;

@property (strong, nonatomic) NSString      *statusDescription;
@property (assign, nonatomic) LGCloudStatus status;
@property (assign, nonatomic) BOOL          isEnabledOnDevice;

+ (instancetype)sharedManager;
- (void)initialize;

- (void)sync;
- (void)syncFilesWithCloud;
- (void)disableCloud;
- (void)saveNewTokenAndSyncInfo;
- (void)syncDone;

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

@end
