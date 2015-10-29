//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "BashFavouriteQuotesCloudDocument_OLD.h"

#pragma mark ----------------------------------------------------------------------------------------------------

@interface FavouriteQuote : NSObject <NSCoding>

@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSDate   *dateAdded;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *source;

@end

@implementation FavouriteQuote

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_date         forKey:@"date"];
    [encoder encodeObject:_dateAdded    forKey:@"dateAdded"];
    [encoder encodeObject:_text         forKey:@"text"];
    [encoder encodeObject:_source       forKey:@"source"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        _date       = [decoder decodeObjectForKey:@"date"];
        _dateAdded  = [decoder decodeObjectForKey:@"dateAdded"];
        _text       = [decoder decodeObjectForKey:@"text"];
        _source     = [decoder decodeObjectForKey:@"source"];
    }
    return self;
}

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation BashFavouriteQuotesCloudDocument_OLD

// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError
{
    if ([contents length] > 0)
    {
        NSData *data = (NSData *)contents;
        
        @try
        {
            _array = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
        }
        @catch (NSException *exception)
        {
            NSLog(@"BashFavouriteQuotesCloudDocument_OLD: Error while trying to unarchive array, exception - %@", exception);
            
            return NO;
        }
    }
    else _array = [NSMutableArray array];
    
    return YES;
}

// Called whenever the application (auto)saves the content
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError
{
    return [NSKeyedArchiver archivedDataWithRootObject:_array];
}

@end
