//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BashFavouriteQuotesCloudObject : NSObject <NSCoding>

@property (strong, nonatomic) NSString *chapter;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSDate   *dateAdded;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *source;

@end
