//
//  LGDocument.m
//  Bash
//
//  Created by Friend_LGA on 21.02.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "LGDocuments.h"
#import "BashFavouriteQuotesEntity.h"
#import "BashFavouriteQuotesCloudObject.h"
#import "BashFavouriteQuotesCloudDocument.h"
#import "BashFavouriteQuotesCloudBackupDocument.h"
#import "BashFavouriteQuotesCloudDocument_OLD.h"
#import "AppDelegate.h"
#import "LGKit.h"
#import "Settings.h"
#import "LGCloud.h"
#import "LGCoreData.h"
#import "Versions.h"
#import "LGChapter.h"
#import "TopView.h"

static NSString *const kCloudDocumentName           = @"bashFavouriteQuotes.doc";
static NSString *const kCloudBackupDocumentName     = @"bashFavouriteQuotesBackup.doc";

static NSString *const kCloudDocumentName_OLD       = @"favourite.quotes";
static NSString *const kCloudBackupDocumentName_OLD = @"backup.quotes";

static NSString *const kIsCloudDocumentRecreatedKey         = @"isCloudDocumentRecreated";
static NSString *const kIsCloudBackupDocumentRecreatedKey   = @"isCloudBackupDocumentRecreated";
static NSString *const kIsCloudDocumentReloadedKey          = @"isCloudDocumentReloaded";
static NSString *const kIsCloudBackupDocumentReloadedKey    = @"isCloudBackupDocumentReloaded";

#pragma mark ----------------------------------------------------------------------------------------------------

@interface LGDocuments ()

@property (strong, nonatomic) BashFavouriteQuotesCloudDocument          *cloudDocument;
@property (strong, nonatomic) BashFavouriteQuotesCloudBackupDocument    *cloudBackupDocument;
@property (strong, nonatomic) BashFavouriteQuotesCloudDocument_OLD      *cloudDocument_OLD;
@property (strong, nonatomic) BashFavouriteQuotesCloudDocument_OLD      *cloudBackupDocument_OLD;
@property (assign, nonatomic) BOOL                                      isCloudDocumentRecreated;
@property (assign, nonatomic) BOOL                                      isCloudBackupDocumentRecreated;
@property (assign, nonatomic) BOOL                                      isCloudDocumentReloaded;
@property (assign, nonatomic) BOOL                                      isCloudBackupDocumentReloaded;
@property (assign, nonatomic) BOOL                                      isCloudDocumentsReloaded;
@property (assign, nonatomic) BOOL                                      isFileVersionError;
@property (assign, nonatomic) BOOL                                      isCloudDocumentRemoved;
@property (assign, nonatomic) BOOL                                      isCloudBackupDocumentRemoved;

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation LGDocuments

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
        NSLog(@"LGDocument: Shared Manager initialization...");
    }
    
	return self;
}

- (void)openDocument:(UIDocument *)document completionHandler:(void(^)(BOOL result))completionHandler
{
    LOG(@"");
    
    if ([kFileManager fileExistsAtPath:document.fileURL.path])
    {
        NSLog(@"LGDocuments: Document EXISTS, OPEN - %@", document.fileURL);
        
        if (document.documentState & UIDocumentStateClosed)
        {
            [document openWithCompletionHandler:^(BOOL success)
             {
                 if (success)
                 {
                     NSLog(@"LGDocuments: OPEN Document SUCCEESS");
                     
                     completionHandler(YES);
                 }
                 else
                 {
                     NSLog(@"LGDocuments: OPEN Document ERROR");
                  
                     completionHandler(NO);
                 }
             }];
        }
        else
        {
            NSLog(@"LGDocuments: Document already OPENED");
         
            completionHandler(YES);
        }
    }
    else
    {
        NSLog(@"LGDocuments: Document does NOT EXISTS, CREATE NEW - %@", document.fileURL);
        
        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
         {
             if (success)
             {
                 NSLog(@"LGDocuments: CREATE Document SUCCEESS");
                 
                 completionHandler(YES);
             }
             else
             {
                 NSLog(@"LGDocuments: CREATE Document ERROR");
              
                 completionHandler(NO);
             }
         }];
    }
}

- (void)saveDocument:(LGDocumentTemplate *)document withArray:(NSMutableArray *)array
{
    LOG(@"");
    
    if (![document.array isEqualToArray:array] || !array)
    {
        NSLog(@"LGDocuments: SAVE Document - %@", document.fileURL);
        
        document.array = [NSMutableArray arrayWithArray:array];
        
        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success)
         {
             if (success) NSLog(@"LGDocuments: SAVE Document SUCCEESS");
             else NSLog(@"LGDocuments: SAVE Document ERROR");
         }];
    }
}

- (void)closeDocument:(UIDocument *)document
{
    LOG(@"");
    
    NSLog(@"LGDocuments: CLOSE Document - %@", document.fileURL);
    
    if (!(document.documentState & UIDocumentStateClosed))
    {
        [document closeWithCompletionHandler:^(BOOL success)
         {
             if (success) NSLog(@"LGDocuments: CLOSE Document SUCCEESS");
             else NSLog(@"LGDocuments: CLOSE Document ERROR");
         }];
    }
    else NSLog(@"LGDocuments: Document already CLOSED");
}

- (BOOL)removeDocument:(UIDocument *)document
{
    LOG(@"");
    
    BOOL result = NO;
    
    if ([kFileManager fileExistsAtPath:document.fileURL.path])
    {
        NSLog(@"LGDocuments: Document EXISTS, REMOVE - %@", document.fileURL);
        
        [self closeDocument:document];
        
        NSError *error;
        
        if ([kFileManager removeItemAtURL:document.fileURL error:&error])
        {
            NSLog(@"LGDocuments: REMOVE Document SUCCESS");
            
            result = YES;
        }
        else NSLog(@"LGDocuments: REMOVE Document ERROR");
    }
    else
    {
        NSLog(@"LGDocuments: Document does NOT EXISTS");
        
        result = YES;
    }
    
    return result;
}

- (BOOL)evictCloudDocument:(LGDocumentTemplate *)document
{
    LOG(@"");
    
    BOOL result = NO;
    
    if ([kFileManager fileExistsAtPath:document.fileURL.path])
    {
        NSLog(@"LGDocuments: Document EXISTS, EVICT - %@", document.fileURL);
        
        [self closeDocument:document];
        
        NSError *error;
        
        if ([kFileManager evictUbiquitousItemAtURL:document.fileURL error:&error])
        {
            NSLog(@"LGDocuments: EVICT Document SUCCESS");
            
            result = YES;
        }
        else NSLog(@"LGDocuments: EVICT Document ERROR");
    }
    else
    {
        NSLog(@"LGDocuments: Document does NOT EXISTS");
        
        result = YES;
    }
    
    return result;
}

- (void)closeAllCloudDocuments
{
    LOG(@"");
    
    if (_cloudDocument) [self closeDocument:_cloudDocument];
    if (_cloudBackupDocument) [self closeDocument:_cloudBackupDocument];
}

#pragma mark - Init / Open / Save / Close / Remove Methods

- (void)initOpenSyncCloudDocuments
{
    LOG(@"");
    
    [self initOpenSyncCloudDocumentsStep:1];
}

- (void)initOpenSyncCloudDocumentsStep:(int)step
{
    if (step == 1)
    {
        _isCloudDocumentRecreated = [kStandartUserDefaults boolForKey:kIsCloudDocumentRecreatedKey];
        _isCloudBackupDocumentRecreated = [kStandartUserDefaults boolForKey:kIsCloudBackupDocumentRecreatedKey];
        
        NSURL *cloudDocumentURL = [kCloudDocumentsBashDirectoryURL URLByAppendingPathComponent:kCloudDocumentName];
        _cloudDocument = [[BashFavouriteQuotesCloudDocument alloc] initWithFileURL:cloudDocumentURL];
        
        NSURL *cloudBackupDocumentURL = [kCloudDocumentsBashDirectoryURL URLByAppendingPathComponent:kCloudBackupDocumentName];
        _cloudBackupDocument = [[BashFavouriteQuotesCloudBackupDocument alloc] initWithFileURL:cloudBackupDocumentURL];
        
        _isFileVersionError = NO;
        
        [self initOpenSyncCloudDocumentsStep:2];
    }
    else if (step == 2)
    {
        [self openDocument:_cloudDocument completionHandler:^(BOOL result)
         {
             if (result) [self initOpenSyncCloudDocumentsStep:3];
             else
             {
                 [self openDocument:_cloudDocument completionHandler:^(BOOL result)
                  {
                      if (result) [self initOpenSyncCloudDocumentsStep:3];
                      else
                      {
                          if (_cloudDocument.openingError.code == LGDocumentErrorUnexpectedVersion) _isFileVersionError = YES;
                          else
                          {
                              if (!_isCloudDocumentReloaded && [self evictCloudDocument:_cloudDocument]) _isCloudDocumentReloaded = YES;
                              else
                              {
                                  _isCloudDocumentReloaded = NO;
                                  
                                  if ([self removeDocument:_cloudDocument])
                                  {
                                      _isCloudDocumentRecreated = YES;
                                      [kStandartUserDefaults setBool:YES forKey:kIsCloudDocumentRecreatedKey];
                                      
                                      [self openDocument:_cloudDocument completionHandler:^(BOOL result)
                                       {
                                           if (result) [self initOpenSyncCloudDocumentsStep:3];
                                       }];
                                  }
                              }
                          }
                      }
                  }];
             }
         }];
    }
    else if (step == 3)
    {
        [self openDocument:_cloudBackupDocument completionHandler:^(BOOL result)
         {
             if (result) [self initOpenSyncCloudDocumentsStep:4];
             else
             {
                 [self openDocument:_cloudBackupDocument completionHandler:^(BOOL result)
                  {
                      if (result) [self initOpenSyncCloudDocumentsStep:4];
                      else
                      {
                          if (_cloudBackupDocument.openingError.code == LGDocumentErrorUnexpectedVersion) _isFileVersionError = YES;
                          else
                          {
                              if (!_isCloudBackupDocumentReloaded && [self evictCloudDocument:_cloudBackupDocument]) _isCloudBackupDocumentReloaded = YES;
                              else
                              {
                                  _isCloudBackupDocumentReloaded = NO;
                                  
                                  if ([self removeDocument:_cloudBackupDocument])
                                  {
                                      _isCloudBackupDocumentRecreated = YES;
                                      [kStandartUserDefaults setBool:YES forKey:kIsCloudBackupDocumentRecreatedKey];
                                      
                                      [self openDocument:_cloudBackupDocument completionHandler:^(BOOL result)
                                       {
                                           if (result) [self initOpenSyncCloudDocumentsStep:4];
                                       }];
                                  }
                              }
                          }
                      }
                  }];
             }
         }];
    }
    else if (step == 4)
    {
        if (!_isFileVersionError)
        {
            if (_isCloudDocumentReloaded || _isCloudBackupDocumentReloaded)
            {
                if (!_isCloudDocumentsReloaded)
                {
                    _isCloudDocumentsReloaded = YES;
                    
                    [kLGCloud sync];
                }
            }
            else
            {
                if ([kLGCoreData isBashFavouriteQuotesDataBaseRecreated] && !_isCloudBackupDocumentRecreated)
                    [self restoreBashFavouriteQuotesDataBaseFromCloudBackup];
                
                [self syncBashFavouriteQuotesLocalAndCloud];
            }
        }
        else
        {
            [kLGCloud disableCloud];
            
            if (kNavController.isLaunched)
            {
                [kNavController showFileVersionError];
                
                if (kLGChapter.type == LGChapterTypeFavourites) [kTopView tableViewLoadQuotes];
            }
            else kLGKit.needsToShowFileVersionError = YES;
        }
    }
}

#pragma mark -

- (void)restoreBashFavouriteQuotesDataBaseFromCloudBackup
{
    LOG(@"");
    
    [self restoreBashFavouriteQuotesDataBaseFromCloudBackupStep:1];
}

- (void)restoreBashFavouriteQuotesDataBaseFromCloudBackupStep:(int)step
{
    if (step == 1)
    {
        if (_cloudBackupDocument.documentState & UIDocumentStateClosed) [self restoreBashFavouriteQuotesDataBaseFromCloudBackupStep:2];
        else [self restoreBashFavouriteQuotesDataBaseFromCloudBackupStep:3];
    }
    else if (step == 2)
    {
        [self openDocument:_cloudBackupDocument completionHandler:^(BOOL result)
        {
            if (result) [self restoreBashFavouriteQuotesDataBaseFromCloudBackupStep:3];
        }];
    }
    else if (step == 3)
    {
        NSMutableArray *cloudBackupArray = [NSMutableArray arrayWithArray:_cloudBackupDocument.array];
        
        // добавляем все цитаты в базу
        
        if (cloudBackupArray.count)
        {
            NSManagedObjectContext *context = [kLGCoreData getContextOfBashFavouriteQuotesDataBase];
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:context];
            
            for (BashFavouriteQuotesCloudObject *backupQuote in cloudBackupArray)
            {
                BashFavouriteQuotesEntity *quote = [[BashFavouriteQuotesEntity alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
                quote.date = backupQuote.date;
                quote.dateAdded = backupQuote.dateAdded;
                quote.source = backupQuote.source;
                quote.text = backupQuote.text;
            }
            
            [kLGCoreData saveContextOfBashFavouriteQuotesDataBase];
        }
    }
}

#pragma mark -

- (void)syncBashFavouriteQuotesLocalAndCloud
{
    LOG(@"");
    
    [self syncBashFavouriteQuotesLocalAndCloudStep:1];
}

- (void)syncBashFavouriteQuotesLocalAndCloudStep:(int)step
{
    if (step == 1)
    {
        if (_cloudDocument.documentState & UIDocumentStateClosed) [self syncBashFavouriteQuotesLocalAndCloudStep:2];
        else [self syncBashFavouriteQuotesLocalAndCloudStep:3];
    }
    else if (step == 2)
    {
        [self openDocument:_cloudDocument completionHandler:^(BOOL result)
        {
            if (result) [self syncBashFavouriteQuotesLocalAndCloudStep:3];
        }];
    }
    else if (step == 3)
    {
        if (_cloudBackupDocument.documentState & UIDocumentStateClosed) [self syncBashFavouriteQuotesLocalAndCloudStep:4];
        else [self syncBashFavouriteQuotesLocalAndCloudStep:5];
    }
    else if (step == 4)
    {
        [self openDocument:_cloudBackupDocument completionHandler:^(BOOL result)
         {
             if (result) [self syncBashFavouriteQuotesLocalAndCloudStep:5];
         }];
    }
    else if (step == 5)
    {
        NSError *error;
        
        NSManagedObjectContext *context = [kLGCoreData getContextOfBashFavouriteQuotesDataBase];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:context];
        NSFetchRequest *request = [NSFetchRequest new];
        [request setEntity:entityDescription];
        
        NSArray *localArray = [context executeFetchRequest:request error:&error];
        NSMutableArray *cloudArray = [NSMutableArray arrayWithArray:_cloudDocument.array];
        
        NSMutableArray *localExceptedArray = [NSMutableArray new];
        NSMutableArray *cloudExceptedArray = [NSMutableArray new];
        
        if (kSettings.syncType == LGSyncCloudToLocal) // очистка Local
        {
            for (BashFavouriteQuotesEntity *quote in localArray)
                [context deleteObject:quote];
            
            localArray = [NSArray array];
        }
        
        if (kSettings.syncType == LGSyncLocalToCloud) // очистка iCloud
            cloudArray = [NSMutableArray array];
        
        // ----------------------------------------------------------------------------------------
        
        if (localArray.count)
        {
            for (BashFavouriteQuotesEntity *quote in localArray)
            {
                if (!quote.text || !quote.text.length) [context deleteObject:quote];
                else
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(text = %@)", quote.text];
                    NSArray *matchesArray = [cloudArray filteredArrayUsingPredicate:predicate];
                    
                    if (!matchesArray.count) [cloudExceptedArray addObject:quote];
                }
            }
        }
        
        // ----------------------------------------------------------------------------------------
        
        if (cloudArray.count)
        {
            NSMutableArray *objectsToRemove = [NSMutableArray new];
            
            for (BashFavouriteQuotesCloudObject *quote in cloudArray)
            {
                if (!quote.text || !quote.text.length) [objectsToRemove addObject:quote];
                else
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(text = %@)", quote.text];
                    NSArray *matchesArray = [localArray filteredArrayUsingPredicate:predicate];
                    
                    if (!matchesArray.count) [localExceptedArray addObject:quote];
                }
            }
            
            if (objectsToRemove.count) [cloudArray removeObjectsInArray:objectsToRemove];
        }
        
        // ----------------------------------------------------------------------------------------
        
        if (localExceptedArray.count)
        {
            for (BashFavouriteQuotesCloudObject *exceptedQuote in localExceptedArray)
            {
                BashFavouriteQuotesEntity *quote = [[BashFavouriteQuotesEntity alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
                quote.date = exceptedQuote.date;
                quote.dateAdded = exceptedQuote.dateAdded;
                quote.source = exceptedQuote.source;
                quote.text = exceptedQuote.text;
            }
            
            [kLGCoreData saveContextOfBashFavouriteQuotesDataBase];
        }
        
        if (cloudExceptedArray.count)
        {
            for (BashFavouriteQuotesEntity *exceptedQuote in cloudExceptedArray)
            {
                BashFavouriteQuotesCloudObject *quote = [BashFavouriteQuotesCloudObject new];
                quote.date = exceptedQuote.date;
                quote.dateAdded = exceptedQuote.dateAdded;
                quote.source = exceptedQuote.source;
                quote.text = exceptedQuote.text;
                
                [cloudArray addObject:quote];
            }
            
            [self saveDocument:_cloudDocument withArray:cloudArray];
            [self saveDocument:_cloudBackupDocument withArray:cloudArray];
        }
        
        [self closeDocument:_cloudBackupDocument];
        
        [kLGCoreData saveBashFavouriteQuotesDataBaseToLocalBackup];
        
        [kLGCloud syncDone];
        
        NSLog(@"LGDocuments: Добавлено в Local базу - %i цитат", (int)localExceptedArray.count);
        NSLog(@"LGDocuments: Добавлено в Cloud базу - %i цитат", (int)cloudExceptedArray.count);
        NSLog(@"LGDocuments: Всего в избранном      - %i цитат", (int)localArray.count+(int)localExceptedArray.count);
    }
}

#pragma mark -

- (NSMutableArray *)getArrayOfCloudDocument
{
    return _cloudDocument.array;
}

- (void)saveCloudDocumentWithArray:(NSMutableArray *)array
{
    [self saveDocument:_cloudDocument withArray:array];
}

#pragma mark - Fill from old docs

- (void)initOpenReplaceOldCloudDocuments
{
    LOG(@"");
    
    [self initOpenReplaceOldCloudDocumentsStep:1];
}

- (void)initOpenReplaceOldCloudDocumentsStep:(int)step
{
    if (step == 1)
    {
        NSURL *cloudDocumentURL = [kCloudDocumentsDirectoryURL URLByAppendingPathComponent:kCloudDocumentName_OLD];
        _cloudDocument_OLD = [[BashFavouriteQuotesCloudDocument_OLD alloc] initWithFileURL:cloudDocumentURL];
        
        NSURL *cloudBackupDocumentURL = [kCloudDocumentsDirectoryURL URLByAppendingPathComponent:kCloudBackupDocumentName_OLD];
        _cloudBackupDocument_OLD = [[BashFavouriteQuotesCloudDocument_OLD alloc] initWithFileURL:cloudBackupDocumentURL];
        
        _isCloudDocumentRemoved = NO;
        _isCloudBackupDocumentRemoved = NO;
        
        [self initOpenReplaceOldCloudDocumentsStep:2];
    }
    else if (step == 2)
    {
        [self openDocument:_cloudDocument_OLD completionHandler:^(BOOL result)
         {
             if (result) [self initOpenReplaceOldCloudDocumentsStep:3];
             else
             {
                 [self openDocument:_cloudDocument_OLD completionHandler:^(BOOL result)
                  {
                      if (result) [self initOpenReplaceOldCloudDocumentsStep:3];
                      else
                      {
                          [self removeDocument:_cloudDocument_OLD];
                          
                          _isCloudDocumentRemoved = YES;
                      }
                  }];
             }
         }];
    }
    else if (step == 3)
    {
        if (!_isCloudDocumentRemoved) [self removeDocument:_cloudBackupDocument_OLD];
        else
        {
            [self openDocument:_cloudBackupDocument_OLD completionHandler:^(BOOL result)
             {
                 if (result) [self initOpenReplaceOldCloudDocumentsStep:4];
                 else
                 {
                     [self openDocument:_cloudBackupDocument_OLD completionHandler:^(BOOL result)
                      {
                          if (result) [self initOpenReplaceOldCloudDocumentsStep:4];
                          else
                          {
                              [self removeDocument:_cloudBackupDocument_OLD];
                              
                              _isCloudBackupDocumentRemoved = YES;
                          }
                      }];
                 }
             }];
        }
    }
    else if (step == 4)
    {
        if (!_isCloudDocumentRemoved) [self fillBashFavouriteQuotesDataBaseFromOldCloudDocument_fromBackup:NO];
        else if (!_isCloudBackupDocumentRemoved) [self fillBashFavouriteQuotesDataBaseFromOldCloudDocument_fromBackup:YES];
    }
}

#pragma mark -

- (void)fillBashFavouriteQuotesDataBaseFromOldCloudDocument_fromBackup:(BOOL)fromBackup
{
    LOG(@"");
    
    NSError *error;

    NSManagedObjectContext *favouriteContext = [kLGCoreData getContextOfBashFavouriteQuotesDataBase];
    NSEntityDescription *favouriteEntityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:favouriteContext];
    NSFetchRequest *request = [NSFetchRequest new];
    [request setEntity:favouriteEntityDescription];
    
    NSArray *oldArray;
    if (fromBackup) oldArray = [NSArray arrayWithArray:_cloudBackupDocument_OLD.array];
    else oldArray = [NSArray arrayWithArray:_cloudDocument_OLD.array];
    
    for (BashFavouriteQuotesCloudObject *oldQuote in oldArray)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(text = %@)", oldQuote.text];
        [request setPredicate:predicate];
        
        NSArray *matchesArray = [favouriteContext executeFetchRequest:request error:&error];
        
        if (!matchesArray.count)
        {
            BashFavouriteQuotesEntity *quote = [[BashFavouriteQuotesEntity alloc] initWithEntity:favouriteEntityDescription insertIntoManagedObjectContext:favouriteContext];
            quote.chapter   = @"Favourite";
            quote.date      = oldQuote.date;
            quote.dateAdded = oldQuote.dateAdded;
            quote.source    = oldQuote.source;
            quote.text      = oldQuote.text;
        }
    }
    
    [kLGCoreData saveContextOfBashFavouriteQuotesDataBase];

    [self removeDocument:_cloudDocument_OLD];
    [self removeDocument:_cloudBackupDocument_OLD];
    
    [kVersions setNeedsToReplaceCloudDocument:NO];
    
    [kLGCloud syncFilesWithCloud];
}

@end

















