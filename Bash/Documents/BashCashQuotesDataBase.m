//
//  BashCashQuotesDataBase.m
//  Bash
//
//  Created by Friend_LGA on 13.03.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "BashCashQuotesDataBase.h"
#import "LGKit.h"

static NSString *const kDataBaseName  = @"bashCashQuotes.db";
static NSString *const kDataModelName = @"BashCashQuotesDataModel";

#pragma mark ----------------------------------------------------------------------------------------------------

@interface BashCashQuotesDataBase ()

@property (strong, nonatomic) NSManagedObjectModel          *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext        *managedObjectContext;
@property (strong, nonatomic) NSPersistentStore             *persistentStore;
@property (strong, nonatomic) NSPersistentStoreCoordinator  *persistentStoreCoordinator;

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation BashCashQuotesDataBase

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
        NSLog(@"BashCashQuotesDataBase: Shared Manager initialization...");
    }
	return self;
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) return _managedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (!coordinator) return nil;
    else
    {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        
        return _managedObjectContext;
    }
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) return _managedObjectModel;
    
    NSURL *dataModelURL = [[NSBundle mainBundle] URLForResource:kDataModelName withExtension:@"momd"];
    NSLog(@"BashCashQuotesDataBase: File data model - %@", dataModelURL);
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:dataModelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) return _persistentStoreCoordinator;
    
    NSURL *dataBaseURL = [kDocumentsBashDirectoryURL URLByAppendingPathComponent:kDataBaseName];
    NSLog(@"BashCashQuotesDataBase: File data base - %@", dataBaseURL);
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    _persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                 configuration:nil
                                                                           URL:dataBaseURL
                                                                       options:nil
                                                                         error:&error];
    
    if (!_persistentStore)
    {
        NSLog(@"BashCashQuotesDataBase: Unresolved error %@, %@", error, [error userInfo]);
        
        return nil;
    }
    else return _persistentStoreCoordinator;
}

#pragma mark ----------------------------------------------------------------------------------------------------

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = _managedObjectContext;
    
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"BashCashQuotesDataBase: Unresolved error %@, %@", error, [error userInfo]);
            
            abort();
        }
    }
}

- (void)recreate
{
    NSURL *dataBaseURL = [kDocumentsBashDirectoryURL URLByAppendingPathComponent:kDataBaseName];
    
    NSError *error;
    
    if ([kFileManager fileExistsAtPath:dataBaseURL.path])
        [kFileManager removeItemAtURL:dataBaseURL error:&error];
    
    [self managedObjectContext];
}

@end
