//
//  Entity.h
//  Bash
//
//  Created by Friend_LGA on 11.03.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BashCashQuoteObject : NSObject

typedef enum
{
    QuoteRatingNone = 0,
    QuoteRatingPlus = 1,
    QuoteRatingMinus = 2,
    QuoteRatingBayan = 3
}
QuoteRating;

@property (strong, nonatomic) NSString      *date;
@property (assign, nonatomic) NSUInteger    number;
@property (assign, nonatomic) NSUInteger    rating;
@property (strong, nonatomic) NSString      *ratingString;
@property (assign, nonatomic) QuoteRating   ratingSelected;
@property (assign, nonatomic) NSUInteger    ratingTaps;
@property (strong, nonatomic) NSString      *text;
@property (assign, nonatomic) NSUInteger    sequence;
@property (nonatomic, retain) NSString      *source;
@property (assign, nonatomic) BOOL          isFavourite;

@end
