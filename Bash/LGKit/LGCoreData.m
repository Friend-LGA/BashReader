//
//  LGCoreData.m
//  Bash
//
//  Created by Friend_LGA on 13.03.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "LGCoreData.h"
#import "BashFavouriteQuotesDataBase.h"
#import "BashFavouriteQuotesEntity.h"
#import "BashCashQuotesDataBase.h"
#import "BashCashQuotesEntity.h"
#import "BashCashQuotesDataBase_OLD.h"
#import "BashCashQuotesEntity_OLD.h"
#import "LGKit.h"
#import "LGCloud.h"
#import "Versions.h"
#import "LGDocuments.h"
#import "BashFavouriteQuotesCloudObject.h"
#import "AppDelegate.h"
#import "BashCashQuoteObject.h"

#define kBashFavouriteQuotesDataBase            [BashFavouriteQuotesDataBase sharedManager]
#define kBashCashQuotesDataBase                 [BashCashQuotesDataBase sharedManager]
#define kBashQuotesDataBase_OLD                 [BashCashQuotesDataBase_OLD sharedManager]

static NSString *const kBashCashQuotesDataBaseName                  = @"bashCashQuotes.db";
static NSString *const kBashFavouriteQuotesDataBaseName             = @"bashFavouriteQuotes.db";
static NSString *const kBashFavouriteQuotesBackupDataBaseName       = @"bashFavouriteQuotesBackup.db";

static NSString *const kIsBashFavouriteQuotesDataBaseRecreatedKey   = @"isBashFavouriteQuotesDataBaseRecreated";

#pragma mark ----------------------------------------------------------------------------------------------------

@interface LGCoreData ()

@property (assign, nonatomic) BOOL isBashFavouriteQuotesDataBaseRecreated;
@property (strong, nonatomic) NSManagedObjectContext *backgroundContext;

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation LGCoreData

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
        NSLog(@"LGCoreData: Shared Manager initialization...");
    }
    
	return self;
}

- (void)initialize
{
    LOG(@"");
    
    [self checkDirectoriesAndFiles];
}

- (void)checkDirectoriesAndFiles
{
    LOG(@"");
    
    NSError *error;
    
    NSLog(@"LGCoreData: CHECK is directory EXISTS - %@", kDocumentsBashDirectoryURL);
    
    if ([kFileManager fileExistsAtPath:kDocumentsBashDirectoryURL.path]) NSLog(@"LGCoreData: Directory EXISTS");
    else
    {
        NSLog(@"LGCoreData: Directory does NOT EXISTS, CREATE NEW");
        
        if([kFileManager createDirectoryAtURL:kDocumentsBashDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error])
            NSLog(@"LGCoreData: CREATE directory SUCCESS");
        else
            NSLog(@"LGCoreData: CREATE directory ERROR - %@", error);
    }
    
    [self initDataBases];
    
    if (kVersions.isNeedsToReplaceLocalDataBase) [self fillBashQuotesDataBasesFromOldDataBase];
}

- (void)initDataBases
{
    LOG(@"");
    
    _isBashFavouriteQuotesDataBaseRecreated = [kStandartUserDefaults boolForKey:kIsBashFavouriteQuotesDataBaseRecreatedKey];
    
    if (kBashFavouriteQuotesDataBase.managedObjectContext) [self saveBashFavouriteQuotesDataBaseToLocalBackup];
    else
    {
        _isBashFavouriteQuotesDataBaseRecreated = YES;
        [kStandartUserDefaults setBool:YES forKey:kIsBashFavouriteQuotesDataBaseRecreatedKey];
        
        [self restoreBashFavouriteQuotesDataBaseFromLocalBackup];
    }
    
    if (!kBashCashQuotesDataBase.managedObjectContext) [kBashCashQuotesDataBase recreate];
}

#pragma mark - Sync Methods

- (BOOL)isBashFavouriteQuotesDataBaseRecreated
{
    return _isBashFavouriteQuotesDataBaseRecreated;
}

- (void)restoreBashFavouriteQuotesDataBaseFromLocalBackup
{
    LOG(@"");
    
    NSURL *bashFavouriteQuotesDataBaseURL = [kDocumentsBashDirectoryURL URLByAppendingPathComponent:kBashFavouriteQuotesDataBaseName];
    NSURL *bashFavouriteQuotesBackupDataBaseURL = [kDocumentsBashDirectoryURL URLByAppendingPathComponent:kBashFavouriteQuotesBackupDataBaseName];
    
    NSError *error;
    
    if ([kFileManager copyItemAtURL:bashFavouriteQuotesBackupDataBaseURL toURL:bashFavouriteQuotesDataBaseURL error:&error])
    {
        if (kBashFavouriteQuotesDataBase.managedObjectContext)
        {
            _isBashFavouriteQuotesDataBaseRecreated = NO;
            [kStandartUserDefaults setBool:NO forKey:kIsBashFavouriteQuotesDataBaseRecreatedKey];
        }
        else
        {
            if (kLGCloud.status == LGCloudStatusDisabled)
            {
                _isBashFavouriteQuotesDataBaseRecreated = NO;
                [kStandartUserDefaults setBool:NO forKey:kIsBashFavouriteQuotesDataBaseRecreatedKey];
            }
            
            [kBashFavouriteQuotesDataBase recreate];
        }
    }
}

- (void)saveBashFavouriteQuotesDataBaseToLocalBackup
{
    LOG(@"");
    
    NSManagedObjectContext *context = kBashFavouriteQuotesDataBase.managedObjectContext;
    
    NSArray *array = [self getArrayOfBashFavouriteQuotesDataBaseWithStart:0 limit:0];
    
    // проверка на пустые цитаты
    for (BashFavouriteQuotesEntity *quote in array)
        if (!quote.text || !quote.text.length)
            [context deleteObject:quote];
    
    [kBashFavouriteQuotesDataBase saveContext];
    
    NSError *error;
    
    NSURL *bashFavouriteQuotesDataBaseURL = [kDocumentsBashDirectoryURL URLByAppendingPathComponent:kBashFavouriteQuotesDataBaseName];
    NSURL *bashFavouriteQuotesBackupDataBaseURL = [kDocumentsBashDirectoryURL URLByAppendingPathComponent:kBashFavouriteQuotesBackupDataBaseName];
    
    [kFileManager copyItemAtURL:bashFavouriteQuotesDataBaseURL toURL:bashFavouriteQuotesBackupDataBaseURL error:&error];
}

#pragma mark ----------------------------------------------------------------------------------------------------

- (NSManagedObjectContext *)getContextOfBashFavouriteQuotesDataBase
{
    LOG(@"");
    
    return kBashFavouriteQuotesDataBase.managedObjectContext;
}

- (void)saveContextOfBashFavouriteQuotesDataBase
{
    [kBashFavouriteQuotesDataBase saveContext];
}

- (NSArray *)getArrayOfBashFavouriteQuotesDataBaseWithStart:(NSUInteger)start limit:(NSUInteger)limit
{
    LOG(@"");
    
    NSError *error;
    NSManagedObjectContext *context = kBashFavouriteQuotesDataBase.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:context];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:YES];
    
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = entityDescription;
    request.sortDescriptors = @[sortDescriptor];
    request.fetchOffset = start;
    if (limit) request.fetchLimit = limit;
    
    return [context executeFetchRequest:request error:&error];
}

- (NSArray *)getArrayOfBashFavouriteQuotesDataBaseWithSortDescriptor:(NSSortDescriptor *)sortDescriptor start:(NSUInteger)start limit:(NSUInteger)limit
{
    LOG(@"");
    
    NSError *error;
    _backgroundContext = [NSManagedObjectContext new];
    [_backgroundContext setPersistentStoreCoordinator:kBashFavouriteQuotesDataBase.managedObjectContext.persistentStoreCoordinator];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:_backgroundContext];
    
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = entityDescription;
    request.sortDescriptors = @[sortDescriptor];
    request.fetchOffset = start;
    if (limit) request.fetchLimit = limit;
    
    return [_backgroundContext executeFetchRequest:request error:&error];
}

- (NSUInteger)getNumberOfObjectsInFavouriteDataBase
{
    NSError *error;
    _backgroundContext = [NSManagedObjectContext new];
    [_backgroundContext setPersistentStoreCoordinator:kBashFavouriteQuotesDataBase.managedObjectContext.persistentStoreCoordinator];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:_backgroundContext];
    
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = entityDescription;
    request.includesSubentities = NO;

    NSUInteger count = [_backgroundContext countForFetchRequest:request error:&error];
    
    return (error || count == NSNotFound ? 0 : count);
}

#pragma mark -

- (NSManagedObjectContext *)getContextOfBashCashQuotesDataBase
{
    LOG(@"");
    
    return kBashCashQuotesDataBase.managedObjectContext;
}

- (void)saveContextOfBashCashQuotesDataBase
{
    [kBashCashQuotesDataBase saveContext];
}

- (NSArray *)getArrayOfBashCashQuotesDataBaseWithEntity:(NSString *)entity sortDescriptor:(NSSortDescriptor *)sortDescriptor start:(NSUInteger)start limit:(NSUInteger)limit
{
    LOG(@"");
    
    NSError *error;
    _backgroundContext = [NSManagedObjectContext new];
    [_backgroundContext setPersistentStoreCoordinator:kBashCashQuotesDataBase.managedObjectContext.persistentStoreCoordinator];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:_backgroundContext];
    
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = entityDescription;
    request.sortDescriptors = @[sortDescriptor];
    request.fetchOffset = start;
    if (limit) request.fetchLimit = limit;

    return [_backgroundContext executeFetchRequest:request error:&error];
}

- (NSUInteger)getNumberOfObjectsInCashDataBaseWithEntity:(NSString *)entity
{
    NSError *error;
    _backgroundContext = [NSManagedObjectContext new];
    [_backgroundContext setPersistentStoreCoordinator:kBashCashQuotesDataBase.managedObjectContext.persistentStoreCoordinator];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:_backgroundContext];
    
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = entityDescription;
    request.includesSubentities = NO;
    
    NSUInteger count = [_backgroundContext countForFetchRequest:request error:&error];
    
    return (error || count == NSNotFound ? 0 : count);
}

#pragma mark - Add / Remove / Check quotes Methods

- (BOOL)isQuoteInFavourites:(BashCashQuotesEntity *)quote
{
    //LOG(@"");
    
    if (quote)
    {
        NSError *error;
        NSManagedObjectContext *context = kBashFavouriteQuotesDataBase.managedObjectContext;
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:context];
        NSFetchRequest *request = [NSFetchRequest new];
        [request setEntity:entityDescription];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(text = %@)", quote.text];
        [request setPredicate:predicate];
        
        NSArray *matchesArray = [context executeFetchRequest:request error:&error];
        
        if (!matchesArray.count) return NO;
        else return YES;
    }
    else return NO;
}

- (void)addQuoteToFavourites:(BashCashQuoteObject *)quote
{
    LOG(@"");
    
    if (quote)
    {
        {
            NSManagedObjectContext *context = kBashFavouriteQuotesDataBase.managedObjectContext;
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:context];
            
            BashFavouriteQuotesEntity *bashFavouriteQuote = [[BashFavouriteQuotesEntity alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
            bashFavouriteQuote.chapter   = @"Favourite";
            bashFavouriteQuote.date      = quote.date;
            bashFavouriteQuote.dateAdded = [NSDate date];
            bashFavouriteQuote.text      = quote.text;
            bashFavouriteQuote.source    = quote.source;
            
            [self saveContextOfBashFavouriteQuotesDataBase];
        }
        
        if (kLGCloud.status == LGCloudStatusWorking)
        {
            NSMutableArray *cloudDocumentArray = [NSMutableArray arrayWithArray:[kLGDocuments getArrayOfCloudDocument]];
            
            BashFavouriteQuotesCloudObject *bashFavouriteQuote = [BashFavouriteQuotesCloudObject new];
            bashFavouriteQuote.chapter   = @"Favourite";
            bashFavouriteQuote.date      = quote.date;
            bashFavouriteQuote.dateAdded = [NSDate date];
            bashFavouriteQuote.text      = quote.text;
            bashFavouriteQuote.source    = quote.source;
            
            [cloudDocumentArray addObject:bashFavouriteQuote];
            
            [kLGDocuments saveCloudDocumentWithArray:cloudDocumentArray];
        }
    }
}

- (void)removeQuoteFromFavourites:(BashCashQuoteObject *)quote
{
    LOG(@"");
    
    if (quote)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(text = %@)", quote.text];
        
        {
            NSError *error;
            NSManagedObjectContext *context = kBashFavouriteQuotesDataBase.managedObjectContext;
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:context];
            NSFetchRequest *request = [NSFetchRequest new];
            [request setEntity:entityDescription];
            [request setPredicate:predicate];
            
            NSArray *matchesArray = [context executeFetchRequest:request error:&error];
            
            if (matchesArray.count)
            {
                for (BashFavouriteQuotesEntity *bashFavouriteQuote in matchesArray)
                    [context deleteObject:bashFavouriteQuote];
                
                [self saveContextOfBashFavouriteQuotesDataBase];
            }
        }
        
        if (kLGCloud.status == LGCloudStatusWorking)
        {
            NSMutableArray *cloudDocumentArray = [NSMutableArray arrayWithArray:[kLGDocuments getArrayOfCloudDocument]];
            
            NSArray *matchesArray = [cloudDocumentArray filteredArrayUsingPredicate:predicate];
            
            if (matchesArray.count)
            {
                for (BashFavouriteQuotesCloudObject *bashFavouriteQuote in matchesArray)
                    [cloudDocumentArray removeObject:bashFavouriteQuote];
                
                [kLGDocuments saveCloudDocumentWithArray:cloudDocumentArray];
            }
        }
    }
}

- (void)clearBashCashQuotesDataBaseForEntity:(NSString *)entity
{
    LOG(@"");
    
    NSError *error;
    NSManagedObjectContext *context = kBashCashQuotesDataBase.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:context];
    NSFetchRequest *request = [NSFetchRequest new];
    [request setEntity:entityDescription];
    
    NSArray *matchesArray = [context executeFetchRequest:request error:&error];
    
    if (matchesArray.count)
    {
        for (BashFavouriteQuotesEntity *bashFavouriteQuote in matchesArray)
            [context deleteObject:bashFavouriteQuote];
        
        [self saveContextOfBashCashQuotesDataBase];
    }
}

- (void)removeQuotesFromCash:(NSArray *)quotesArray
{
    LOG(@"");
    
    NSError *error;
    NSManagedObjectContext *context = kBashCashQuotesDataBase.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:context];
    NSFetchRequest *request = [NSFetchRequest new];
    [request setEntity:entityDescription];
    
    for (BashCashQuotesEntity *quote in quotesArray)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(text = %@)", quote.text];
        [request setPredicate:predicate];
        
        NSArray *matchesArray = [context executeFetchRequest:request error:&error];
        
        if (matchesArray.count)
            for (BashCashQuotesEntity *quote in matchesArray)
                [context deleteObject:quote];
    }
    
    [self saveContextOfBashCashQuotesDataBase];
}

#pragma mark - Sync with OLD DataBase

- (void)fillBashQuotesDataBasesFromOldDataBase
{
    LOG(@"");
    
    // добавляем favourite
    {
        NSError *error;
        
        NSManagedObjectContext *favouriteContext = kBashFavouriteQuotesDataBase.managedObjectContext;
        NSEntityDescription *favouriteEntityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:favouriteContext];
        
        NSManagedObjectContext *oldContext = kBashQuotesDataBase_OLD.managedObjectContext;
        NSEntityDescription *oldEntityDescription = [NSEntityDescription entityForName:@"FavouritesEntity" inManagedObjectContext:oldContext];
        
        NSFetchRequest *request = [NSFetchRequest new];
        [request setEntity:oldEntityDescription];
        
        NSArray *oldArray = [oldContext executeFetchRequest:request error:&error];
        
        [request setEntity:favouriteEntityDescription];
        
        for (BashCashQuotesEntity_OLD *oldQuote in oldArray)
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
        
        [kBashFavouriteQuotesDataBase saveContext];
    }
    
    // добавляем остальные
    {
        [self fillBashCashQuotesDataBaseFromOldDataBaseForEntityName:@"NewEntity"       chapterName:@"New"];
        [self fillBashCashQuotesDataBaseFromOldDataBaseForEntityName:@"BestEntity"      chapterName:@"Best"];
        [self fillBashCashQuotesDataBaseFromOldDataBaseForEntityName:@"RatingEntity"    chapterName:@"Rating"];
        [self fillBashCashQuotesDataBaseFromOldDataBaseForEntityName:@"AbyssEntity"     chapterName:@"Abyss"];
        [self fillBashCashQuotesDataBaseFromOldDataBaseForEntityName:@"AbyssTopEntity"  chapterName:@"AbyssTop"];
        [self fillBashCashQuotesDataBaseFromOldDataBaseForEntityName:@"AbyssBestEntity" chapterName:@"AbyssBest"];
        [self fillBashCashQuotesDataBaseFromOldDataBaseForEntityName:@"RandomEntity"    chapterName:@"Random"];
        [self fillBashCashQuotesDataBaseFromOldDataBaseForEntityName:@"SearchEntity"    chapterName:@"Search"];
        
        [kBashCashQuotesDataBase saveContext];
    }
    
    [kBashQuotesDataBase_OLD removeDataBase];
    
    [kVersions setNeedsToReplaceLocalDataBase:NO];
    
    [self saveBashFavouriteQuotesDataBaseToLocalBackup];
}

- (void)fillBashCashQuotesDataBaseFromOldDataBaseForEntityName:(NSString *)entityName chapterName:(NSString *)chapterName
{
    //LOG(@"");
    
    NSError *error;
    
    NSManagedObjectContext *cashContext = kBashCashQuotesDataBase.managedObjectContext;
    NSEntityDescription *cashEntityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:cashContext];
    
    NSManagedObjectContext *oldContext = kBashQuotesDataBase_OLD.managedObjectContext;
    NSEntityDescription *oldEntityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:oldContext];
    
    NSFetchRequest *request = [NSFetchRequest new];
    [request setEntity:oldEntityDescription];
    
    NSArray *oldArray = [oldContext executeFetchRequest:request error:&error];
    
    [request setEntity:cashEntityDescription];
    
    for (BashCashQuotesEntity_OLD *oldQuote in oldArray)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(text = %@)", oldQuote.text];
        [request setPredicate:predicate];
        
        NSArray *matchesArray = [cashContext executeFetchRequest:request error:&error];
        
        if (!matchesArray.count)
        {
            BashCashQuotesEntity *quote = [[BashCashQuotesEntity alloc] initWithEntity:cashEntityDescription insertIntoManagedObjectContext:cashContext];
            quote.chapter       = chapterName;
            quote.date          = oldQuote.date;
            quote.number        = oldQuote.number;
            if (![chapterName isEqualToString:@"AbyssBest"] && ![chapterName isEqualToString:@"AbyssTop"])
                quote.rating    = oldQuote.rating;
            quote.text = oldQuote.text;
            if ([chapterName isEqualToString:@"Abyss"] || [chapterName isEqualToString:@"Best"] || [chapterName isEqualToString:@"Random"])
                quote.sequence  = oldQuote.sequence;
            quote.source        = @"Bash";
        }
    }
}

#pragma mark - Cash Clean Methods

- (int)getNumberOfQuotesInCash
{
    NSError *error;
    NSManagedObjectContext *cashContext = kBashCashQuotesDataBase.managedObjectContext;
    
    NSEntityDescription *cashEntityDescriptionsArray[8];
    cashEntityDescriptionsArray[0] = [NSEntityDescription entityForName:@"NewEntity" inManagedObjectContext:cashContext];
    cashEntityDescriptionsArray[1] = [NSEntityDescription entityForName:@"BestEntity" inManagedObjectContext:cashContext];
    cashEntityDescriptionsArray[2] = [NSEntityDescription entityForName:@"RatingEntity" inManagedObjectContext:cashContext];
    cashEntityDescriptionsArray[3] = [NSEntityDescription entityForName:@"AbyssEntity" inManagedObjectContext:cashContext];
    cashEntityDescriptionsArray[4] = [NSEntityDescription entityForName:@"AbyssTopEntity" inManagedObjectContext:cashContext];
    cashEntityDescriptionsArray[5] = [NSEntityDescription entityForName:@"AbyssBestEntity" inManagedObjectContext:cashContext];
    cashEntityDescriptionsArray[6] = [NSEntityDescription entityForName:@"RandomEntity" inManagedObjectContext:cashContext];
    cashEntityDescriptionsArray[7] = [NSEntityDescription entityForName:@"SearchEntity" inManagedObjectContext:cashContext];
    
    NSFetchRequest *request = [NSFetchRequest new];
    
    int result = 0;
    
    for (int i=0; i<8; i++)
    {
        [request setEntity:cashEntityDescriptionsArray[i]];
        result += [cashContext executeFetchRequest:request error:&error].count;
    }
    
    return result;
}

- (NSString *)getSizeOfQuotesInCash
{
    NSURL *bashCashQuotesDataBaseURL = [kDocumentsBashDirectoryURL URLByAppendingPathComponent:kBashCashQuotesDataBaseName];
    
    NSError *error;
    
    float fileSize = [[kFileManager attributesOfItemAtPath:bashCashQuotesDataBaseURL.path error:&error] fileSize];
    
    NSString *resultString;
    
    if (fileSize < 1000) resultString = [NSString stringWithFormat:@"%.0f б", fileSize];
    else if (fileSize >= 1000 && fileSize < 1000000) resultString = [NSString stringWithFormat:@"%.1f кб", fileSize/1000];
    else if (fileSize >= 1000000) resultString = [NSString stringWithFormat:@"%.1f мб", fileSize/1000000];
    
    return resultString;
}

- (void)removeQuotesInCash
{
    NSError *error;
    //NSManagedObjectContext *cashContext = kBashCashQuotesDataBase.managedObjectContext;
    NSManagedObjectContext *cashContext = [NSManagedObjectContext new];
    [cashContext setPersistentStoreCoordinator:kBashCashQuotesDataBase.managedObjectContext.persistentStoreCoordinator];
    
    NSEntityDescription *cashEntityDescriptionsArray[8];
    cashEntityDescriptionsArray[0] = [NSEntityDescription entityForName:@"NewEntity" inManagedObjectContext:cashContext];
    cashEntityDescriptionsArray[1] = [NSEntityDescription entityForName:@"BestEntity" inManagedObjectContext:cashContext];
    cashEntityDescriptionsArray[2] = [NSEntityDescription entityForName:@"RatingEntity" inManagedObjectContext:cashContext];
    cashEntityDescriptionsArray[3] = [NSEntityDescription entityForName:@"AbyssEntity" inManagedObjectContext:cashContext];
    cashEntityDescriptionsArray[4] = [NSEntityDescription entityForName:@"AbyssTopEntity" inManagedObjectContext:cashContext];
    cashEntityDescriptionsArray[5] = [NSEntityDescription entityForName:@"AbyssBestEntity" inManagedObjectContext:cashContext];
    cashEntityDescriptionsArray[6] = [NSEntityDescription entityForName:@"RandomEntity" inManagedObjectContext:cashContext];
    cashEntityDescriptionsArray[7] = [NSEntityDescription entityForName:@"SearchEntity" inManagedObjectContext:cashContext];
    
    NSFetchRequest *request = [NSFetchRequest new];
    
    for (int i=0; i<8; i++)
    {
        [request setEntity:cashEntityDescriptionsArray[i]];
        
        NSArray *quotesArray = [cashContext executeFetchRequest:request error:&error];
        
        for (BashCashQuotesEntity *quote in quotesArray)
            [cashContext deleteObject:quote];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cashContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:cashContext];
    
    [cashContext save:&error];
}

- (void)cashContextDidSave:(NSNotification *)notification
{
    LOG(@"");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:notification.object];
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [kBashCashQuotesDataBase.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
                   });
}

@end


















