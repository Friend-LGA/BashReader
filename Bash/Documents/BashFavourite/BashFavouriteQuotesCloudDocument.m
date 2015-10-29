//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "BashFavouriteQuotesCloudDocument.h"

static NSString *const  kVersionKey     = @"bashFavouriteQuotesCloudDocumentVersion";
static NSString *const  kArrayKey       = @"bashFavouriteQuotesCloudDocumentArray";
static int       const  kCurrentVersion = 1;

@implementation BashFavouriteQuotesCloudDocument

@synthesize
array = _array,
openingError = _openingError,
savingError = _savingError;

// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError
{
    if (contents)
    {
        if ([contents length] > 0)
        {
            NSData *data = (NSData *)contents;
            
            @try
            {
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                
                int version = [unarchiver decodeIntForKey:kVersionKey];
                
                if (version == kCurrentVersion)
                {
                    _array = [NSMutableArray arrayWithArray:[unarchiver decodeObjectForKey:kArrayKey]];
                    
                    _openingError = nil;
                    
                    [unarchiver finishDecoding];
                    
                    return YES;
                }
                else
                {
                    _openingError = [NSError errorWithDomain:@"Unexpected Version" code:LGDocumentErrorUnexpectedVersion userInfo:nil];
                    
                    [unarchiver finishDecoding];
                    
                    return NO;
                }
            }
            @catch (NSException *exception)
            {
                NSLog(@"BashFavouriteQuotesCloudDocument: Error while trying to unarchive array, exception - %@", exception);
                
                _openingError = [NSError errorWithDomain:@"Corrupted File" code:LGDocumentErrorCorruptFile userInfo:nil];
                
                return NO;
            }
        }
        else
        {
            _array = [NSMutableArray array];
            
            _openingError = [NSError errorWithDomain:@"Zero Length File" code:LGDocumentErrorZeroLengthFile userInfo:nil];
            
            return YES;
        }
    }
    else return NO;
}

// Called whenever the application (auto)saves the content
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError
{
    NSMutableData *data = [NSMutableData new];
    
    @try
    {
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        
        [archiver encodeInt:kCurrentVersion forKey:kVersionKey];
        [archiver encodeObject:_array forKey:kArrayKey];
        
        [archiver finishEncoding];
        
        _savingError = nil;
        
        return data;
    }
    @catch (NSException *exception)
    {
        return nil;
    }
}

- (void)openWithCompletionHandler:(void (^)(BOOL))completionHandler
{
    _openingError = [NSError errorWithDomain:@"No Such File" code:LGDocumentErrorNoSuchFile userInfo:nil];
    
    [super openWithCompletionHandler:completionHandler];
}

- (void)saveToURL:(NSURL *)url forSaveOperation:(UIDocumentSaveOperation)saveOperation completionHandler:(void (^)(BOOL))completionHandler
{
    _savingError = [NSError errorWithDomain:@"Error occurred while saving" code:LGDocumentErrorOccurredWhileSaving userInfo:nil];
    
    [super saveToURL:url forSaveOperation:saveOperation completionHandler:completionHandler];
}

@end
