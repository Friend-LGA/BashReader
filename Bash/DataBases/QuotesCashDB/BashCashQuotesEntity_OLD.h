//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface BashCashQuotesEntity_OLD : NSManagedObject

@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSDate   *dateAdded;
@property (nonatomic, retain) NSNumber *number;
@property (nonatomic, retain) NSNumber *rating;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSNumber *sequence;
@property (nonatomic, retain) NSString *source;

@end
