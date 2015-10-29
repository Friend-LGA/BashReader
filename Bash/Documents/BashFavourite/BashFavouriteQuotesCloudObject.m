//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "BashFavouriteQuotesCloudObject.h"

@implementation BashFavouriteQuotesCloudObject

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        _chapter   = [decoder decodeObjectForKey:@"chapter"];
        _date      = [decoder decodeObjectForKey:@"date"];
        _dateAdded = [decoder decodeObjectForKey:@"dateAdded"];
        _text      = [decoder decodeObjectForKey:@"text"];
        _source    = [decoder decodeObjectForKey:@"source"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_chapter   forKey:@"chapter"];
    [encoder encodeObject:_date      forKey:@"date"];
    [encoder encodeObject:_dateAdded forKey:@"dateAdded"];
    [encoder encodeObject:_text      forKey:@"text"];
    [encoder encodeObject:_source    forKey:@"source"];
}

@end
