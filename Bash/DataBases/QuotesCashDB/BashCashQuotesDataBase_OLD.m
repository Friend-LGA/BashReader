//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "BashCashQuotesDataBase_OLD.h"
#import "LGKit.h"

static NSString *const kDataBaseName  = @"Bash.sqlite";
static NSString *const kDataModelName = @"BashCashQuotesDataModel_OLD";

#pragma mark ----------------------------------------------------------------------------------------------------

@interface BashCashQuotesDataBase_OLD ()

@property (strong, nonatomic) NSManagedObjectModel          *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext        *managedObjectContext;
@property (strong, nonatomic) NSPersistentStore             *persistentStore;
@property (strong, nonatomic) NSPersistentStoreCoordinator  *persistentStoreCoordinator;

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation BashCashQuotesDataBase_OLD

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
        NSLog(@"BashCashQuotesDataBase_OLD: Shared Manager initialization...");
    }
	return self;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = _managedObjectContext;
    
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"BashCashQuotesDataBase_OLD: Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) return _managedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil)
    {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) return _managedObjectModel;
    
    NSURL *dataModelURL = [[NSBundle mainBundle] URLForResource:kDataModelName withExtension:@"momd"];
    NSLog(@"BashCashQuotesDataBase_OLD: File data model - %@", dataModelURL);
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:dataModelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) return _persistentStoreCoordinator;
    
    NSURL *dataBaseURL = [kDocumentsDirectoryURL URLByAppendingPathComponent:kDataBaseName];
    NSLog(@"BashCashQuotesDataBase_OLD: File data base - %@", dataBaseURL);
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    _persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                 configuration:nil
                                                                           URL:dataBaseURL
                                                                       options:nil
                                                                         error:&error];
    
    if (!_persistentStore)
    {
        NSLog(@"BashCashQuotesDataBase_OLD: Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (void)removeDataBase
{
    _managedObjectModel = nil;
    _managedObjectContext = nil;
    _persistentStore = nil;
    _persistentStoreCoordinator = nil;
    
    NSError *error;
    
    NSArray *urlArray = [kFileManager contentsOfDirectoryAtURL:kDocumentsDirectoryURL includingPropertiesForKeys:nil options:nil error:&error];
    
    for (NSURL *url in urlArray)
        if ([url.path rangeOfString:kDataBaseName].length)
            [kFileManager removeItemAtURL:url error:&error];
}

- (BOOL)isExists
{
    NSURL *storeURL = [kDocumentsDirectoryURL URLByAppendingPathComponent:kDataBaseName];
    
    return [kFileManager fileExistsAtPath:storeURL.path];
}

@end













