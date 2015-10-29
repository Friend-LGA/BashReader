//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "LGCloud.h"
#import "AppDelegate.h"
#import "TopView.h"
#import "BottomView.h"
#import "LGKit.h"
#import "Settings.h"
#import "LGChapter.h"
#import "LGDocuments.h"
#import "Versions.h"
#import "InfoViewController.h"

static NSString *const kCloudTokenKey = @"ubiquityIdentityToken";

#pragma mark ----------------------------------------------------------------------------------------------------

@interface LGCloud ()

@property (strong, nonatomic) NSMetadataQuery   *metadataQuery;
@property (assign, nonatomic) BOOL              isCloudNotificationAdded;

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation LGCloud

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static id sharedManager = nil;
    
    dispatch_once(&once, ^
                  {
                      sharedManager = [super new];
                  });
    
    return sharedManager;
}

- (id)init
{
    LOG(@"");
    
    if ((self = [super init]))
    {
        NSLog(@"LGCloud: Shared Manager initialization...");
    }
    
	return self;
}

- (void)initialize
{
    LOG(@"");
    
    _status = LGCloudStatusSyncing;
    _statusDescription = @"Идет синхронизация данных с iCloud...";
    
    [self checkCloudAvailability];
}

- (void)checkCloudAvailability
{
    LOG(@"");
    
    if (!_isCloudNotificationAdded)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudAccountAvailabilityChanged:) name:NSUbiquityIdentityDidChangeNotification object:nil];
        
        _isCloudNotificationAdded = YES;
    }
    
    id cloudToken = [kFileManager ubiquityIdentityToken];
    
    NSLog(@"LGCloud: iCloud Token -------- %@", cloudToken);
    
    if (cloudToken)
    {
        _isEnabledOnDevice = YES;
        
        if (!kSettings.isCloudEnabled)
        {
            NSLog(@"LGCloud: iCloud is DISABLED");
            
            _status = LGCloudStatusDisabled;
            _statusDescription = @"iCloud отключен.";
        }
    }
    else
    {
        NSLog(@"LGCloud: iCloud is DISABLED");
        
        kSettings.isCloudEnabled = NO;
        _status = LGCloudStatusDisabled;
        _isEnabledOnDevice = NO;
        
        NSString *deviceModel = @"девайса";
        if ([kDeviceModel rangeOfString:@"iPhone"].length != 0) deviceModel = @"iPhone";
        else if ([kDeviceModel rangeOfString:@"iPad"].length != 0) deviceModel = @"iPad";
        else if ([kDeviceModel rangeOfString:@"iPod"].length != 0) deviceModel = @"iPod";
        
        _statusDescription = [NSString stringWithFormat:@"iCloud отключен в настройках %@.", deviceModel];
        
        [kBottomView tableViewCollapseCloudSettings];
    }
}

- (void)sync
{
    LOG(@"");
    
    if (_status != LGCloudStatusDisabled)
    {
        if (kLGChapter.type == LGChapterTypeFavourites)
        {
            __weak typeof(self) wself = self;
            
            if (kTopView)
            {
                [kTopView tableViewRefreshWithCompletionHandler:^(void)
                 {
                     if (wself)
                     {
                         __strong typeof(wself) self = wself;
                         
                         [self sync2];
                     }
                 }];
            }
            else [self sync2];
        }
        else [self sync2];
    }
}

- (void)sync2
{
    id cloudTokenSaved;
    NSData *cloudTokenSavedData = [kStandartUserDefaults objectForKey:kCloudTokenKey];
    
    if (cloudTokenSavedData)
    {
        @try
        {
            cloudTokenSaved = [NSKeyedUnarchiver unarchiveObjectWithData:cloudTokenSavedData];
        }
        @catch (NSException *exception)
        {
            NSLog(@"LGCloud: Error while trying to unarchive cloudTokenSaved, exception - %@", exception);
            
            cloudTokenSaved = nil;
        }
    }
    else cloudTokenSaved = nil;
    
    NSLog(@"LGCloud: iCloud Token Saved ------ %@", cloudTokenSaved);
    NSLog(@"LGCloud: iCloud Documents Directory -------- %@", kCloudDocumentsDirectoryURL);
    
    id cloudToken = [kFileManager ubiquityIdentityToken];
    
    if ([cloudToken isEqual:cloudTokenSaved]) [self checkDirectoriesAndFiles];
    else
    {
        if (cloudTokenSaved) [self clearCloud];
        
        if (kNavController.isLaunched) [kNavController showSyncInfo];
        else kLGKit.needsToShowSyncInfo = YES;
    }
}

- (void)checkDirectoriesAndFiles
{
    LOG(@"");
    
    NSError *error;
    
    NSLog(@"LGCloud: CHECK is directory EXISTS - %@", kCloudDocumentsDirectoryURL);
    
    if([kFileManager fileExistsAtPath:kCloudDocumentsDirectoryURL.path]) NSLog(@"LGCloud: directory EXISTS");
    else
    {
        NSLog(@"LGCloud: Directory does NOT EXISTS, CREATE NEW");
        
        if([kFileManager createDirectoryAtURL:kCloudDocumentsDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error])
            NSLog(@"LGCloud: CREATE directory SUCCESS");
        else
            NSLog(@"LGCloud: CREATE directory ERROR - %@", error);
    }
    
    NSLog(@"LGCloud: Contents of directory:\n%@", [kFileManager contentsOfDirectoryAtPath:kCloudDocumentsDirectoryURL.path error:&error]);
    
    NSLog(@"LGCloud: CHECK is directory EXISTS - %@", kCloudDocumentsBashDirectoryURL);
    
    if([kFileManager fileExistsAtPath:kCloudDocumentsBashDirectoryURL.path]) NSLog(@"LGCloud: directory EXISTS");
    else
    {
        NSLog(@"LGCloud: Directory does NOT EXISTS, CREATE NEW");
        
        if([kFileManager createDirectoryAtURL:kCloudDocumentsBashDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error])
            NSLog(@"LGCloud: CREATE directory SUCCESS");
        else
            NSLog(@"LGCloud: CREATE directory ERROR - %@", error);
    }
    
    NSLog(@"LGCloud: Contents of directory:\n%@", [kFileManager contentsOfDirectoryAtPath:kCloudDocumentsBashDirectoryURL.path error:&error]);
    
    [self syncFilesWithCloud];
}

- (void)syncFilesWithCloud
{
    LOG(@"");
    
    _metadataQuery = [NSMetadataQuery new];
    
    if (kVersions.isNeedsToReplaceCloudDocument) [_metadataQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE '*.quotes'", NSMetadataItemFSNameKey]];
    else [_metadataQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE '*.doc'", NSMetadataItemFSNameKey]];
    [_metadataQuery setSearchScopes:[NSArray arrayWithObjects:NSMetadataQueryUbiquitousDocumentsScope, nil]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataQueryDidFinishGathering:) name:NSMetadataQueryDidFinishGatheringNotification object:_metadataQuery];
    [_metadataQuery startQuery];
}

- (void)metadataQueryDidFinishGathering:(NSNotification *)notification
{
    LOG(@"");
    
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:query];
    [query stopQuery];
    
    NSLog(@"LGCloud: query.results:\n%@", query.results);
    
    if (kVersions.isNeedsToReplaceCloudDocument)
    {
        if (query.resultCount) [kLGDocuments initOpenReplaceOldCloudDocuments];
        else
        {
            [kVersions setNeedsToReplaceCloudDocument:NO];
            [self syncFilesWithCloud];
        }
    }
    else [kLGDocuments initOpenSyncCloudDocuments];
}

#pragma mark - Дополнительные методы

- (void)saveNewTokenAndSyncInfo
{
    LOG(@"");
    
    id cloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    NSData *cloudTokenData = [NSKeyedArchiver archivedDataWithRootObject:cloudToken];
    
    [kStandartUserDefaults setObject:cloudTokenData forKey:kCloudTokenKey];
    
    [self checkDirectoriesAndFiles];
}

- (void)clearCloud
{
    LOG(@"");
    
    [kLGDocuments closeAllCloudDocuments];
    
    NSError *error;
    
    NSLog(@"LGCloud: CLEAR iCloud directory - %@", kCloudDocumentsBashDirectoryURL);
    
    if ([kFileManager fileExistsAtPath:kCloudDocumentsBashDirectoryURL.path])
    {
        if ([kFileManager evictUbiquitousItemAtURL:kCloudDocumentsBashDirectoryURL error:&error])
            NSLog(@"LGCloud: EVICT directory SUCCESS");
        else
            NSLog(@"LGCloud: EVICT directory ERROR - %@", error);
    }
    else NSLog(@"LGCloud: Directory does NOT EXISTS");
}

- (void)disableCloud
{
    LOG(@"");
    
    [kLGDocuments closeAllCloudDocuments];
    
    kSettings.isCloudEnabled = NO;
    _status = LGCloudStatusDisabled;
    _statusDescription = @"iCloud отключен.";
    
    [kBottomView tableViewCollapseCloudSettings];
    
    if (kLGChapter.type == LGChapterTypeFavourites)
    {
        [kTopView tableViewRefreshWithCompletionHandler:^(void)
         {
             [kTopView tableViewLoadQuotes];
         }];
    }
}

- (void)cloudAccountAvailabilityChanged:(NSNotification *)notification
{
    LOG(@"");
    
    [kLGDocuments closeAllCloudDocuments];
    
    kSettings.isCloudEnabled = YES;
    
    [kBottomView tableViewSetCloudSettingsTo:YES];
    
    [self initialize];
    
    [self sync];
}

- (void)syncDone
{
    LOG(@"");
    
    if (kSettings.syncType != LGSyncBoth)
    {
        kSettings.syncType = LGSyncBoth;
        [kStandartUserDefaults setInteger:kSettings.syncType forKey:@"syncType"];
    }
    
    if (kLGChapter.type == LGChapterTypeFavourites)
    {
        [kTopView tableViewRefreshWithCompletionHandler:^(void)
        {
            [kTopView tableViewLoadQuotes];
        }];
    }
    
    _status = LGCloudStatusWorking;
    _statusDescription = @"Данные синхронизированы с iCloud.";
}

@end











