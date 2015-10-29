//
//  Entity.h
//  Bash
//
//  Created by Friend_LGA on 11.03.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BashCashQuotesEntity : NSManagedObject

@property (nonatomic, retain) NSString *chapter;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSDate   *dateAdded;
@property (nonatomic, retain) NSNumber *number;
@property (nonatomic, retain) NSNumber *page;
@property (nonatomic, retain) NSNumber *period;
@property (nonatomic, retain) NSNumber *rating;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSNumber *sequence;
@property (nonatomic, retain) NSString *source;

@end
