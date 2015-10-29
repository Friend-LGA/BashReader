//
//  BashFavouriteQuotesEntity.h
//  Bash
//
//  Created by Friend_LGA on 11.03.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BashFavouriteQuotesEntity : NSManagedObject

@property (nonatomic, retain) NSString *chapter;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSDate   *dateAdded;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *source;

@end
